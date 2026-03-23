package ma.safar.morocco.reservation.service;

import lombok.RequiredArgsConstructor;
import ma.safar.morocco.event.entity.EvenementCulturel;
import ma.safar.morocco.event.repository.EvenementCulturelRepository;
import ma.safar.morocco.reservation.entity.Reservation;
import ma.safar.morocco.reservation.repository.ReservationRepository;
import ma.safar.morocco.user.entity.Utilisateur;
import ma.safar.morocco.user.service.UtilisateurService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final EvenementCulturelRepository evenementRepository; // Assuming this exists
    private final UtilisateurService utilisateurService;

    @Transactional
    public Reservation createReservation(Long evenementId) {
        Utilisateur currentUser = utilisateurService.getCurrentUser();

        if (reservationRepository.existsByUtilisateurIdAndEvenementId(currentUser.getId(), evenementId)) {
            throw new RuntimeException("Vous avez déjà réservé cet événement.");
        }

        EvenementCulturel event = evenementRepository.findById(evenementId)
                .orElseThrow(() -> new RuntimeException("Événement non trouvé"));

        Reservation reservation = Reservation.builder()
                .utilisateur(currentUser)
                .evenement(event)
                .build();

        return reservationRepository.save(reservation);
    }

    public List<Reservation> getMyReservations() {
        Utilisateur currentUser = utilisateurService.getCurrentUser();
        return reservationRepository.findByUtilisateurId(currentUser.getId());
    }

    @Transactional
    public void cancelReservation(Long reservationId) {
        Utilisateur currentUser = utilisateurService.getCurrentUser();
        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new RuntimeException("Réservation non trouvée"));
        if (!reservation.getUtilisateur().getId().equals(currentUser.getId())) {
            throw new RuntimeException("Vous ne pouvez annuler que vos propres réservations.");
        }
        reservation.setStatus("CANCELLED");
        reservationRepository.save(reservation);
    }
}
