package ma.safar.morocco.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for Google OAuth2 token-based authentication.
 * Used when Flutter/mobile sends the Google ID token to the backend.
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class GoogleAuthRequest {
    @NotBlank(message = "Google ID token is required")
    private String idToken;
}

