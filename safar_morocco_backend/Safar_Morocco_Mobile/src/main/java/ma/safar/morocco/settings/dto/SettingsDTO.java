package ma.safar.morocco.settings.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class SettingsDTO {
    private String language;
    private String theme;
    private boolean notifyEmail;
    private boolean notifySms;
    private boolean privacyProfilePublic;
    private boolean privacyShowEmail;
}
