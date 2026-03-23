package ma.safar.morocco.itinerary.dto;

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
public class UpdateItineraireDTO {

    @Size(min = 3, max = 200, message = "Le nom doit contenir entre 3 et 200 caractères")
    private String nom;

    private List<Long> destinationIds;
}