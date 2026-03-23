package ma.safar.morocco.favori.entity;

import jakarta.persistence.*;
import lombok.*;
import ma.safar.morocco.destination.entity.Destination;
import ma.safar.morocco.user.entity.Utilisateur;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Table(name = "favoris", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "utilisateur_id", "destination_id" })
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EntityListeners(AuditingEntityListener.class)
public class Favori {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utilisateur_id", nullable = false)
    private Utilisateur utilisateur;

    @ManyToOne(fetch = FetchType.EAGER) // Eager to fetch destination details easily
    @JoinColumn(name = "destination_id", nullable = false)
    private Destination destination;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime dateAjout;
}
