package ma.safar.morocco.review.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import ma.safar.morocco.user.entity.Utilisateur;
import ma.safar.morocco.destination.entity.Destination;
import org.springframework.data.annotation.CreatedDate;

import java.time.LocalDateTime;

@Entity
@Table(name = "avis")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Avis {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "TEXT")
    private String commentaire;

    @CreatedDate
    private LocalDateTime datePublication;

    @Column(nullable = false)
    private Integer note;

    @Column(length = 50)
    @Builder.Default
    private String status = "PENDING"; // PENDING, APPROVED, REJECTED

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utilisateur_id")
    @JsonIgnoreProperties({ "avis", "favoris", "itineraires", "password", "roles", "hibernateLazyInitializer",
            "handler" })
    private Utilisateur auteur;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "destination_id")
    @JsonIgnoreProperties({ "avis", "medias", "evenements", "meteo", "hibernateLazyInitializer", "handler" })
    private Destination destination;

    @PrePersist
    public void prePersist() {
        if (datePublication == null)
            datePublication = LocalDateTime.now();
        if (status == null)
            status = "PENDING";
    }

}
