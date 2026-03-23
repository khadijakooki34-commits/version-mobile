package ma.safar.morocco.event.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import ma.safar.morocco.destination.entity.Destination;

import java.time.LocalDateTime;

@Entity
@Table(name = "evenements_culturels")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EvenementCulturel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 200)
    private String nom;

    private LocalDateTime dateDebut;

    private LocalDateTime dateFin;

    @Column(nullable = false, length = 200)
    private String lieu;

    @Column(length = 100)
    private String typeEvenement;

    @Column(columnDefinition = "TEXT")
    private String description;

    private String imageUrl;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "destination_id")
    private Destination destination;

}
