package ma.safar.morocco.media.controller;

import lombok.RequiredArgsConstructor;
import ma.safar.morocco.media.entity.Media;
import ma.safar.morocco.media.service.MediaService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/media")
@RequiredArgsConstructor
public class MediaController {
    
    private final MediaService mediaService;
    
    /**
     * GET /api/media
     * Récupère tous les médias (publique)
     */
    @GetMapping
    public ResponseEntity<List<Media>> getAllMedia() {
        List<Media> media = mediaService.findAll();
        return ResponseEntity.ok(media);
    }
    
    /**
     * GET /api/media/{id}
     * Récupère un média par ID (publique)
     */
    @GetMapping("/{id}")
    public ResponseEntity<Media> getMediaById(@PathVariable Long id) {
        return mediaService.findById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    
    /**
     * GET /api/media/destination/{destinationId}
     * Récupère tous les médias d'une destination (publique)
     */
    @GetMapping("/destination/{destinationId}")
    public ResponseEntity<List<Media>> getMediaByDestination(@PathVariable Long destinationId) {
        List<Media> media = mediaService.findByDestinationId(destinationId);
        return ResponseEntity.ok(media);
    }
    
    /**
     * GET /api/media/type/{type}
     * Récupère les médias par type (publique)
     */
    @GetMapping("/type/{type}")
    public ResponseEntity<List<Media>> getMediaByType(@PathVariable String type) {
        List<Media> media = mediaService.findByType(type);
        return ResponseEntity.ok(media);
    }
    
    /**
     * POST /api/media/destination/{destinationId}
     * Crée un nouveau média (admin seulement)
     */
    @PostMapping("/destination/{destinationId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Media> createMedia(
            @PathVariable Long destinationId,
            @RequestBody Media media) {
        Media created = mediaService.create(destinationId, media);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
    
    /**
     * POST /api/media/upload/destination/{destinationId}
     * Upload un fichier média (admin seulement)
     */
    @PostMapping("/upload/destination/{destinationId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Media> uploadMedia(
            @PathVariable Long destinationId,
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "description", required = false) String description) throws IOException {
        
        Media uploaded = mediaService.uploadMedia(destinationId, file, description);
        return ResponseEntity.status(HttpStatus.CREATED).body(uploaded);
    }
    
    /**
     * PUT /api/media/{id}
     * Met à jour un média (admin seulement)
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Media> updateMedia(
            @PathVariable Long id,
            @RequestBody Media media) {
        Media updated = mediaService.update(id, media);
        return ResponseEntity.ok(updated);
    }
    
    /**
     * DELETE /api/media/{id}
     * Supprime un média (admin seulement)
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteMedia(@PathVariable Long id) {
        mediaService.delete(id);
        return ResponseEntity.noContent().build();
    }
    
    /**
     * GET /api/media/destination/{destinationId}/count
     * Compte les médias d'une destination (publique)
     */
    @GetMapping("/destination/{destinationId}/count")
    public ResponseEntity<Long> countMediaByDestination(@PathVariable Long destinationId) {
        long count = mediaService.countByDestinationId(destinationId);
        return ResponseEntity.ok(count);
    }
}
