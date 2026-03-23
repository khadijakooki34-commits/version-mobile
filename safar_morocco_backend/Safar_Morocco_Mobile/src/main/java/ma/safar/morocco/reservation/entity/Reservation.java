package ma.safar.morocco.reservation.entity;

import jakarta.persistence.*;
import lombok.*;
import ma.safar.morocco.event.entity.EvenementCulturel;
import ma.safar.morocco.user.entity.Utilisateur;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Table(name = "reservations", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "utilisateur_id", "evenement_id" })
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EntityListeners(AuditingEntityListener.class)
public class Reservation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utilisateur_id", nullable = false)
    private Utilisateur utilisateur;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "evenement_id", nullable = false)
    private EvenementCulturel evenement;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime dateReservation;

    @Column(nullable = false)
    @Builder.Default
    private String status = "CONFIRMED"; // CONFIRMED, CANCELLED
}
