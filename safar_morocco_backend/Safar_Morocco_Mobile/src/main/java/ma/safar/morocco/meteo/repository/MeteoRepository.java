package ma.safar.morocco.meteo.repository;

import ma.safar.morocco.meteo.entity.Meteo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface MeteoRepository extends JpaRepository<Meteo, Long> {

    /**
     * Trouver la météo la plus récente pour une destination
     */
    @Query("SELECT m FROM Meteo m WHERE m.destination.id = :destinationId " +
            "ORDER BY m.datePrevision DESC")
    Optional<Meteo> findLatestByDestinationId(@Param("destinationId") Long destinationId);

    /**
     * Trouver toutes les prévisions pour une destination
     */
    List<Meteo> findByDestinationIdOrderByDatePrevisionAsc(Long destinationId);

    /**
     * Trouver les prévisions dans une plage de dates
     */
    @Query("SELECT m FROM Meteo m WHERE m.destination.id = :destinationId " +
            "AND m.datePrevision BETWEEN :debut AND :fin " +
            "ORDER BY m.datePrevision ASC")
    List<Meteo> findByDestinationIdAndDateRange(
            @Param("destinationId") Long destinationId,
            @Param("debut") LocalDateTime debut,
            @Param("fin") LocalDateTime fin
    );

    /**
     * Supprimer les anciennes prévisions
     */
    void deleteByDatePrevisionBefore(LocalDateTime date);
}