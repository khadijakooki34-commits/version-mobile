package ma.safar.morocco.auth.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.safar.morocco.auth.dto.*;
import ma.safar.morocco.security.JwtService;
import ma.safar.morocco.user.entity.Utilisateur;
import ma.safar.morocco.user.repository.UtilisateurRepository;
import ma.safar.morocco.user.service.ActivityLogService;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UtilisateurRepository utilisateurRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final ActivityLogService activityLogService;
    private final RestTemplate restTemplate = new RestTemplate();

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (utilisateurRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Un compte existe déjà avec cet email");
        }

        var user = Utilisateur.builder()
                .nom(request.getNom())
                .email(request.getEmail())
                .motDePasseHache(passwordEncoder.encode(request.getMotDePasse()))
                .telephone(request.getTelephone())
                .langue(request.getLangue() != null ? request.getLangue() : "fr")
                .role("USER")
                .actif(true)
                .compteBloquer(false)
                .provider("LOCAL")
                .build();
        user = utilisateurRepository.save(user);

        var accessToken = jwtService.generateToken(user);
        var refreshToken = jwtService.generateRefreshToken(user);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .userId(user.getId())
                .email(user.getEmail())
                .nom(user.getNom())
                .role(user.getRole())
                .build();
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getMotDePasse()));

        var user = utilisateurRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        if (user.getCompteBloquer()) {
            throw new RuntimeException("Votre compte a été bloqué. Contactez l'administrateur.");
        }

        if (!user.getActif()) {
            throw new RuntimeException("Votre compte est désactivé.");
        }

        var accessToken = jwtService.generateToken(user);
        var refreshToken = jwtService.generateRefreshToken(user);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .userId(user.getId())
                .email(user.getEmail())
                .nom(user.getNom())
                .role(user.getRole())
                .build();
    }

    @Transactional
    public AuthResponse googleLogin(ma.safar.morocco.auth.dto.GoogleAuthRequest request) {
        String idToken = request.getIdToken();
        if (idToken == null || idToken.isBlank()) {
            throw new RuntimeException("Google ID token is required");
        }

        try {
            // Verify token with Google's tokeninfo endpoint
            String url = "https://oauth2.googleapis.com/tokeninfo?id_token=" + idToken;
            @SuppressWarnings("unchecked")
            Map<String, Object> tokenInfo = restTemplate.getForObject(url, Map.class);

            if (tokenInfo == null) {
                throw new RuntimeException("Invalid Google token");
            }

            String email = (String) tokenInfo.get("email");
            String nom = (String) tokenInfo.get("name");
            String photoUrl = (String) tokenInfo.get("picture");
            String providerId = (String) tokenInfo.get("sub");

            if (email == null || email.isBlank()) {
                throw new RuntimeException("Email not found in Google token");
            }

            log.info("Google OAuth2 login attempt for email: {}", email);

            // Find existing user by provider/providerId or by email
            Optional<Utilisateur> existingUser = utilisateurRepository
                    .findByProviderAndProviderId("GOOGLE", providerId);

            if (existingUser.isEmpty()) {
                existingUser = utilisateurRepository.findByEmail(email);
                if (existingUser.isPresent()) {
                    Utilisateur existingByEmail = existingUser.get();
                    existingByEmail.setProvider("GOOGLE");
                    existingByEmail.setProviderId(providerId);
                    utilisateurRepository.save(existingByEmail);
                }
            }

            Utilisateur user;

            if (existingUser.isEmpty()) {
                user = Utilisateur.builder()
                        .email(email)
                        .nom(nom != null ? nom : email)
                        .photoUrl(photoUrl)
                        .provider("GOOGLE")
                        .providerId(providerId)
                        .motDePasseHache("OAUTH2_USER_" + System.currentTimeMillis())
                        .role("USER")
                        .actif(true)
                        .compteBloquer(false)
                        .langue("fr")
                        .build();
                user = utilisateurRepository.save(user);
                log.info("New Google OAuth2 user created: {}", email);
            } else {
                user = existingUser.get();
                if (photoUrl != null && !photoUrl.equals(user.getPhotoUrl())) {
                    user.setPhotoUrl(photoUrl);
                    utilisateurRepository.save(user);
                }
            }

            if (user.getCompteBloquer()) {
                throw new RuntimeException("Votre compte a été bloqué");
            }

            var accessToken = jwtService.generateToken(user);
            var refreshToken = jwtService.generateRefreshToken(user);

            return AuthResponse.builder()
                    .accessToken(accessToken)
                    .refreshToken(refreshToken)
                    .tokenType("Bearer")
                    .userId(user.getId())
                    .email(user.getEmail())
                    .nom(user.getNom())
                    .role(user.getRole())
                    .build();

        } catch (org.springframework.web.client.HttpClientErrorException e) {
            log.error("Google token verification failed: {}", e.getMessage());
            throw new RuntimeException("Invalid or expired Google token. Please try again.");
        } catch (Exception e) {
            log.error("Google login failed: {}", e.getMessage());
            throw new RuntimeException(e.getMessage() != null ? e.getMessage() : "Google sign-in failed");
        }
    }

    public AuthResponse refreshToken(RefreshTokenRequest request) {
        final String refreshToken = request.getRefreshToken();
        final String userEmail = jwtService.extractUsername(refreshToken);

        if (userEmail != null) {
            var user = utilisateurRepository.findByEmail(userEmail)
                    .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            if (jwtService.isTokenValid(refreshToken, user)) {
                var accessToken = jwtService.generateToken(user);
                var newRefreshToken = jwtService.generateRefreshToken(user);

                return AuthResponse.builder()
                        .accessToken(accessToken)
                        .refreshToken(newRefreshToken)
                        .tokenType("Bearer")
                        .userId(user.getId())
                        .email(user.getEmail())
                        .nom(user.getNom())
                        .role(user.getRole())
                        .build();
            }
        }
        throw new RuntimeException("Refresh token invalide");
    }

    @Transactional
    public void updateProfile(UpdateProfileRequest request) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        Utilisateur user = utilisateurRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        if (request.getNom() != null) {
            user.setNom(request.getNom());
        }
        if (request.getTelephone() != null) {
            user.setTelephone(request.getTelephone());
        }
        if (request.getLangue() != null) {
            user.setLangue(request.getLangue());
        }

        utilisateurRepository.save(user);
        activityLogService.logActivity(user, "PROFILE_UPDATED", "Profil mis à jour via AuthService");
    }

    @Transactional
    public void changePassword(ChangePasswordRequest request) {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        Utilisateur user = utilisateurRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        if (!passwordEncoder.matches(request.getAncienMotDePasse(), user.getMotDePasseHache())) {
            throw new RuntimeException("Ancien mot de passe incorrect");
        }

        user.setMotDePasseHache(passwordEncoder.encode(request.getNouveauMotDePasse()));
        utilisateurRepository.save(user);
    }

    public Utilisateur getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return utilisateurRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
    }

    @Transactional
    public String forgotPassword(ForgotPasswordRequest request) {
        Utilisateur user = utilisateurRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        String token = UUID.randomUUID().toString();
        user.setResetPasswordToken(token);
        user.setValiditeTokenReset(LocalDateTime.now().plusMinutes(30)); // 30 mins validity
        utilisateurRepository.save(user);

        // In a real app, send email here.
        // For this project, we return token to be displayed/logged for testing
        return token;
    }

    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        Utilisateur user = utilisateurRepository.findByResetPasswordToken(request.getToken())
                .orElseThrow(() -> new RuntimeException("Token invalide"));

        if (user.getValiditeTokenReset().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Token expiré");
        }

        user.setMotDePasseHache(passwordEncoder.encode(request.getNewPassword()));
        user.setResetPasswordToken(null);
        user.setValiditeTokenReset(null);
        utilisateurRepository.save(user);
    }
}
