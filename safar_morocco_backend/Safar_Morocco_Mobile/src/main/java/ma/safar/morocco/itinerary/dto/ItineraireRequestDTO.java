package ma.safar.morocco.itinerary.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ItineraireRequestDTO {

    @NotBlank(message = "Le nom de l'itinéraire est obligatoire")
    @Size(min = 3, max = 200, message = "Le nom doit contenir entre 3 et 200 caractères")
    private String nom;

    private String dureeEstimee; // Optionnel, sera calculé automatiquement

    @NotEmpty(message = "L'itinéraire doit contenir au moins une destination")
    private List<Long> destinationIds;

    @Builder.Default
    private Boolean optimiser = false; // Si true, optimise automatiquement l'itinéraire
}