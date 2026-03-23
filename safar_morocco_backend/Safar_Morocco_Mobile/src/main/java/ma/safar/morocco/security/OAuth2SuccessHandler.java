package ma.safar.morocco.security;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.safar.morocco.user.entity.Utilisateur;
import ma.safar.morocco.user.repository.UtilisateurRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.util.Optional;

/**
 * OAuth2SuccessHandler
 * Gère la redirection après authentification OAuth2 (Google)
 * - Création automatique d'utilisateurs
 * - Génération de JWT
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class OAuth2SuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private final UtilisateurRepository utilisateurRepository;
    private final JwtService jwtService;

    @Override
    public void onAuthenticationSuccess(
            HttpServletRequest request,
            HttpServletResponse response,
            Authentication authentication) throws IOException {
        try {
            OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();

            // Récupérer les infos de l'utilisateur Google
            String email = oAuth2User.getAttribute("email");
            String nom = oAuth2User.getAttribute("name");
            String photoUrl = oAuth2User.getAttribute("picture");
            String providerId = oAuth2User.getAttribute("sub");

            log.info("OAuth2 Login attempt for email: {}", email);
            
            // Validate required attributes
            if (email == null || email.isBlank()) {
                throw new RuntimeException("Email not found in Google OAuth response");
            }
            if (providerId == null || providerId.isBlank()) {
                throw new RuntimeException("Provider ID not found in Google OAuth response");
            }

            // Chercher l'utilisateur existant d'abord par provider/providerId
            Optional<Utilisateur> existingUser = utilisateurRepository
                    .findByProviderAndProviderId("GOOGLE", providerId);

            // Si pas trouvé, chercher par email (au cas où il existe déjà avec une
            // tentative échouée)
            if (existingUser.isEmpty()) {
                existingUser = utilisateurRepository.findByEmail(email);
                // Si trouvé par email, mettre à jour le provider et providerId
                if (existingUser.isPresent()) {
                    Utilisateur existingByEmail = existingUser.get();
                    existingByEmail.setProvider("GOOGLE");
                    existingByEmail.setProviderId(providerId);
                }
            }

            Utilisateur user;
            boolean isNewUser = false;

            if (existingUser.isEmpty()) {
                // Créer un nouvel utilisateur
                user = Utilisateur.builder()
                        .email(email)
                        .nom(nom)
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
                isNewUser = true;

                log.info("New OAuth2 user created: {}", email);
            } else {
                user = existingUser.get();

                // Mettre à jour les infos si nécessaire
                if (photoUrl != null && !photoUrl.equals(user.getPhotoUrl())) {
                    user.setPhotoUrl(photoUrl);
                    utilisateurRepository.save(user);
                    log.info("Updated photo URL for user: {}", email);
                }
            }

            // Vérifier que le compte n'est pas bloqué
            if (user.getCompteBloquer()) {
                log.warn("Blocked account OAuth2 login attempt: {}", email);
                throw new RuntimeException("Votre compte a été bloqué");
            }

            // Générer les tokens JWT
            String accessToken = jwtService.generateToken(user);
            String refreshToken = jwtService.generateRefreshToken(user);

            log.info("OAuth2 authentication successful for user: {}", email);

            // Rediriger vers Flutter Web avec les tokens
            // Try to get the original referer (where the user came from)
            String referer = request.getHeader("Referer");
            String frontendUrl = System.getenv("FRONTEND_URL");
            
            // If no environment variable, try to extract from referer
            if ((frontendUrl == null || frontendUrl.isEmpty()) && referer != null) {
                try {
                    java.net.URI refererUri = java.net.URI.create(referer);
                    if (refererUri.getHost() != null && refererUri.getPort() != -1) {
                        frontendUrl = refererUri.getScheme() + "://" + refererUri.getHost() + ":" + refererUri.getPort();
                        log.info("Using referer as frontend URL: {}", frontendUrl);
                    }
                } catch (Exception e) {
                    log.warn("Failed to parse referer: {}", referer);
                }
            }
            
            // Default to Flutter web port if still not set
            if (frontendUrl == null || frontendUrl.isEmpty()) {
                frontendUrl = "http://localhost:57977";
                log.info("Using default frontend URL: {}", frontendUrl);
            }
            
            String targetUrl = UriComponentsBuilder
                    .fromUriString(frontendUrl + "/oauth-callback")
                    .queryParam("accessToken", accessToken)
                    .queryParam("refreshToken", refreshToken)
                    .queryParam("userId", user.getId())
                    .queryParam("email", user.getEmail())
                    .queryParam("nom", user.getNom() != null ? user.getNom() : "")
                    .queryParam("role", user.getRole())
                    .build()
                    .toUriString() + "#/oauth-callback";  // Add hash for Flutter Web routing

            log.info("Redirecting to Flutter: {}", targetUrl);
            response.sendRedirect(targetUrl);

        } catch (Exception e) {
            log.error("OAuth2 authentication failed: {}", e.getMessage(), e);
            
            // Try to get referer for frontend URL
            String referer = request.getHeader("Referer");
            String frontendUrl = System.getenv("FRONTEND_URL");
            
            if ((frontendUrl == null || frontendUrl.isEmpty()) && referer != null) {
                try {
                    java.net.URI refererUri = java.net.URI.create(referer);
                    if (refererUri.getHost() != null && refererUri.getPort() != -1) {
                        frontendUrl = refererUri.getScheme() + "://" + refererUri.getHost() + ":" + refererUri.getPort();
                    }
                } catch (Exception ex) {
                    log.warn("Failed to parse referer: {}", referer);
                }
            }
            
            if (frontendUrl == null || frontendUrl.isEmpty()) {
                frontendUrl = "http://localhost:57977";
            }
            
            String errorMessage = e.getMessage() != null ? e.getMessage() : "OAuth authentication failed";
            String targetUrl = UriComponentsBuilder
                    .fromUriString(frontendUrl + "/oauth-callback")
                    .queryParam("error", "oauth2_failed")
                    .queryParam("message", errorMessage)
                    .build()
                    .toUriString() + "#/oauth-callback";  // Add hash for Flutter Web routing
            
            log.info("Redirecting to Flutter with error: {}", targetUrl);
            response.sendRedirect(targetUrl);
        }
    }
}
