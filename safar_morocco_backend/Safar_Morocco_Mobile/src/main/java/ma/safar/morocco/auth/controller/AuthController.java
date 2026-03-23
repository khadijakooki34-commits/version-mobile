package ma.safar.morocco.auth.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.safar.morocco.auth.dto.*;
import ma.safar.morocco.auth.service.AuthService;
import ma.safar.morocco.user.entity.Utilisateur;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    /**
     * POST /api/auth/google
     * Authenticate with Google ID token (from Flutter google_sign_in).
     * Validates the token with Google, creates/finds user, returns JWT.
     */
    @PostMapping("/google")
    public ResponseEntity<AuthResponse> googleLogin(@Valid @RequestBody GoogleAuthRequest request) {
        return ResponseEntity.ok(authService.googleLogin(request));
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        return ResponseEntity.ok(authService.refreshToken(request));
    }

    @GetMapping("/me")
    public ResponseEntity<Utilisateur> getCurrentUser() {
        return ResponseEntity.ok(authService.getCurrentUser());
    }

    @PutMapping("/profile")
    public ResponseEntity<String> updateProfile(@Valid @RequestBody UpdateProfileRequest request) {
        authService.updateProfile(request);
        return ResponseEntity.ok("Profil mis à jour avec succès");
    }

    @PutMapping("/change-password")
    public ResponseEntity<String> changePassword(@Valid @RequestBody ChangePasswordRequest request) {
        authService.changePassword(request);
        return ResponseEntity.ok("Mot de passe modifié avec succès");
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<String> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        String token = authService.forgotPassword(request);
        // In dev/test, we return the token directly. In prod, we'd say "Email sent".
        return ResponseEntity.ok("Token de réinitialisation (DEV ONLY): " + token);
    }

    @PostMapping("/reset-password")
    public ResponseEntity<String> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request);
        return ResponseEntity.ok("Mot de passe réinitialisé avec succès");
    }

    @PostMapping("/logout")
    public ResponseEntity<String> logout() {
        // Le logout est géré côté client en supprimant le token
        return ResponseEntity.ok("Déconnexion réussie");
    }
}