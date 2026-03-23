package ma.safar.morocco.user.repository;

import ma.safar.morocco.user.entity.Utilisateur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Repository: UtilisateurRepository
 * Accès aux données pour l'entité Utilisateur
 * Requêtes personnalisées pour l'authentification et la gestion des
 * utilisateurs
 */
@Repository
public interface UtilisateurRepository extends JpaRepository<Utilisateur, Long> {

    /**
     * Cherche un utilisateur par email (cas-insensible)
     */
    Optional<Utilisateur> findByEmail(String email);

    /**
     * Cherche un utilisateur par provider et providerId (OAuth2)
     */
    Optional<Utilisateur> findByProviderAndProviderId(String provider, String providerId);

    /**
     * Vérifie si un email existe déjà
     */
    boolean existsByEmail(String email);

    /**
     * Récupère les utilisateurs actifs
     */
    @Query("SELECT u FROM Utilisateur u WHERE u.actif = true AND u.compteBloquer = false")
    List<Utilisateur> findAllActiveUsers();

    /**
     * Récupère les utilisateurs par rôle
     */
    List<Utilisateur> findByRole(String role);

    /**
     * Cherche les utilisateurs par provider
     */
    List<Utilisateur> findByProvider(String provider);

    /**
     * Compte les utilisateurs actifs
     */
    @Query("SELECT COUNT(u) FROM Utilisateur u WHERE u.actif = true")
    long countActiveUsers();

    /**
     * Compte les utilisateurs par rôle
     */
    long countByRole(String role);

    /**
     * Récupère les utilisateurs créés après une date
     */
    @Query("SELECT u FROM Utilisateur u WHERE u.dateInscription >= :date")
    List<Utilisateur> findUsersCreatedAfter(@Param("date") LocalDateTime date);

    /**
     * Récupère les utilisateurs bloqués
     */
    @Query("SELECT u FROM Utilisateur u WHERE u.compteBloquer = true")
    List<Utilisateur> findBlockedUsers();

    Optional<Utilisateur> findByResetPasswordToken(String token);
}