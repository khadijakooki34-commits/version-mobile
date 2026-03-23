package ma.safar.morocco.itinerary.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.safar.morocco.itinerary.dto.*;
import ma.safar.morocco.itinerary.service.ItineraireService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controller REST pour les itinéraires
 * @author Khadija El Achhab
 */
@RestController
@RequestMapping("/api/itineraires")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*", maxAge = 3600)
public class ItineraireController {

    private final ItineraireService itineraireService;

    // ============================================
    // CRUD ENDPOINTS
    // ============================================

    /**
     * Créer un nouvel itinéraire
     * POST /api/itineraires/utilisateur/{utilisateurId}
     */
    @PostMapping("/utilisateur/{utilisateurId}")
    public ResponseEntity<ItineraireResponseDTO> creerItineraire(
            @Valid @RequestBody ItineraireRequestDTO request,
            @PathVariable Long utilisateurId) {

        log.info("Requête de création d'itinéraire: {} pour utilisateur ID={}",
                request.getNom(), utilisateurId);

        try {
            ItineraireResponseDTO response = itineraireService.creerItineraire(request, utilisateurId);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            log.error("Erreur lors de la création: {}", e.getMessage());
            throw new RuntimeException("Erreur lors de la création de l'itinéraire: " + e.getMessage());
        }
    }

    /**
     * Récupérer tous les itinéraires d'un utilisateur
     * GET /api/itineraires/utilisateur/{utilisateurId}
     */
    @GetMapping("/utilisateur/{utilisateurId}")
    public ResponseEntity<List<ItineraireResponseDTO>> getItinerairesUtilisateur(
            @PathVariable Long utilisateurId) {

        log.info("Récupération des itinéraires pour utilisateur ID={}", utilisateurId);

        List<ItineraireResponseDTO> itineraires = itineraireService.getItinerairesUtilisateur(utilisateurId);
        return ResponseEntity.ok(itineraires);
    }

    /**
     * Récupérer un itinéraire par son ID
     * GET /api/itineraires/{id}/utilisateur/{utilisateurId}
     */
    @GetMapping("/{id}/utilisateur/{utilisateurId}")
    public ResponseEntity<ItineraireDetailDTO> getItineraireById(
            @PathVariable Long id,
            @PathVariable Long utilisateurId) {

        log.info("Récupération de l'itinéraire ID={} pour utilisateur ID={}", id, utilisateurId);

        try {
            ItineraireDetailDTO itineraire = itineraireService.getItineraireById(id, utilisateurId);
            return ResponseEntity.ok(itineraire);
        } catch (Exception e) {
            log.error("Erreur: {}", e.getMessage());
            throw new RuntimeException("Itinéraire non trouvé ou accès non autorisé");
        }
    }

    /**
     * Mettre à jour un itinéraire
     * PUT /api/itineraires/{id}/utilisateur/{utilisateurId}
     */
    @PutMapping("/{id}/utilisateur/{utilisateurId}")
    public ResponseEntity<ItineraireResponseDTO> updateItineraire(
            @PathVariable Long id,
            @PathVariable Long utilisateurId,
            @Valid @RequestBody UpdateItineraireDTO request) {

        log.info("Mise à jour de l'itinéraire ID={}", id);

        try {
            ItineraireResponseDTO response = itineraireService.updateItineraire(id, request, utilisateurId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Erreur: {}", e.getMessage());
            throw new RuntimeException("Erreur lors de la mise à jour: " + e.getMessage());
        }
    }

    /**
     * Supprimer un itinéraire
     * DELETE /api/itineraires/{id}/utilisateur/{utilisateurId}
     */
    @DeleteMapping("/{id}/utilisateur/{utilisateurId}")
    public ResponseEntity<Void> supprimerItineraire(
            @PathVariable Long id,
            @PathVariable Long utilisateurId) {

        log.info("Suppression de l'itinéraire ID={}", id);

        try {
            itineraireService.supprimerItineraire(id, utilisateurId);
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            log.error("Erreur: {}", e.getMessage());
            throw new RuntimeException("Erreur lors de la suppression");
        }
    }

    // ============================================
    // FONCTIONNALITÉS AVANCÉES
    // ============================================

    /**
     * Optimiser un itinéraire
     * POST /api/itineraires/{id}/optimiser/utilisateur/{utilisateurId}
     */
    @PostMapping("/{id}/optimiser/utilisateur/{utilisateurId}")
    public ResponseEntity<ItineraireResponseDTO> optimiserItineraire(
            @PathVariable Long id,
            @PathVariable Long utilisateurId) {

        log.info("Optimisation de l'itinéraire ID={}", id);

        try {
            ItineraireResponseDTO response = itineraireService.optimiserItineraire(id, utilisateurId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Erreur: {}", e.getMessage());
            throw new RuntimeException("Erreur lors de l'optimisation");
        }
    }

    /**
     * Ajouter une destination à un itinéraire
     * POST /api/itineraires/{id}/destinations/{destinationId}/utilisateur/{utilisateurId}
     */
    @PostMapping("/{id}/destinations/{destinationId}/utilisateur/{utilisateurId}")
    public ResponseEntity<ItineraireResponseDTO> ajouterDestination(
            @PathVariable Long id,
            @PathVariable Long destinationId,
            @PathVariable Long utilisateurId) {

        log.info("Ajout de la destination {} à l'itinéraire {}", destinationId, id);

        try {
            ItineraireResponseDTO response = itineraireService.ajouterDestination(id, destinationId, utilisateurId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Erreur: {}", e.getMessage());
            throw new RuntimeException("Erreur lors de l'ajout de la destination");
        }
    }

    /**
     * Supprimer une destination d'un itinéraire
     * DELETE /api/itineraires/{id}/destinations/{destinationId}/utilisateur/{utilisateurId}
     */
    @DeleteMapping("/{id}/destinations/{destinationId}/utilisateur/{utilisateurId}")
    public ResponseEntity<ItineraireResponseDTO> supprimerDestination(
            @PathVariable Long id,
            @PathVariable Long destinationId,
            @PathVariable Long utilisateurId) {

        log.info("Suppression de la destination {} de l'itinéraire {}", destinationId, id);

        try {
            ItineraireResponseDTO response = itineraireService.supprimerDestination(id, destinationId, utilisateurId);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Erreur: {}", e.getMessage());
            throw new RuntimeException("Erreur lors de la suppression de la destination");
        }
    }

    /**
     * Rechercher des itinéraires
     * POST /api/itineraires/rechercher/utilisateur/{utilisateurId}
     */
    @PostMapping("/rechercher/utilisateur/{utilisateurId}")
    public ResponseEntity<List<ItineraireResponseDTO>> rechercherItineraires(
            @RequestBody RechercheItineraireDTO request,
            @PathVariable Long utilisateurId) {

        log.info("Recherche d'itinéraires pour utilisateur ID={}", utilisateurId);

        List<ItineraireResponseDTO> resultats = itineraireService.rechercherItineraires(request, utilisateurId);
        return ResponseEntity.ok(resultats);
    }

    // ============================================
    // GESTION DES ERREURS
    // ============================================

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<ErrorResponse> handleRuntimeException(RuntimeException e) {
        log.error("Erreur Runtime: {}", e.getMessage());

        ErrorResponse error = new ErrorResponse(
                HttpStatus.BAD_REQUEST.value(),
                e.getMessage(),
                System.currentTimeMillis()
        );

        return ResponseEntity.badRequest().body(error);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleException(Exception e) {
        log.error("Erreur inattendue: {}", e.getMessage());

        ErrorResponse error = new ErrorResponse(
                HttpStatus.INTERNAL_SERVER_ERROR.value(),
                "Une erreur inattendue s'est produite",
                System.currentTimeMillis()
        );

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }

    /**
     * DTO pour les réponses d'erreur
     */
    record ErrorResponse(int status, String message, long timestamp) {}
}