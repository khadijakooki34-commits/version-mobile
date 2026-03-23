package ma.safar.morocco.security;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;

/**
 * OAuth2FailureHandler
 * Handles OAuth2 authentication failures and redirects to Flutter with error
 */
@Component
@Slf4j
public class OAuth2FailureHandler implements AuthenticationFailureHandler {

    @Override
    public void onAuthenticationFailure(
            HttpServletRequest request,
            HttpServletResponse response,
            AuthenticationException exception) throws IOException {
        
        log.error("OAuth2 authentication failed: {}", exception.getMessage());
        
        // Get Flutter web URL from environment or use default
        String frontendUrl = System.getenv("FRONTEND_URL");
        if (frontendUrl == null || frontendUrl.isEmpty()) {
            frontendUrl = "http://localhost:57977";
        }
        
        // Redirect to Flutter with error
        String targetUrl = UriComponentsBuilder
                .fromUriString(frontendUrl + "/oauth-callback")
                .queryParam("error", "oauth2_failed")
                .queryParam("message", exception.getMessage() != null ? exception.getMessage() : "OAuth authentication failed")
                .build()
                .toUriString();
        
        log.info("Redirecting to Flutter with error: {}", targetUrl);
        response.sendRedirect(targetUrl);
    }
}

