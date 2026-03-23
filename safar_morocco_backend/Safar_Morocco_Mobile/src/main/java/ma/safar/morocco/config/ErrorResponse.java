package ma.safar.morocco.config;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
class ErrorResponse {
    private LocalDateTime timestamp;
    private int status;
    private String error;
    private String message;
}