package ma.safar.morocco.meteo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MeteoDTO {
    // Identifiants
    private Long id;
    private Long destinationId;
    private String destinationNom;

    // Températures
    private Double temperature;
    private Double temperatureMin;
    private Double temperatureMax;
    private Double temperatureRessentie;

    // Conditions
    private String conditions;
    private String description;
    private String iconeCode;
    private String iconeUrl;

    // Vent
    private Double vitesseVent;
    private Integer directionVent;
    private Double rafalesVent;

    // Atmosphère
    private Integer humidite;
    private Integer pressionAtmospherique;

    // Précipitations
    private Double precipitation1h;
    private Double precipitation3h;

    // Visibilité & Nuages
    private Integer visibilite;
    private Integer couvertureNuageuse;

    // Soleil
    private LocalDateTime heureLeverSoleil;
    private LocalDateTime heureCoucherSoleil;

    // Dates
    private LocalDateTime datePrevision;
    private LocalDateTime derniereMiseAJour;
}