package ma.safar.morocco.admin.controller;

import lombok.RequiredArgsConstructor;
import ma.safar.morocco.destination.repository.DestinationRepository;
import ma.safar.morocco.destination.service.DestinationService;
import ma.safar.morocco.event.repository.EvenementCulturelRepository;
import ma.safar.morocco.review.repository.AvisRepository;
import ma.safar.morocco.user.dto.UtilisateurDTO;
import ma.safar.morocco.user.repository.UtilisateurRepository;
import ma.safar.morocco.user.service.UtilisateurService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * AdminController
 * Endpoints for admin operations including statistics
 */
@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminController {

    private final UtilisateurRepository utilisateurRepository;
    private final UtilisateurService utilisateurService;
    private final DestinationRepository destinationRepository;
    private final DestinationService destinationService;
    private final AvisRepository avisRepository;
    private final EvenementCulturelRepository evenementRepository;

    /**
     * GET /api/admin/statistics
     * Get comprehensive statistics for admin dashboard
     */
    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getStatistics() {
        Map<String, Object> stats = new HashMap<>();

        // Total counts
        long totalUsers = utilisateurRepository.count();
        long totalDestinations = destinationRepository.count();
        long totalReviews = avisRepository.count();
        long totalEvents = evenementRepository.count();

        // User statistics
        long activeUsers = utilisateurRepository.countActiveUsers();
        long blockedUsers = utilisateurRepository.findBlockedUsers().size();

        // Users by role
        Map<String, Integer> usersByRole = new HashMap<>();
        usersByRole.put("USER", (int) utilisateurRepository.countByRole("USER"));
        usersByRole.put("ADMIN", (int) utilisateurRepository.countByRole("ADMIN"));

        // Destinations by category
        Map<String, Integer> destinationsByCategory = destinationRepository.findAll()
                .stream()
                .collect(Collectors.groupingBy(
                        destination -> destination.getCategorie() != null ? destination.getCategorie() : "Uncategorized",
                        Collectors.collectingAndThen(Collectors.counting(), Long::intValue)
                ));

        // Average rating (from all reviews)
        double averageRating = 0.0;
        var allAvis = avisRepository.findAll();
        if (!allAvis.isEmpty()) {
            averageRating = allAvis.stream()
                    .mapToInt(avis -> avis.getNote() != null ? avis.getNote() : 0)
                    .average()
                    .orElse(0.0);
        }

        // Build response
        stats.put("totalUsers", totalUsers);
        stats.put("totalDestinations", totalDestinations);
        stats.put("totalReviews", totalReviews);
        stats.put("totalEvents", totalEvents);
        stats.put("averageRating", averageRating);
        stats.put("activeUsers", activeUsers);
        stats.put("blockedUsers", blockedUsers);
        stats.put("destinationsByCategory", destinationsByCategory);
        stats.put("usersByRole", usersByRole);
        stats.put("generatedAt", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));

        return ResponseEntity.ok(stats);
    }

    /**
     * GET /api/admin/users
     * Get paginated list of all users (admin only)
     */
    @GetMapping("/users")
    public ResponseEntity<Map<String, Object>> getUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        List<UtilisateurDTO> allUsers = utilisateurService.getAllUsers();
        
        // Manual pagination
        int start = page * size;
        int end = Math.min(start + size, allUsers.size());
        List<UtilisateurDTO> pageContent = start < allUsers.size() 
            ? allUsers.subList(start, end) 
            : List.of();
        
        Map<String, Object> response = new HashMap<>();
        response.put("content", pageContent);
        response.put("totalElements", allUsers.size());
        response.put("totalPages", (int) Math.ceil((double) allUsers.size() / size));
        response.put("size", size);
        response.put("number", page);
        response.put("numberOfElements", pageContent.size());
        response.put("first", page == 0);
        response.put("last", end >= allUsers.size());
        
        return ResponseEntity.ok(response);
    }

    /**
     * PUT /api/admin/users/block/{id}
     * Block a user (admin only)
     */
    @PutMapping("/users/block/{id}")
    public ResponseEntity<Map<String, String>> blockUser(@PathVariable Long id) {
        utilisateurService.blockUser(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "User blocked successfully");
        return ResponseEntity.ok(response);
    }

    /**
     * PUT /api/admin/users/{id}/role
     * Change a user's role (admin only)
     */
    @PutMapping("/users/{id}/role")
    public ResponseEntity<Map<String, String>> changeUserRole(
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {
        String roleName = request.get("role");
        if (roleName == null || roleName.isBlank()) {
            throw new IllegalArgumentException("Role is required");
        }

        utilisateurService.changeUserRole(id, roleName);

        Map<String, String> response = new HashMap<>();
        response.put("message", "User role updated successfully");
        return ResponseEntity.ok(response);
    }

    /**
     * DELETE /api/admin/destinations/{id}
     * Delete a destination (admin only)
     */
    @DeleteMapping("/destinations/{id}")
    public ResponseEntity<Void> deleteDestination(@PathVariable Long id) {
        destinationService.delete(id);
        return ResponseEntity.noContent().build();
    }
}

