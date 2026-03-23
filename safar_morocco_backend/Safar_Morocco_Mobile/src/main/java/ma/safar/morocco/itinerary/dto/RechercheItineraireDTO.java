package ma.safar.morocco.itinerary.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RechercheItineraireDTO {

    private String nom; // Recherche partielle
    private List<Long> destinationIds; // Destinations souhaitées
    private Integer nombreDestinationsMin; // Filtres
    private Integer nombreDestinationsMax;
    private Boolean optimise; // Seulement les optimisés
}