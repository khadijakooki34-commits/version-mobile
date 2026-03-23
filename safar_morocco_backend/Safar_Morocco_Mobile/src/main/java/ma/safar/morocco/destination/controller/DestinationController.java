package ma.safar.morocco.destination.controller;

import lombok.RequiredArgsConstructor;
import ma.safar.morocco.destination.entity.Destination;
import ma.safar.morocco.destination.service.DestinationService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/destinations")
@RequiredArgsConstructor
public class DestinationController {

    private final DestinationService destinationService;

    /**
     * GET /api/destinations
     * Récupère toutes les destinations (publique)
     */
    @GetMapping
    public ResponseEntity<List<Destination>> getAllDestinations() {
        List<Destination> destinations = destinationService.findAll();
        return ResponseEntity.ok(destinations);
    }

    /**
     * GET /api/destinations/{id}
     * Récupère une destination par ID (publique)
     */
    @GetMapping("/{id}")
    public ResponseEntity<Destination> getDestinationById(@PathVariable Long id) {
        destinationService.incrementViewCount(id);
        return destinationService.findById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    /**
     * GET /api/destinations/category/{category}
     * Récupère les destinations par catégorie (publique)
     */
    @GetMapping("/category/{category}")
    public ResponseEntity<List<Destination>> getDestinationsByCategory(@PathVariable String category) {
        List<Destination> destinations = destinationService.findByCategorie(category);
        return ResponseEntity.ok(destinations);
    }

    /**
     * POST /api/destinations
     * Crée une nouvelle destination (admin seulement)
     */
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Destination> createDestination(@RequestBody Destination destination) {
        Destination created = destinationService.create(destination);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    /**
     * PUT /api/destinations/{id}
     * Met à jour une destination (admin seulement)
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Destination> updateDestination(
            @PathVariable Long id,
            @RequestBody Destination destination) {
        Destination updated = destinationService.update(id, destination);
        return ResponseEntity.ok(updated);
    }

    /**
     * PUT /api/destinations/update-history
     * Met à jour toutes les destinations avec l'historique (admin seulement)
     */
    @PutMapping("/update-history")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> updateAllDestinationsWithHistory() {
        try {
            destinationService.updateAllDestinationsWithHistory();
            return ResponseEntity.ok(Map.of(
                "message", "Toutes les destinations ont été mises à jour avec l'historique",
                "timestamp", System.currentTimeMillis()
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of(
                    "error", "Erreur lors de la mise à jour de l'historique: " + e.getMessage(),
                    "timestamp", System.currentTimeMillis()
                ));
        }
    }

    /**
     * DELETE /api/destinations/{id}
     * Supprime une destination (admin seulement)
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteDestination(@PathVariable Long id) {
        destinationService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
