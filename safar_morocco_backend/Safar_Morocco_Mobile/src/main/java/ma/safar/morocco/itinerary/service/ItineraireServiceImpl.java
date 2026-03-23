package ma.safar.morocco.itinerary.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.safar.morocco.destination.entity.Destination;
import ma.safar.morocco.destination.repository.DestinationRepository;
import ma.safar.morocco.itinerary.dto.*;
import ma.safar.morocco.itinerary.entity.Itineraire;
import ma.safar.morocco.itinerary.repository.ItineraireRepository;
import ma.safar.morocco.user.entity.Utilisateur;
import ma.safar.morocco.user.repository.UtilisateurRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Service de gestion des itinéraires
 * 
 * @author Khadija El Achhab
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class ItineraireServiceImpl implements ItineraireService {

    private final ItineraireRepository itineraireRepository;
    private final UtilisateurRepository utilisateurRepository;
    private final DestinationRepository destinationRepository;

    // ============================================
    // CRUD OPERATIONS
    // ============================================

    @Override
    public ItineraireResponseDTO creerItineraire(ItineraireRequestDTO request, Long utilisateurId) {
        log.info("Création d'un nouvel itinéraire: {} pour l'utilisateur ID={}", request.getNom(), utilisateurId);

        // Récupérer l'utilisateur
        Utilisateur proprietaire = utilisateurRepository.findById(utilisateurId)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        // Vérifier si un itinéraire avec ce nom existe déjà
        if (itineraireRepository.existsByNomAndProprietaire_Id(request.getNom(), utilisateurId)) {
            throw new RuntimeException("Un itinéraire avec ce nom existe déjà");
        }

        // Récupérer les destinations
        List<Destination> destinations = destinationRepository.findAllById(request.getDestinationIds());

        if (destinations.size() != request.getDestinationIds().size()) {
            throw new RuntimeException("Certaines destinations n'existent pas");
        }

        // Créer l'itinéraire
        Itineraire itineraire = Itineraire.builder()
                .nom(request.getNom())
                .proprietaire(proprietaire)
                .destinations(destinations)
                .build();

        // Optimiser si demandé
        if (Boolean.TRUE.equals(request.getOptimiser())) {
            log.info("Optimisation de l'itinéraire demandée");
            itineraire.calculerItineraireOptimise();
        }

        // Sauvegarder
        Itineraire saved = itineraireRepository.save(itineraire);
        log.info("Itinéraire créé avec succès: ID={}", saved.getId());

        return mapToResponse(saved, "Itinéraire créé avec succès");
    }

    @Override
    @Transactional(readOnly = true)
    public List<ItineraireResponseDTO> getItinerairesUtilisateur(Long utilisateurId) {
        log.info("Récupération des itinéraires de l'utilisateur ID={}", utilisateurId);

        return itineraireRepository.findByProprietaire_Id(utilisateurId)
                .stream()
                .map(i -> mapToResponse(i, null))
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public ItineraireDetailDTO getItineraireById(Long id, Long utilisateurId) {
        log.info("Récupération de l'itinéraire ID={}", id);

        Itineraire itineraire = itineraireRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Itinéraire non trouvé"));

        // Vérifier que l'utilisateur est le propriétaire
        if (!itineraire.getProprietaire().getId().equals(utilisateurId)) {
            throw new RuntimeException("Accès non autorisé à cet itinéraire");
        }

        return mapToDetailDTO(itineraire);
    }

    @Override
    public ItineraireResponseDTO updateItineraire(Long id, UpdateItineraireDTO request, Long utilisateurId) {
        log.info("Mise à jour de l'itinéraire ID={}", id);

        Itineraire itineraire = itineraireRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Itinéraire non trouvé"));

        // Vérifier que l'utilisateur est le propriétaire
        if (!itineraire.getProprietaire().getId().equals(utilisateurId)) {
            throw new RuntimeException("Accès non autorisé à cet itinéraire");
        }

        // Mettre à jour le nom si fourni
        if (request.getNom() != null && !request.getNom().isBlank()) {
            itineraire.setNom(request.getNom());
        }

        // Mettre à jour les destinations si fournies
        if (request.getDestinationIds() != null && !request.getDestinationIds().isEmpty()) {
            List<Destination> destinations = destinationRepository.findAllById(request.getDestinationIds());
            itineraire.setDestinations(destinations);
        }

        Itineraire updated = itineraireRepository.save(itineraire);
        log.info("Itinéraire mis à jour avec succès");

        return mapToResponse(updated, "Itinéraire mis à jour avec succès");
    }

    @Override
    public void supprimerItineraire(Long id, Long utilisateurId) {
        log.info("Suppression de l'itinéraire ID={}", id);

        Itineraire itineraire = itineraireRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Itinéraire non trouvé"));

        // Vérifier que l'utilisateur est le propriétaire
        if (!itineraire.getProprietaire().getId().equals(utilisateurId)) {
            throw new RuntimeException("Accès non autorisé à cet itinéraire");
        }

        itineraireRepository.delete(itineraire);
        log.info("Itinéraire supprimé avec succès");
    }

    // ============================================
    // FONCTIONNALITÉS AVANCÉES
    // ============================================

    @Override
    public ItineraireResponseDTO optimiserItineraire(Long id, Long utilisateurId) {
        log.info("Optimisation de l'itinéraire ID={}", id);

        Itineraire itineraire = itineraireRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Itinéraire non trouvé"));

        // Vérifier que l'utilisateur est le propriétaire
        if (!itineraire.getProprietaire().getId().equals(utilisateurId)) {
            throw new RuntimeException("Accès non autorisé");
        }

        itineraire.calculerItineraireOptimise();
        Itineraire optimized = itineraireRepository.save(itineraire);

        log.info("Itinéraire optimisé avec succès");
        return mapToResponse(optimized, "Itinéraire optimisé avec succès");
    }

    @Override
    public ItineraireResponseDTO ajouterDestination(Long id, Long destinationId, Long utilisateurId) {
        log.info("Ajout de la destination {} à l'itinéraire {}", destinationId, id);

        Itineraire itineraire = itineraireRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Itinéraire non trouvé"));

        Destination destination = destinationRepository.findById(destinationId)
                .orElseThrow(() -> new RuntimeException("Destination non trouvée"));

        // Vérifier que l'utilisateur est le propriétaire
        if (!itineraire.getProprietaire().getId().equals(utilisateurId)) {
            throw new RuntimeException("Accès non autorisé");
        }

        itineraire.ajouterDestination(destination);
        Itineraire updated = itineraireRepository.save(itineraire);

        return mapToResponse(updated, "Destination ajoutée avec succès");
    }

    @Override
    public ItineraireResponseDTO supprimerDestination(Long id, Long destinationId, Long utilisateurId) {
        log.info("Suppression de la destination {} de l'itinéraire {}", destinationId, id);

        Itineraire itineraire = itineraireRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Itinéraire non trouvé"));

        Destination destination = destinationRepository.findById(destinationId)
                .orElseThrow(() -> new RuntimeException("Destination non trouvée"));

        // Vérifier que l'utilisateur est le propriétaire
        if (!itineraire.getProprietaire().getId().equals(utilisateurId)) {
            throw new RuntimeException("Accès non autorisé");
        }

        itineraire.supprimerDestination(destination);
        Itineraire updated = itineraireRepository.save(itineraire);

        return mapToResponse(updated, "Destination supprimée avec succès");
    }

    @Override
    @Transactional(readOnly = true)
    public List<ItineraireResponseDTO> rechercherItineraires(RechercheItineraireDTO request, Long utilisateurId) {
        log.info("Recherche d'itinéraires avec critères");

        List<Itineraire> resultats;

        // Recherche par nom
        if (request.getNom() != null && !request.getNom().isBlank()) {
            resultats = itineraireRepository.rechercherParNom(request.getNom(), utilisateurId);
        } else {
            resultats = itineraireRepository.findByProprietaire_Id(utilisateurId);
        }

        // Filtrer par nombre de destinations
        if (request.getNombreDestinationsMin() != null && request.getNombreDestinationsMax() != null) {
            resultats = itineraireRepository.findWithDestinationsBetween(
                    utilisateurId,
                    request.getNombreDestinationsMin(),
                    request.getNombreDestinationsMax());
        } else if (request.getNombreDestinationsMin() != null) {
            resultats = itineraireRepository.findWithMinDestinations(
                    utilisateurId,
                    request.getNombreDestinationsMin());
        }

        // Filtrer par destinations
        if (request.getDestinationIds() != null && !request.getDestinationIds().isEmpty()) {
            resultats = itineraireRepository.findWithDestinations(
                    request.getDestinationIds(),
                    1L,
                    utilisateurId);
        }

        // Filtrer par optimisé
        if (request.getOptimise() != null) {
            resultats = resultats.stream()
                    .filter(i -> i.getEstOptimise().equals(request.getOptimise()))
                    .collect(Collectors.toList());
        }

        return resultats.stream()
                .map(i -> mapToResponse(i, null))
                .collect(Collectors.toList());
    }

    // ============================================
    // MAPPING
    // ============================================

    private ItineraireResponseDTO mapToResponse(Itineraire itineraire, String message) {
        return ItineraireResponseDTO.builder()
                .id(itineraire.getId())
                .nom(itineraire.getNom())
                .dureeEstimee(itineraire.getDureeEstimee())
                .dateCreation(itineraire.getDateCreation())
                .dateModification(itineraire.getDateModification())
                .distanceTotale(itineraire.getDistanceTotale())
                .nombreDestinations(itineraire.getNombreDestinations())
                .estOptimise(itineraire.getEstOptimise())
                .destinations(
                        itineraire.getDestinations().stream()
                                .map(Destination::getNom)
                                .collect(Collectors.toList()))
                .message(message)
                .build();
    }

    private ItineraireDetailDTO mapToDetailDTO(Itineraire itineraire) {
        return ItineraireDetailDTO.builder()
                .id(itineraire.getId())
                .nom(itineraire.getNom())
                .dureeEstimee(itineraire.getDureeEstimee())
                .dateCreation(itineraire.getDateCreation())
                .dateModification(itineraire.getDateModification())
                .distanceTotale(itineraire.getDistanceTotale())
                .nombreDestinations(itineraire.getNombreDestinations())
                .estOptimise(itineraire.getEstOptimise())
                .proprietaire(ItineraireDetailDTO.ProprietaireDTO.builder()
                        .id(itineraire.getProprietaire().getId())
                        .nom(itineraire.getProprietaire().getNom())
                        .email(itineraire.getProprietaire().getEmail())
                        .build())
                .destinations(
                        itineraire.getDestinations().stream()
                                .map(dest -> ItineraireDetailDTO.DestinationDTO.builder()
                                        .id(dest.getId())
                                        .nom(dest.getNom())
                                        .type(dest.getType())
                                        .categorie(dest.getCategorie())
                                        .latitude(dest.getLatitude())
                                        .longitude(dest.getLongitude())
                                        .build())
                                .collect(Collectors.toList()))
                .build();
    }
}