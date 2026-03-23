package ma.safar.morocco.itinerary.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import ma.safar.morocco.user.entity.Utilisateur;
import ma.safar.morocco.destination.entity.Destination;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Entité Itineraire - Plateforme Safar Morocco
 * Conforme au diagramme de classes et cahier des charges
 *
 * @author Khadija El Achhab
 */
@Entity
@Table(
        name = "itineraires",
        indexes = {
                @Index(name = "idx_utilisateur", columnList = "utilisateur_id"),
                @Index(name = "idx_date_creation", columnList = "date_creation"),
                @Index(name = "idx_nom", columnList = "nom")
        }
)
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@ToString(exclude = {"proprietaire", "destinations"})
public class Itineraire {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Le nom de l'itinéraire est obligatoire")
    @Column(nullable = false, length = 200)
    private String nom;

    @Column(name = "duree_estimee", length = 100)
    private String dureeEstimee;

    @CreatedDate
    @Column(name = "date_creation", nullable = false, updatable = false)
    private LocalDateTime dateCreation;

    @LastModifiedDate
    @Column(name = "date_modification")
    private LocalDateTime dateModification;

    // Champs calculés
    @Column(name = "distance_totale")
    private Double distanceTotale;

    @Column(name = "nombre_destinations")
    private Integer nombreDestinations;

    @Column(name = "est_optimise")
    @Builder.Default
    private Boolean estOptimise = false;

    // ============================================
    // RELATIONS
    // ============================================

    /**
     * Relation ManyToOne avec Utilisateur
     * Un utilisateur peut créer plusieurs itinéraires
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utilisateur_id", nullable = false)
    @NotNull(message = "Le propriétaire est obligatoire")
    private Utilisateur proprietaire;

    /**
     * Relation ManyToMany avec Destination
     * Un itinéraire contient plusieurs destinations
     */
    @ManyToMany(fetch = FetchType.LAZY, cascade = {CascadeType.PERSIST, CascadeType.MERGE})
    @JoinTable(
            name = "itineraire_destinations",
            joinColumns = @JoinColumn(name = "itineraire_id"),
            inverseJoinColumns = @JoinColumn(name = "destination_id"),
            indexes = {
                    @Index(name = "idx_itin_id", columnList = "itineraire_id"),
                    @Index(name = "idx_dest_id", columnList = "destination_id")
            }
    )
    @OrderColumn(name = "ordre")
    @Builder.Default
    private List<Destination> destinations = new ArrayList<>();

    // ============================================
    // MÉTHODES MÉTIER (Diagramme de classes)
    // ============================================

    /**
     * Calcule l'itinéraire optimisé selon l'algorithme du plus proche voisin
     * Minimise la distance totale parcourue
     */
    public void calculerItineraireOptimise() {
        if (destinations == null || destinations.size() < 2) {
            this.estOptimise = true;
            return;
        }

        List<Destination> optimized = new ArrayList<>();
        List<Destination> remaining = new ArrayList<>(destinations);

        // Commence avec la première destination
        Destination current = remaining.remove(0);
        optimized.add(current);

        // Trouve toujours la destination la plus proche
        while (!remaining.isEmpty()) {
            Destination closest = findClosestDestination(current, remaining);
            remaining.remove(closest);
            optimized.add(closest);
            current = closest;
        }

        this.destinations = optimized;
        this.estOptimise = true;

        // Recalculer la distance totale après optimisation
        this.distanceTotale = calculerDistanceTotale();
    }

    /**
     * Recherche d'itinéraire (implémenté dans le service)
     */
    public void rechercherItineraire() {
        // Logique dans ItineraireService
    }

    // ============================================
    // MÉTHODES UTILITAIRES
    // ============================================

    /**
     * Trouve la destination la plus proche parmi une liste
     */
    private Destination findClosestDestination(Destination from, List<Destination> candidates) {
        Destination closest = null;
        double minDistance = Double.MAX_VALUE;

        for (Destination candidate : candidates) {
            double distance = calculateDistance(from, candidate);
            if (distance < minDistance) {
                minDistance = distance;
                closest = candidate;
            }
        }

        return closest;
    }

    /**
     * Calcule la distance entre deux destinations (Formule de Haversine)
     * @return Distance en kilomètres
     */
    private double calculateDistance(Destination from, Destination to) {
        if (from.getLatitude() == null || from.getLongitude() == null ||
                to.getLatitude() == null || to.getLongitude() == null) {
            return Double.MAX_VALUE;
        }

        final int R = 6371; // Rayon de la Terre en km

        double latDistance = Math.toRadians(to.getLatitude() - from.getLatitude());
        double lonDistance = Math.toRadians(to.getLongitude() - from.getLongitude());

        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(from.getLatitude()))
                * Math.cos(Math.toRadians(to.getLatitude()))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return R * c;
    }

    /**
     * Ajoute une destination à l'itinéraire
     */
    public void ajouterDestination(Destination destination) {
        if (destination != null && !this.destinations.contains(destination)) {
            this.destinations.add(destination);
            this.nombreDestinations = this.destinations.size();
            this.distanceTotale = calculerDistanceTotale();
            this.dureeEstimee = calculerDureeTotale();
        }
    }

    /**
     * Supprime une destination de l'itinéraire
     */
    public void supprimerDestination(Destination destination) {
        if (this.destinations.remove(destination)) {
            this.nombreDestinations = this.destinations.size();
            this.distanceTotale = calculerDistanceTotale();
            this.dureeEstimee = calculerDureeTotale();
        }
    }

    /**
     * Calcule la durée totale estimée de l'itinéraire
     */
    public String calculerDureeTotale() {
        if (destinations == null || destinations.isEmpty()) {
            return "0 heure";
        }

        // Estimation: 2h par destination + temps de trajet (1h pour 50km)
        int heures = destinations.size() * 2;

        double distance = calculerDistanceTotale();
        heures += (int) (distance / 50);

        if (heures < 24) {
            return heures + " heure" + (heures > 1 ? "s" : "");
        } else {
            int jours = heures / 24;
            int restHeures = heures % 24;
            return jours + " jour" + (jours > 1 ? "s" : "") +
                    (restHeures > 0 ? " " + restHeures + "h" : "");
        }
    }

    /**
     * Calcule la distance totale de l'itinéraire en km
     */
    public double calculerDistanceTotale() {
        if (destinations == null || destinations.size() < 2) {
            return 0.0;
        }

        double total = 0.0;
        for (int i = 0; i < destinations.size() - 1; i++) {
            total += calculateDistance(destinations.get(i), destinations.get(i + 1));
        }

        return Math.round(total * 100.0) / 100.0;
    }

    /**
     * Met à jour automatiquement les champs calculés avant sauvegarde
     */
    @PrePersist
    @PreUpdate
    private void updateCalculatedFields() {
        this.nombreDestinations = (destinations != null) ? destinations.size() : 0;
        this.distanceTotale = calculerDistanceTotale();
        this.dureeEstimee = calculerDureeTotale();
    }
}