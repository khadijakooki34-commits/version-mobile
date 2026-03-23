package ma.safar.morocco.config;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.LockedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * GlobalExceptionHandler
 * Gestion centralisée des exceptions de l'application
 * - Exceptions de validation
 * - Exceptions d'authentification
 * - Exceptions métier
 * - Exceptions non gérées
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * Gère les erreurs de validation (@Valid)
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ResponseEntity<Map<String, Object>> handleValidationExceptions(
            MethodArgumentNotValidException ex,
            WebRequest request
    ) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });

        Map<String, Object> response = new HashMap<>();
        response.put("timestamp", LocalDateTime.now());
        response.put("status", HttpStatus.BAD_REQUEST.value());
        response.put("error", "Erreur de Validation");
        response.put("message", "Les données fournies sont invalides");
        response.put("details", errors);
        response.put("path", request.getDescription(false).replace("uri=", ""));

        log.warn("Validation error: {}", errors);
        return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }

    /**
     * Gère les exceptions d'authentification - Mauvais identifiants
     */
    @ExceptionHandler(BadCredentialsException.class)
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    public ResponseEntity<Map<String, Object>> handleBadCredentialsException(
            BadCredentialsException ex,
            WebRequest request
    ) {
        Map<String, Object> response = new HashMap<>();
        response.put("timestamp", LocalDateTime.now());
        response.put("status", HttpStatus.UNAUTHORIZED.value());
        response.put("error", "Authentification Échouée");
        response.put("message", "Email ou mot de passe incorrect");
        response.put("path", request.getDescription(false).replace("uri=", ""));

        log.warn("Authentication failed: {}", ex.getMessage());
        return new ResponseEntity<>(response, HttpStatus.UNAUTHORIZED);
    }

    /**
     * Gère l'utilisateur non trouvé
     */
    @ExceptionHandler(UsernameNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ResponseEntity<Map<String, Object>> handleUsernameNotFoundException(
            UsernameNotFoundException ex,
            WebRequest request
    ) {
        Map<String, Object> response = new HashMap<>();
        response.put("timestamp", LocalDateTime.now());
        response.put("status", HttpStatus.NOT_FOUND.value());
        response.put("error", "Utilisateur Non Trouvé");
        response.put("message", ex.getMessage());
        response.put("path", request.getDescription(false).replace("uri=", ""));

        log.warn("User not found: {}", ex.getMessage());
        return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
    }

    /**
     * Gère les compte désactivés
     */
    @ExceptionHandler(DisabledException.class)
    @ResponseStatus(HttpStatus.FORBIDDEN)
    public ResponseEntity<Map<String, Object>> handleDisabledException(
            DisabledException ex,
            WebRequest request
    ) {
        Map<String, Object> response = new HashMap<>();
        response.put("timestamp", LocalDateTime.now());
        response.put("status", HttpStatus.FORBIDDEN.value());
        response.put("error", "Compte Désactivé");
        response.put("message", "Votre compte a été désactivé. Contactez l'administrateur.");
        response.put("path", request.getDescription(false).replace("uri=", ""));

        log.warn("Disabled account access attempt");
        return new ResponseEntity<>(response, HttpStatus.FORBIDDEN);
    }

    /**
     * Gère les compte verrouillés
     */
    @ExceptionHandler(LockedException.class)
    @ResponseStatus(HttpStatus.FORBIDDEN)
    public ResponseEntity<Map<String, Object>> handleLockedException(
            LockedException ex,
            WebRequest request
    ) {
        Map<String, Object> response = new HashMap<>();
        response.put("timestamp", LocalDateTime.now());
        response.put("status", HttpStatus.FORBIDDEN.value());
        response.put("error", "Compte Verrouillé");
        response.put("message", "Votre compte a été verrouillé suite à plusieurs tentatives échouées.");
        response.put("path", request.getDescription(false).replace("uri=", ""));

        log.warn("Locked account access attempt");
        return new ResponseEntity<>(response, HttpStatus.FORBIDDEN);
    }

    /**
     * Gère l'accès refusé (autorisation insuffisante)
     */
    @ExceptionHandler(AccessDeniedException.class)
    @ResponseStatus(HttpStatus.FORBIDDEN)
    public ResponseEntity<Map<String, Object>> handleAccessDeniedException(
            AccessDeniedException ex,
            WebRequest request
    ) {
        Map<String, Object> response = new HashMap<>();
        response.put("timestamp", LocalDateTime.now());
        response.put("status", HttpStatus.FORBIDDEN.value());
        response.put("error", "Accès Refusé");
        response.put("message", "Vous n'avez pas les permissions pour accéder à cette ressource");
        response.put("path", request.getDescription(false).replace("uri=", ""));

        log.warn("Access denied: {}", ex.getMessage());
        return new ResponseEntity<>(response, HttpStatus.FORBIDDEN);
    }

    /**
     * Gère les autres exceptions d'authentification
     */
    @ExceptionHandler(AuthenticationException.class)
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    public ResponseEntity<Map<String, Object>> handleAuthenticationException(
            AuthenticationException ex,
            WebRequest request
    ) {
        Map<String, Object> response = new HashMap<>();
        response.put("timestamp", LocalDateTime.now());
        response.put("status", HttpStatus.UNAUTHORIZED.value());
        response.put("error", "Erreur d'Authentification");
        response.put("message", "Authentification échouée: " + ex.getMessage());
        response.put("path", request.getDescription(false).replace("uri=", ""));

        log.warn("Authentication error: {}", ex.getMessage());
        return new ResponseEntity<>(response, HttpStatus.UNAUTHORIZED);
    }

    /**
     * Gère les RuntimeException métier
     */
    @ExceptionHandler(RuntimeException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ResponseEntity<Map<String, Object>> handleRuntimeException(
            RuntimeException ex,
            WebRequest request
    ) {
        HttpStatus status = HttpStatus.BAD_REQUEST;
        String error = "Erreur Métier";

        if (ex.getMessage() != null) {
            if (ex.getMessage().contains("non trouvé")) {
                status = HttpStatus.NOT_FOUND;
                error = "Ressource Non Trouvée";
            } else if (ex.getMessage().contains("existe déjà")) {
                status = HttpStatus.CONFLICT;
                error = "Ressource Existante";
            } else if (ex.getMessage().contains("Accès refusé")) {
                status = HttpStatus.FORBIDDEN;
                error = "Accès Refusé";
            }
        }

        Map<String, Object> response = new HashMap<>();
        response.put("timestamp", LocalDateTime.now());
        response.put("status", status.value());
        response.put("error", error);
        response.put("message", ex.getMessage());
        response.put("path", request.getDescription(false).replace("uri=", ""));

        log.error("Runtime error: {}", ex.getMessage(), ex);
        return new ResponseEntity<>(response, status);
    }

    /**
     * Gère les exceptions non gérées
     */
    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ResponseEntity<Map<String, Object>> handleGlobalException(
            Exception ex,
            WebRequest request
    ) {
        Map<String, Object> response = new HashMap<>();
        response.put("timestamp", LocalDateTime.now());
        response.put("status", HttpStatus.INTERNAL_SERVER_ERROR.value());
        response.put("error", "Erreur Interne");
        response.put("message", "Une erreur inattendue s'est produite. Veuillez réessayer plus tard.");
        response.put("path", request.getDescription(false).replace("uri=", ""));

        log.error("Unexpected error: {}", ex.getMessage(), ex);
        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    /**
     * DTO: ErrorResponse
     * Réponse d'erreur standardisée
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ErrorResponse {
        private LocalDateTime timestamp;
        private int status;
        private String error;
        private String message;
        private String path;
        private Map<String, String> details;
    }
}

