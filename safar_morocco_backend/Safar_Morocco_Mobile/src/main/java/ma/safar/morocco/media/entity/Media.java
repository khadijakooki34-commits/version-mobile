package ma.safar.morocco.media.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import ma.safar.morocco.destination.entity.Destination;

@Entity
@Table(name = "medias")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Media {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 500)
    private String url;

    @Column(nullable = false, length = 50)
    private String type; // IMAGE, VIDEO, AUDIO, DOCUMENT

    @Column(columnDefinition = "TEXT")
    private String description;

    @JsonIgnore
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "destination_id")
    private Destination destination;

}
