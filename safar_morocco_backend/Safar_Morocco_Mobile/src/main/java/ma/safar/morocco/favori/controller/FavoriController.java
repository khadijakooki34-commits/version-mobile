package ma.safar.morocco.favori.controller;

import lombok.RequiredArgsConstructor;
import ma.safar.morocco.favori.entity.Favori;
import ma.safar.morocco.favori.service.FavoriService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/favoris")
@RequiredArgsConstructor
public class FavoriController {

    private final FavoriService favoriService;

    @PostMapping("/{destinationId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Favori> addFavori(@PathVariable Long destinationId) {
        return ResponseEntity.ok(favoriService.addFavori(destinationId));
    }

    @DeleteMapping("/{destinationId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Void> removeFavori(@PathVariable Long destinationId) {
        favoriService.removeFavori(destinationId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/my")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<Favori>> getMyFavoris() {
        return ResponseEntity.ok(favoriService.getMyFavoris());
    }

    @GetMapping("/check/{destinationId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Boolean> isFavori(@PathVariable Long destinationId) {
        return ResponseEntity.ok(favoriService.isFavori(destinationId));
    }
}
