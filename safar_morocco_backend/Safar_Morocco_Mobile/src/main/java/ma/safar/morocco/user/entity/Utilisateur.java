package ma.safar.morocco.user.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.ArrayList;

@Entity
@Table(name = "utilisateurs", indexes = {
        @Index(name = "idx_email", columnList = "email", unique = true),
        @Index(name = "idx_provider", columnList = "provider"),
        @Index(name = "idx_actif", columnList = "actif")
})
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString(exclude = "motDePasseHache")
public class Utilisateur implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Le nom est obligatoire")
    @Column(nullable = false, length = 100)
    private String nom;

    @Email(message = "Format d'email invalide")
    @NotBlank(message = "L'email est obligatoire")
    @Column(nullable = false, unique = true, length = 150)
    private String email;

    @Column(nullable = false)
    private String motDePasseHache;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime dateInscription;

    @LastModifiedDate
    private LocalDateTime dateModification;

    @Column(nullable = false, length = 20)
    @Builder.Default
    private String role = "USER"; // ADMIN or USER

    @Column(nullable = false)
    @Builder.Default
    private Boolean actif = true;

    @Column(nullable = false)
    @Builder.Default
    private Boolean compteBloquer = false;

    @Column(length = 50)
    private String telephone;

    @Column(length = 10)
    @Builder.Default
    private String langue = "fr";

    // OAuth2 fields
    @Column(length = 20)
    private String provider; // GOOGLE, LOCAL

    @Column(length = 500)
    private String providerId;

    @Column(columnDefinition = "LONGTEXT")
    private String photoUrl;

    @Column(length = 1000)
    private String description;

    private String resetPasswordToken;

    private LocalDateTime validiteTokenReset;

    @Column(columnDefinition = "LONGTEXT")
    private String preferences; // JSON format for user preferences

    // Relationships - One user can have many reviews
    @JsonIgnore
    @OneToMany(mappedBy = "auteur", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<ma.safar.morocco.review.entity.Avis> avis = new ArrayList<>();

    // One user can have many itineraries
    @JsonIgnore
    @OneToMany(mappedBy = "proprietaire", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<ma.safar.morocco.itinerary.entity.Itineraire> itineraires = new ArrayList<>();

    // UserDetails implementation
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role));
    }

    @Override
    public String getPassword() {
        return motDePasseHache;
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return !compteBloquer;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return actif;
    }

}