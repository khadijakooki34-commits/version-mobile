package ma.safar.morocco.user.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UtilisateurDTO {
    private Long id;
    private String nom;
    private String email;
    private String motDePasse; // Uniquement pour la création
    private String telephone;
    private String langue;
    private String role;
    private Boolean actif;
    private Boolean compteBloquer;
    private LocalDateTime dateInscription;
    private String provider;
    private String photoUrl;
    private String description;
}