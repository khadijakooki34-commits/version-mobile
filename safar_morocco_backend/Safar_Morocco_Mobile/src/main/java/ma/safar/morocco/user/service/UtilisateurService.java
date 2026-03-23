package ma.safar.morocco.user.service;

import lombok.RequiredArgsConstructor;
import ma.safar.morocco.user.dto.UtilisateurDTO;
import ma.safar.morocco.user.entity.Utilisateur;
import ma.safar.morocco.user.repository.UtilisateurRepository;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Service: UtilisateurService
 * Gestion complète des utilisateurs et opérations métier associées
 * - CRUD des utilisateurs
 * - Gestion des rôles et permissions
 * - Blocage/Déblocage de comptes
 * - Gestion des profils
 */
@Service
@RequiredArgsConstructor
public class UtilisateurService {
    private static final String MAIN_ADMIN_EMAIL = "admin@safar.com";

    private final UtilisateurRepository utilisateurRepository;
    private final PasswordEncoder passwordEncoder;
    private final ActivityLogService activityLogService;

    /**
     * Récupère l'utilisateur actuellement connecté
     */
    public Utilisateur getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return utilisateurRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
    }

    /**
     * Récupère le DTO du profil actuel
     */
    public UtilisateurDTO getCurrentUserProfile() {
        return convertToDTO(getCurrentUser());
    }

    /**
     * Récupère tous les utilisateurs (admin uniquement)
     */
    @PreAuthorize("hasRole('ADMIN')")
    public List<UtilisateurDTO> getAllUsers() {
        return utilisateurRepository.findAll()
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Récupère les utilisateurs actifs
     */
    public List<UtilisateurDTO> getAllActiveUsers() {
        return utilisateurRepository.findAllActiveUsers()
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Récupère les utilisateurs bloqués (admin)
     */
    @PreAuthorize("hasRole('ADMIN')")
    public List<UtilisateurDTO> getBlockedUsers() {
        return utilisateurRepository.findBlockedUsers()
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Récupère un utilisateur par ID
     */
    @PreAuthorize("hasRole('ADMIN')")
    public UtilisateurDTO getUserById(Long id) {
        Utilisateur user = utilisateurRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé avec l'ID: " + id));
        return convertToDTO(user);
    }

    public Utilisateur getUserByEmailEntity(String email) {
        return utilisateurRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
    }

    /**
     * Récupère un utilisateur par email (admin ou l'utilisateur lui-même)
     */
    public UtilisateurDTO getUserByEmail(String email) {
        String currentEmail = SecurityContextHolder.getContext().getAuthentication().getName();
        if (!email.equals(currentEmail) && !isAdmin()) {
            throw new RuntimeException("Accès refusé");
        }
        Utilisateur user = utilisateurRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé: " + email));
        return convertToDTO(user);
    }

    /**
     * Récupère les utilisateurs par rôle (admin)
     */
    @PreAuthorize("hasRole('ADMIN')")
    public List<UtilisateurDTO> getUsersByRole(String role) {
        return utilisateurRepository.findByRole(role)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Crée un nouvel utilisateur (admin)
     */
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public UtilisateurDTO createUser(UtilisateurDTO dto) {
        if (utilisateurRepository.existsByEmail(dto.getEmail())) {
            throw new RuntimeException("Un utilisateur existe déjà avec cet email");
        }

        Utilisateur user = Utilisateur.builder()
                .nom(dto.getNom())
                .email(dto.getEmail())
                .motDePasseHache(passwordEncoder.encode(dto.getMotDePasse()))
                .telephone(dto.getTelephone())
                .langue(dto.getLangue() != null ? dto.getLangue() : "fr")
                .role(dto.getRole() != null ? dto.getRole() : "USER")
                .actif(true)
                .compteBloquer(false)
                .provider("LOCAL")
                .build();

        user = utilisateurRepository.save(user);
        activityLogService.logActivity(user, "ACCOUNT_CREATED", "Compte créé par l'administrateur");
        return convertToDTO(user);
    }

    /**
     * Met à jour un utilisateur (admin)
     */
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public UtilisateurDTO updateUser(Long id, UtilisateurDTO dto) {
        Utilisateur user = utilisateurRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        if (dto.getNom() != null && !dto.getNom().isBlank()) {
            user.setNom(dto.getNom());
        }
        if (dto.getTelephone() != null && !dto.getTelephone().isBlank()) {
            user.setTelephone(dto.getTelephone());
        }
        if (dto.getLangue() != null && !dto.getLangue().isBlank()) {
            user.setLangue(dto.getLangue());
        }
        if (dto.getRole() != null) {
            user.setRole(dto.getRole());
        }
        if (dto.getDescription() != null) {
            user.setDescription(dto.getDescription());
        }

        user = utilisateurRepository.save(user);
        return convertToDTO(user);
    }

    /**
     * Met à jour le profil de l'utilisateur actuellement connecté
     */
    @Transactional
    public UtilisateurDTO updateOwnProfile(UtilisateurDTO dto) {
        Utilisateur user = getCurrentUser();

        if (dto.getNom() != null && !dto.getNom().isBlank()) {
            user.setNom(dto.getNom());
        }
        if (dto.getTelephone() != null && !dto.getTelephone().isBlank()) {
            user.setTelephone(dto.getTelephone());
        }
        if (dto.getLangue() != null && !dto.getLangue().isBlank()) {
            user.setLangue(dto.getLangue());
        }
        if (dto.getDescription() != null) {
            user.setDescription(dto.getDescription());
        }

        user = utilisateurRepository.save(user);
        activityLogService.logActivity(user, "PROFILE_UPDATED", "Informations du profil mises à jour");
        return convertToDTO(user);
    }

    /**
     * Upload une photo de profil
     */
    @Transactional
    public String uploadProfileImage(MultipartFile file) throws IOException {
        String UPLOAD_DIR = "uploads/users";
        Path uploadPath = Paths.get(UPLOAD_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        String filename = UUID.randomUUID() + "_" + file.getOriginalFilename();
        Path filePath = uploadPath.resolve(filename);
        Files.copy(file.getInputStream(), filePath);

        String photoUrl = "/uploads/users/" + filename;
        updateProfilePhoto(photoUrl);
        return photoUrl;
    }

    /**
     * Met à jour la photo de profil
     */
    public void updateProfilePhoto(String photoUrl) {
        Utilisateur user = getCurrentUser();
        user.setPhotoUrl(photoUrl);
        utilisateurRepository.save(user);
        activityLogService.logActivity(user, "PHOTO_UPDATED", "Photo de profil mise à jour");
    }

    /**
     * Supprime un utilisateur (admin)
     */
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public void deleteUser(Long id) {
        if (!utilisateurRepository.existsById(id)) {
            throw new RuntimeException("Utilisateur non trouvé");
        }
        utilisateurRepository.deleteById(id);
    }

    /**
     * Bloque un compte utilisateur (admin)
     */
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public void blockUser(Long id) {
        Utilisateur user = utilisateurRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
        user.setCompteBloquer(true);
        utilisateurRepository.save(user);
    }

    /**
     * Débloque un compte utilisateur (admin)
     */
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public void unblockUser(Long id) {
        Utilisateur user = utilisateurRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
        user.setCompteBloquer(false);
        utilisateurRepository.save(user);
    }

    /**
     * Désactive un compte utilisateur (admin)
     */
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public void deactivateUser(Long id) {
        Utilisateur user = utilisateurRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
        user.setActif(false);
        utilisateurRepository.save(user);
    }

    /**
     * Réactive un compte utilisateur (admin)
     */
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public void activateUser(Long id) {
        Utilisateur user = utilisateurRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
        user.setActif(true);
        utilisateurRepository.save(user);
    }

    /**
     * Change le rôle d'un utilisateur (admin)
     */
    @PreAuthorize("hasRole('ADMIN')")
    @Transactional
    public void changeUserRole(Long id, String newRole) {
        String currentEmail = SecurityContextHolder.getContext().getAuthentication().getName();
        if (currentEmail == null || !currentEmail.equalsIgnoreCase(MAIN_ADMIN_EMAIL)) {
            throw new RuntimeException("Accès refusé: seul l'admin principal peut changer les rôles");
        }

        if (!newRole.equalsIgnoreCase("USER") && !newRole.equalsIgnoreCase("ADMIN")) {
            throw new RuntimeException("Rôle invalide. Les rôles autorisés sont: USER, ADMIN");
        }

        Utilisateur user = utilisateurRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        if (user.getEmail() != null && user.getEmail().equalsIgnoreCase(MAIN_ADMIN_EMAIL)) {
            throw new RuntimeException("Action interdite: impossible de modifier le rôle du compte admin principal");
        }

        user.setRole(newRole.toUpperCase());
        utilisateurRepository.save(user);
    }

    /**
     * Compte les utilisateurs actifs
     */
    @PreAuthorize("hasRole('ADMIN')")
    public long countActiveUsers() {
        return utilisateurRepository.countActiveUsers();
    }

    /**
     * Compte les utilisateurs par rôle
     */
    @PreAuthorize("hasRole('ADMIN')")
    public long countUsersByRole(String role) {
        return utilisateurRepository.countByRole(role);
    }

    /**
     * Convertit une entité Utilisateur en DTO
     */
    private UtilisateurDTO convertToDTO(Utilisateur user) {
        return UtilisateurDTO.builder()
                .id(user.getId())
                .nom(user.getNom())
                .email(user.getEmail())
                .telephone(user.getTelephone())
                .langue(user.getLangue())
                .role(user.getRole())
                .actif(user.getActif())
                .compteBloquer(user.getCompteBloquer())
                .provider(user.getProvider())
                .photoUrl(user.getPhotoUrl())
                .dateInscription(user.getDateInscription())
                .build();
    }

    /**
     * Vérifie si l'utilisateur actuel est admin
     */
    private boolean isAdmin() {
        return SecurityContextHolder.getContext()
                .getAuthentication()
                .getAuthorities()
                .stream()
                .anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN"));
    }

    public Utilisateur findByEmail(String email) {
        return utilisateurRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found with email: " + email));
    }
}