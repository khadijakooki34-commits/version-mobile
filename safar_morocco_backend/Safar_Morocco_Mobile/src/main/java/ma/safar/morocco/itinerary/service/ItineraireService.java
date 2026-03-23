package ma.safar.morocco.itinerary.service;

import ma.safar.morocco.itinerary.dto.*;

import java.util.List;

/**
 * Interface du service Itineraire
 * @author Khadija El Achhab
 */
public interface ItineraireService {

    /**
     * Crée un nouvel itinéraire
     */
    ItineraireResponseDTO creerItineraire(ItineraireRequestDTO request, Long utilisateurId);

    /**
     * Récupère tous les itinéraires d'un utilisateur
     */
    List<ItineraireResponseDTO> getItinerairesUtilisateur(Long utilisateurId);

    /**
     * Récupère un itinéraire par son ID avec tous les détails
     */
    ItineraireDetailDTO getItineraireById(Long id, Long utilisateurId);

    /**
     * Met à jour un itinéraire
     */
    ItineraireResponseDTO updateItineraire(Long id, UpdateItineraireDTO request, Long utilisateurId);

    /**
     * Supprime un itinéraire
     */
    void supprimerItineraire(Long id, Long utilisateurId);

    /**
     * Optimise un itinéraire existant
     */
    ItineraireResponseDTO optimiserItineraire(Long id, Long utilisateurId);

    /**
     * Ajoute une destination à un itinéraire
     */
    ItineraireResponseDTO ajouterDestination(Long id, Long destinationId, Long utilisateurId);

    /**
     * Supprime une destination d'un itinéraire
     */
    ItineraireResponseDTO supprimerDestination(Long id, Long destinationId, Long utilisateurId);

    /**
     * Recherche d'itinéraires selon des critères
     */
    List<ItineraireResponseDTO> rechercherItineraires(RechercheItineraireDTO request, Long utilisateurId);
}