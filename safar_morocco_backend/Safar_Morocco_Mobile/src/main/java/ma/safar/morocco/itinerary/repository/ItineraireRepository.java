package ma.safar.morocco.itinerary.repository;

import ma.safar.morocco.itinerary.entity.Itineraire;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Repository pour l'entité Itineraire
 * @author Khadija El Achhab
 */
@Repository
public interface ItineraireRepository extends JpaRepository<Itineraire, Long> {

    // ============================================
    // REQUÊTES PAR PROPRIÉTAIRE
    // ============================================

    /**
     * Trouve tous les itinéraires d'un utilisateur
     */
    List<Itineraire> findByProprietaire_Id(Long proprietaireId);

    /**
     * Trouve un itinéraire par nom et propriétaire
     */
    Optional<Itineraire> findByNomAndProprietaire_Id(String nom, Long proprietaireId);

    /**
     * Compte les itinéraires d'un utilisateur
     */
    long countByProprietaire_Id(Long proprietaireId);

    /**
     * Trouve les itinéraires récents d'un utilisateur (triés par date)
     */
    @Query("SELECT i FROM Itineraire i WHERE i.proprietaire.id = :proprietaireId " +
            "ORDER BY i.dateCreation DESC")
    List<Itineraire> findRecentsByProprietaire(@Param("proprietaireId") Long proprietaireId);

    // ============================================
    // RECHERCHE AVANCÉE
    // ============================================

    /**
     * Recherche d'itinéraires par nom (partielle, insensible à la casse)
     */
    @Query("SELECT i FROM Itineraire i WHERE LOWER(i.nom) LIKE LOWER(CONCAT('%', :nom, '%')) " +
            "AND i.proprietaire.id = :proprietaireId")
    List<Itineraire> rechercherParNom(@Param("nom") String nom, @Param("proprietaireId") Long proprietaireId);

    /**
     * Trouve les itinéraires contenant une destination spécifique
     */
    @Query("SELECT DISTINCT i FROM Itineraire i JOIN i.destinations d " +
            "WHERE d.id = :destinationId AND i.proprietaire.id = :proprietaireId")
    List<Itineraire> findByDestinationId(
            @Param("destinationId") Long destinationId,
            @Param("proprietaireId") Long proprietaireId
    );

    /**
     * Trouve les itinéraires contenant plusieurs destinations
     */
    @Query("SELECT DISTINCT i FROM Itineraire i JOIN i.destinations d " +
            "WHERE d.id IN :destinationIds AND i.proprietaire.id = :proprietaireId " +
            "GROUP BY i.id HAVING COUNT(DISTINCT d.id) >= :minMatches")
    List<Itineraire> findWithDestinations(
            @Param("destinationIds") List<Long> destinationIds,
            @Param("minMatches") long minMatches,
            @Param("proprietaireId") Long proprietaireId
    );

    // ============================================
    // FILTRES PAR ATTRIBUTS
    // ============================================

    /**
     * Trouve les itinéraires optimisés d'un utilisateur
     */
    List<Itineraire> findByProprietaire_IdAndEstOptimise(Long proprietaireId, Boolean estOptimise);

    /**
     * Trouve les itinéraires créés après une date
     */
    List<Itineraire> findByProprietaire_IdAndDateCreationAfter(
            Long proprietaireId,
            LocalDateTime date
    );

    /**
     * Trouve les itinéraires dans une période
     */
    List<Itineraire> findByProprietaire_IdAndDateCreationBetween(
            Long proprietaireId,
            LocalDateTime dateDebut,
            LocalDateTime dateFin
    );

    /**
     * Trouve les itinéraires avec un nombre minimum de destinations
     */
    @Query("SELECT i FROM Itineraire i WHERE i.proprietaire.id = :proprietaireId " +
            "AND SIZE(i.destinations) >= :nombreMin")
    List<Itineraire> findWithMinDestinations(
            @Param("proprietaireId") Long proprietaireId,
            @Param("nombreMin") int nombreMin
    );

    /**
     * Trouve les itinéraires avec un nombre de destinations dans une plage
     */
    @Query("SELECT i FROM Itineraire i WHERE i.proprietaire.id = :proprietaireId " +
            "AND SIZE(i.destinations) BETWEEN :min AND :max")
    List<Itineraire> findWithDestinationsBetween(
            @Param("proprietaireId") Long proprietaireId,
            @Param("min") int min,
            @Param("max") int max
    );

    // ============================================
    // VÉRIFICATIONS
    // ============================================

    /**
     * Vérifie si un itinéraire avec ce nom existe pour cet utilisateur
     */
    boolean existsByNomAndProprietaire_Id(String nom, Long proprietaireId);

    /**
     * Supprime tous les itinéraires d'un utilisateur
     */
    void deleteByProprietaire_Id(Long proprietaireId);
}