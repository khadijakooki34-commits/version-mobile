package ma.safar.morocco.event.controller;

import lombok.RequiredArgsConstructor;
import ma.safar.morocco.event.entity.EvenementCulturel;
import ma.safar.morocco.event.service.EvenementCulturelService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/evenements")
@RequiredArgsConstructor
public class EvenementCulturelController {
    
    private final EvenementCulturelService evenementService;
    
    /**
     * GET /api/evenements
     * Récupère tous les événements (publique)
     */
    @GetMapping
    public ResponseEntity<List<EvenementCulturel>> getAllEvenements() {
        List<EvenementCulturel> evenements = evenementService.findAll();
        return ResponseEntity.ok(evenements);
    }
    
    /**
     * GET /api/evenements/{id}
     * Récupère un événement par ID (publique)
     */
    @GetMapping("/{id}")
    public ResponseEntity<EvenementCulturel> getEvenementById(@PathVariable Long id) {
        return evenementService.findById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    
    /**
     * GET /api/evenements/destination/{destinationId}
     * Récupère les événements d'une destination (publique)
     */
    @GetMapping("/destination/{destinationId}")
    public ResponseEntity<List<EvenementCulturel>> getEvenementsByDestination(@PathVariable Long destinationId) {
        List<EvenementCulturel> evenements = evenementService.findByDestinationId(destinationId);
        return ResponseEntity.ok(evenements);
    }
    
    /**
     * GET /api/evenements/upcoming
     * Récupère les événements à venir (publique)
     */
    @GetMapping("/upcoming")
    public ResponseEntity<List<EvenementCulturel>> getUpcomingEvenements() {
        List<EvenementCulturel> evenements = evenementService.findUpcoming();
        return ResponseEntity.ok(evenements);
    }
    
    /**
     * GET /api/evenements/ongoing
     * Récupère les événements en cours (publique)
     */
    @GetMapping("/ongoing")
    public ResponseEntity<List<EvenementCulturel>> getOngoingEvenements() {
        List<EvenementCulturel> evenements = evenementService.findOngoing();
        return ResponseEntity.ok(evenements);
    }
    
    /**
     * GET /api/evenements/past
     * Récupère les événements passés (publique)
     */
    @GetMapping("/past")
    public ResponseEntity<List<EvenementCulturel>> getPastEvenements() {
        List<EvenementCulturel> evenements = evenementService.findPast();
        return ResponseEntity.ok(evenements);
    }
    
    /**
     * GET /api/evenements/type/{type}
     * Récupère les événements par type (publique)
     */
    @GetMapping("/type/{type}")
    public ResponseEntity<List<EvenementCulturel>> getEvenementsByType(@PathVariable String type) {
        List<EvenementCulturel> evenements = evenementService.findByType(type);
        return ResponseEntity.ok(evenements);
    }
    
    /**
     * GET /api/evenements/lieu/{lieu}
     * Récupère les événements par lieu (publique)
     */
    @GetMapping("/lieu/{lieu}")
    public ResponseEntity<List<EvenementCulturel>> getEvenementsByLieu(@PathVariable String lieu) {
        List<EvenementCulturel> evenements = evenementService.findByLieu(lieu);
        return ResponseEntity.ok(evenements);
    }
    
    /**
     * POST /api/evenements/destination/{destinationId}
     * Crée un nouvel événement (admin seulement)
     */
    @PostMapping("/destination/{destinationId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EvenementCulturel> createEvenement(
            @PathVariable Long destinationId,
            @RequestBody EvenementCulturel evenement) {
        EvenementCulturel created = evenementService.create(destinationId, evenement);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
    
    /**
     * PUT /api/evenements/{id}
     * Met à jour un événement (admin seulement)
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EvenementCulturel> updateEvenement(
            @PathVariable Long id,
            @RequestBody EvenementCulturel evenement) {
        EvenementCulturel updated = evenementService.update(id, evenement);
        return ResponseEntity.ok(updated);
    }
    
    /**
     * DELETE /api/evenements/{id}
     * Supprime un événement (admin seulement)
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteEvenement(@PathVariable Long id) {
        evenementService.delete(id);
        return ResponseEntity.noContent().build();
    }
    
    /**
     * GET /api/evenements/destination/{destinationId}/count
     * Compte les événements d'une destination (publique)
     */
    @GetMapping("/destination/{destinationId}/count")
    public ResponseEntity<Long> countEvenementsByDestination(@PathVariable Long destinationId) {
        long count = evenementService.countByDestinationId(destinationId);
        return ResponseEntity.ok(count);
    }
}
