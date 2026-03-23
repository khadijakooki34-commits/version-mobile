package ma.safar.morocco.itinerary.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ItineraireDetailDTO {

    private Long id;
    private String nom;
    private String dureeEstimee;
    private LocalDateTime dateCreation;
    private LocalDateTime dateModification;
    private Double distanceTotale;
    private Integer nombreDestinations;
    private Boolean estOptimise;

    private ProprietaireDTO proprietaire;
    private List<DestinationDTO> destinations;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProprietaireDTO {
        private Long id;
        private String nom;
        private String email;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DestinationDTO {
        private Long id;
        private String nom;
        private String type;
        private String categorie;
        private Double latitude;
        private Double longitude;
        private Integer ordre; // Position dans l'itinéraire
    }
}