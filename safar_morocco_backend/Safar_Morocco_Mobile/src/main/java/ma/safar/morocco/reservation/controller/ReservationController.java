package ma.safar.morocco.reservation.controller;

import lombok.RequiredArgsConstructor;
import ma.safar.morocco.reservation.entity.Reservation;
import ma.safar.morocco.reservation.service.ReservationService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reservations")
@RequiredArgsConstructor
public class ReservationController {

    private final ReservationService reservationService;

    @PostMapping("/{evenementId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Reservation> createReservation(@PathVariable Long evenementId) {
        return ResponseEntity.ok(reservationService.createReservation(evenementId));
    }

    @GetMapping("/my")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<Reservation>> getMyReservations() {
        return ResponseEntity.ok(reservationService.getMyReservations());
    }

    /**
     * Annuler une réservation (utilisateur propriétaire uniquement).
     * DELETE /api/reservations/{id}
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Void> cancelReservation(@PathVariable Long id) {
        reservationService.cancelReservation(id);
        return ResponseEntity.noContent().build();
    }
}
