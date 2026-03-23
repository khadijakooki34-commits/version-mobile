package ma.safar.morocco.review.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.safar.morocco.destination.entity.Destination;
import ma.safar.morocco.destination.service.DestinationService;
import ma.safar.morocco.review.dto.CreateAvisRequest;
import ma.safar.morocco.review.entity.Avis;
import ma.safar.morocco.review.service.AvisService;
import ma.safar.morocco.user.service.UtilisateurService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/avis")
@RequiredArgsConstructor
public class AvisController {

    private final AvisService avisService;
    private final UtilisateurService utilisateurService;
    private final DestinationService destinationService;

    /**
     * GET /api/avis/destination/{destinationId}
     * Récupère tous les avis pour une destination (publique)
     */
    @GetMapping("/destination/{destinationId}")
    public ResponseEntity<List<Avis>> getAvisByDestination(@PathVariable Long destinationId) {
        List<Avis> avis = avisService.findByDestination(destinationId);
        return ResponseEntity.ok(avis);
    }

    /**
     * GET /api/avis/{id}
     * Récupère un avis par ID (publique)
     */
    @GetMapping("/{id}")
    public ResponseEntity<Avis> getAvisById(@PathVariable Long id) {
        return avisService.findById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    /**
     * POST /api/avis
     * Crée un nouvel avis (utilisateur authentifié)
     */
    @PostMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Avis> createAvis(@Valid @RequestBody CreateAvisRequest request) {
        Destination destination = destinationService.findById(request.getDestinationId())
                .orElseThrow(() -> new RuntimeException("Destination non trouvée"));
        int noteValue = request.getNote() != null ? request.getNote().intValue() : 5;
        Avis avis = Avis.builder()
                .commentaire(request.getCommentaire())
                .note(noteValue)
                .auteur(utilisateurService.getCurrentUser())
                .destination(destination)
                .build();
        Avis created = avisService.addAvis(avis);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    /**
     * PUT /api/avis/{id}
     * Met à jour un avis (propriétaire ou admin)
     */
    @PutMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Avis> updateAvis(
            @PathVariable Long id,
            @RequestBody Avis avis) {
        Avis updated = avisService.update(id, avis);
        return ResponseEntity.ok(updated);
    }

    /**
     * DELETE /api/avis/{id}
     * Supprime un avis (propriétaire ou admin)
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Void> deleteAvis(@PathVariable Long id) {
        avisService.deleteAvis(id);
        return ResponseEntity.noContent().build();
    }

    /**
     * GET /api/avis/destination/{destinationId}/average
     * Calcule la moyenne des notes (publique)
     */
    @GetMapping("/destination/{destinationId}/average")
    public ResponseEntity<Double> getAverageRating(@PathVariable Long destinationId) {
        double average = avisService.calculateAverageRating(destinationId);
        return ResponseEntity.ok(average);
    }

    /**
     * GET /api/avis/destination/{destinationId}/count
     * Compte les avis (publique)
     */
    @GetMapping("/destination/{destinationId}/count")
    public ResponseEntity<Long> countAvis(@PathVariable Long destinationId) {
        long count = avisService.countByDestination(destinationId);
        return ResponseEntity.ok(count);
    }

    /**
     * GET /api/avis/admin/pending
     * Récupère tous les avis en attente (admin seulement)
     */
    @GetMapping("/admin/pending")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Avis>> getPendingAvis() {
        List<Avis> pendingAvis = avisService.findByStatus("PENDING");
        return ResponseEntity.ok(pendingAvis);
    }

    /**
     * PUT /api/avis/admin/{id}/approve
     * Approuve un avis (admin seulement)
     */
    @PutMapping("/admin/{id}/approve")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Avis> approveAvis(@PathVariable Long id) {
        Avis approved = avisService.approveAvis(id);
        return ResponseEntity.ok(approved);
    }

    /**
     * DELETE /api/avis/admin/{id}
     * Supprime un avis (admin seulement)
     */
    @DeleteMapping("/admin/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteAvisAdmin(@PathVariable Long id) {
        avisService.deleteAvis(id);
        return ResponseEntity.noContent().build();
    }

    /**
     * GET /api/avis/admin/all
     * Récupère tous les avis (admin seulement)
     */
    @GetMapping("/admin/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Avis>> getAllAvis() {
        List<Avis> allAvis = avisService.findAll();
        return ResponseEntity.ok(allAvis);
    }
}
