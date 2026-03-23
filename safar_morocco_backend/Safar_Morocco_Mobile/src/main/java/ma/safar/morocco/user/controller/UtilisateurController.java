package ma.safar.morocco.user.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.safar.morocco.user.dto.UtilisateurDTO;
import ma.safar.morocco.user.service.UtilisateurService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.List;

/**
 * Controller: UtilisateurController
 * Endpoints pour la gestion des utilisateurs
 * - Accès aux profils publics
 * - Gestion des profils utilisateurs
 * - Administration des utilisateurs (admin uniquement)
 */
@RestController
@RequestMapping("/api/utilisateurs")
@RequiredArgsConstructor
public class UtilisateurController {

    private final UtilisateurService utilisateurService;

    /**
     * GET /api/utilisateurs/profile
     * Récupère le profil de l'utilisateur actuel
     */
    @GetMapping("/profile")
    public ResponseEntity<UtilisateurDTO> getCurrentProfile() {
        return ResponseEntity.ok(utilisateurService.getCurrentUserProfile());
    }

    /**
     * GET /api/utilisateurs/{id}
     * Récupère un utilisateur par ID (admin uniquement)
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UtilisateurDTO> getUserById(@PathVariable Long id) {
        return ResponseEntity.ok(utilisateurService.getUserById(id));
    }

    /**
     * GET /api/utilisateurs/email/{email}
     * Récupère un utilisateur par email
     */
    @GetMapping("/email/{email}")
    public ResponseEntity<UtilisateurDTO> getUserByEmail(@PathVariable String email) {
        return ResponseEntity.ok(utilisateurService.getUserByEmail(email));
    }

    /**
     * GET /api/utilisateurs/all/list
     * Récupère tous les utilisateurs (admin uniquement)
     */
    @GetMapping("/all/list")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<UtilisateurDTO>> getAllUsers() {
        return ResponseEntity.ok(utilisateurService.getAllUsers());
    }

    /**
     * GET /api/utilisateurs/active/list
     * Récupère tous les utilisateurs actifs
     */
    @GetMapping("/active/list")
    public ResponseEntity<List<UtilisateurDTO>> getAllActiveUsers() {
        return ResponseEntity.ok(utilisateurService.getAllActiveUsers());
    }

    /**
     * GET /api/utilisateurs/blocked/list
     * Récupère tous les utilisateurs bloqués (admin uniquement)
     */
    @GetMapping("/blocked/list")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<UtilisateurDTO>> getBlockedUsers() {
        return ResponseEntity.ok(utilisateurService.getBlockedUsers());
    }

    /**
     * GET /api/utilisateurs/role/{role}
     * Récupère les utilisateurs par rôle (admin uniquement)
     */
    @GetMapping("/role/{role}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<UtilisateurDTO>> getUsersByRole(@PathVariable String role) {
        return ResponseEntity.ok(utilisateurService.getUsersByRole(role));
    }

    /**
     * POST /api/utilisateurs
     * Crée un nouvel utilisateur (admin uniquement)
     */
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UtilisateurDTO> createUser(@Valid @RequestBody UtilisateurDTO dto) {
        UtilisateurDTO createdUser = utilisateurService.createUser(dto);
        return ResponseEntity.status(201).body(createdUser);
    }

    /**
     * PUT /api/utilisateurs/profile
     * Met à jour le profil de l'utilisateur actuel
     */
    @PutMapping("/profile")
    public ResponseEntity<UtilisateurDTO> updateOwnProfile(@Valid @RequestBody UtilisateurDTO dto) {
        UtilisateurDTO updatedUser = utilisateurService.updateOwnProfile(dto);
        return ResponseEntity.ok(updatedUser);
    }

    /**
     * PUT /api/utilisateurs/{id}
     * Met à jour un utilisateur (admin uniquement)
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UtilisateurDTO> updateUser(
            @PathVariable Long id,
            @Valid @RequestBody UtilisateurDTO dto) {
        UtilisateurDTO updatedUser = utilisateurService.updateUser(id, dto);
        return ResponseEntity.ok(updatedUser);
    }

    /**
     * POST /api/utilisateurs/profile/photo
     * Upload une photo de profil
     */
    @PostMapping("/profile/photo")
    public ResponseEntity<Map<String, String>> uploadProfilePhoto(@RequestParam("file") MultipartFile file) {
        try {
            String photoUrl = utilisateurService.uploadProfileImage(file);
            Map<String, String> response = new HashMap<>();
            response.put("photoUrl", photoUrl);
            response.put("message", "Photo de profil mise à jour avec succès");
            return ResponseEntity.ok(response);
        } catch (IOException e) {
            throw new RuntimeException("Erreur lors de l'upload de l'image", e);
        }
    }

    /**
     * PUT /api/utilisateurs/{id}/photo
     * Met à jour la photo de profil (URL only - Admin)
     */
    @PutMapping("/{id}/photo")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, String>> updateProfilePhoto(
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {
        String photoUrl = request.get("photoUrl");
        utilisateurService.updateProfilePhoto(photoUrl);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Photo de profil mise à jour avec succès");
        return ResponseEntity.ok(response);
    }

    /**
     * DELETE /api/utilisateurs/{id}
     * Supprime un utilisateur (admin uniquement)
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, String>> deleteUser(@PathVariable Long id) {
        utilisateurService.deleteUser(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Utilisateur supprimé avec succès");
        return ResponseEntity.ok(response);
    }

    /**
     * POST /api/utilisateurs/{id}/block
     * Bloque un compte utilisateur (admin uniquement)
     */
    @PostMapping("/{id}/block")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, String>> blockUser(@PathVariable Long id) {
        utilisateurService.blockUser(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Utilisateur bloqué avec succès");
        return ResponseEntity.ok(response);
    }

    /**
     * POST /api/utilisateurs/{id}/unblock
     * Débloque un compte utilisateur (admin uniquement)
     */
    @PostMapping("/{id}/unblock")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, String>> unblockUser(@PathVariable Long id) {
        utilisateurService.unblockUser(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Utilisateur débloqué avec succès");
        return ResponseEntity.ok(response);
    }

    /**
     * POST /api/utilisateurs/{id}/deactivate
     * Désactive un compte utilisateur (admin uniquement)
     */
    @PostMapping("/{id}/deactivate")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, String>> deactivateUser(@PathVariable Long id) {
        utilisateurService.deactivateUser(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Utilisateur désactivé avec succès");
        return ResponseEntity.ok(response);
    }

    /**
     * POST /api/utilisateurs/{id}/activate
     * Réactive un compte utilisateur (admin uniquement)
     */
    @PostMapping("/{id}/activate")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, String>> activateUser(@PathVariable Long id) {
        utilisateurService.activateUser(id);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Utilisateur réactivé avec succès");
        return ResponseEntity.ok(response);
    }

    /**
     * PUT /api/utilisateurs/{id}/role
     * Change le rôle d'un utilisateur (admin uniquement)
     */
    @PutMapping("/{id}/role")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, String>> changeUserRole(
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {
        String roleName = request.get("role");
        if (roleName == null || roleName.isBlank()) {
            throw new IllegalArgumentException("Le rôle est obligatoire");
        }
        utilisateurService.changeUserRole(id, roleName);
        Map<String, String> response = new HashMap<>();
        response.put("message", "Rôle de l'utilisateur changé avec succès");
        return ResponseEntity.ok(response);
    }

    /**
     * GET /api/utilisateurs/stats/active
     * Compte les utilisateurs actifs (admin uniquement)
     */
    @GetMapping("/stats/active")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> countActiveUsers() {
        long count = utilisateurService.countActiveUsers();
        Map<String, Object> response = new HashMap<>();
        response.put("activeUsers", count);
        return ResponseEntity.ok(response);
    }

    /**
     * GET /api/utilisateurs/stats/role/{role}
     * Compte les utilisateurs par rôle (admin uniquement)
     */
    @GetMapping("/stats/role/{role}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> countUsersByRole(@PathVariable String role) {
        long count = utilisateurService.countUsersByRole(role);
        Map<String, Object> response = new HashMap<>();
        response.put("role", role.toUpperCase());
        response.put("count", count);
        return ResponseEntity.ok(response);
    }
}