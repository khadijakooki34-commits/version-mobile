package ma.safar.morocco.event.repository;

import ma.safar.morocco.event.entity.EvenementCulturel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Repository: EvenementCulturelRepository
 * Gère la persistence des événements culturels
 */
@Repository
public interface EvenementCulturelRepository extends JpaRepository<EvenementCulturel, Long> {

    /**
     * Trouve tous les événements d'une destination
     */
    List<EvenementCulturel> findByDestinationId(Long destinationId);

    /**
     * Trouve tous les événements à venir
     */
    @Query("SELECT e FROM EvenementCulturel e WHERE e.dateDebut > CURRENT_TIMESTAMP ORDER BY e.dateDebut ASC")
    List<EvenementCulturel> findUpcomingEvents();

    /**
     * Trouve tous les événements en cours
     */
    @Query("SELECT e FROM EvenementCulturel e WHERE e.dateDebut <= CURRENT_TIMESTAMP AND e.dateFin >= CURRENT_TIMESTAMP ORDER BY e.dateDebut ASC")
    List<EvenementCulturel> findOngoingEvents();

    /**
     * Trouve tous les événements passés
     */
    @Query("SELECT e FROM EvenementCulturel e WHERE e.dateFin < CURRENT_TIMESTAMP ORDER BY e.dateDebut DESC")
    List<EvenementCulturel> findPastEvents();

    /**
     * Trouve les événements par type
     */
    List<EvenementCulturel> findByTypeEvenement(String typeEvenement);

    /**
     * Trouve les événements par lieu
     */
    List<EvenementCulturel> findByLieu(String lieu);

    /**
     * Trouve les événements entre deux dates
     */
    @Query("SELECT e FROM EvenementCulturel e WHERE e.dateDebut BETWEEN :dateDebut AND :dateFin ORDER BY e.dateDebut ASC")
    List<EvenementCulturel> findByDateRange(@Param("dateDebut") LocalDateTime dateDebut, @Param("dateFin") LocalDateTime dateFin);

    /**
     * Compte les événements d'une destination
     */
    Long countByDestinationId(Long destinationId);

    /**
     * Compte les événements par type
     */
    Long countByTypeEvenement(String typeEvenement);

}
