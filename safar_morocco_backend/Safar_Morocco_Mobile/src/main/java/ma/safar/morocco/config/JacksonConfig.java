package ma.safar.morocco.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Configuration: JacksonConfig
 * Configuration de Jackson ObjectMapper pour la sérialisation JSON
 */
@Configuration
public class JacksonConfig {

    /**
     * Crée et configure un bean ObjectMapper pour la sérialisation/désérialisation JSON
     */
    @Bean
    public ObjectMapper objectMapper() {
        return new ObjectMapper();
    }
}
