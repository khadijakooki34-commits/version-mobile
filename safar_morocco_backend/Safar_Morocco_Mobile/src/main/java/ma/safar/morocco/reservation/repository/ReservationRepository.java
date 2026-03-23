package ma.safar.morocco.reservation.repository;

import ma.safar.morocco.reservation.entity.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Long> {
    List<Reservation> findByUtilisateurId(Long utilisateurId);

    boolean existsByUtilisateurIdAndEvenementId(Long utilisateurId, Long evenementId);
}
