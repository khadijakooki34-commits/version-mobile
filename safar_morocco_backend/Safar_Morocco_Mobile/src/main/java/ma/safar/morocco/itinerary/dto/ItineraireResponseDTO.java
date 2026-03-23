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
public class ItineraireResponseDTO {

    private Long id;
    private String nom;
    private String dureeEstimee;
    private LocalDateTime dateCreation;
    private LocalDateTime dateModification;
    private Double distanceTotale;
    private Integer nombreDestinations;
    private Boolean estOptimise;
    private List<String> destinations; // Noms des destinations
    private String message; // Message de succès
}