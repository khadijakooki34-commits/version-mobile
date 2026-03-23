package ma.safar.morocco.meteo.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import ma.safar.morocco.destination.entity.Destination;

import java.time.LocalDateTime;

@Entity
@Table(name = "meteo", indexes = {
        @Index(name = "idx_destination_date", columnList = "destination_id,date_prevision"),
        @Index(name = "idx_date_prevision", columnList = "date_prevision")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Meteo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // ========== TEMPÉRATURES ==========
    @Column(nullable = false)
    private Double temperature;

    @Column(name = "temperature_min")
    private Double temperatureMin;

    @Column(name = "temperature_max")
    private Double temperatureMax;

    @Column(name = "temperature_ressentie")
    private Double temperatureRessentie;

    // ========== CONDITIONS MÉTÉO ==========
    @Column(nullable = false, length = 100)
    private String conditions;

    @Column(length = 500)
    private String description;

    @Column(name = "icone_code", length = 10)
    private String iconeCode;

    // ========== VENT ==========
    @Column(name = "vitesse_vent")
    private Double vitesseVent;

    @Column(name = "direction_vent")
    private Integer directionVent;

    @Column(name = "rafales_vent")
    private Double rafalesVent;

    // ========== ATMOSPHÈRE ==========
    @Column(nullable = false)
    private Integer humidite;

    @Column(name = "pression_atmospherique")
    private Integer pressionAtmospherique;

    // ========== PRÉCIPITATIONS ==========
    @Column(name = "precipitation_1h")
    private Double precipitation1h;

    @Column(name = "precipitation_3h")
    private Double precipitation3h;

    // ========== VISIBILITÉ & NUAGES ==========
    @Column(name = "visibilite")
    private Integer visibilite;

    @Column(name = "couverture_nuageuse")
    private Integer couvertureNuageuse;

    // ========== SOLEIL ==========
    @Column(name = "heure_lever_soleil")
    private LocalDateTime heureLeverSoleil;

    @Column(name = "heure_coucher_soleil")
    private LocalDateTime heureCoucherSoleil;

    // ========== DATES ==========
    @Column(name = "date_prevision", nullable = false)
    private LocalDateTime datePrevision;

    @Column(name = "derniere_mise_a_jour", nullable = false)
    private LocalDateTime derniereMiseAJour;

    // ========== RELATION DESTINATION ==========
    @JsonIgnore
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "destination_id", nullable = false)
    private Destination destination;

    // ========== MÉTHODES MÉTIER ==========

    /**
     * Méthode du diagramme : Mise à jour depuis API
     */
    public void mettreAJourDonnees(String donneesAPI) {
        this.derniereMiseAJour = LocalDateTime.now();
    }

    /**
     * Vérifier si la météo est récente (< 1 heure)
     */
    public boolean isRecent() {
        return this.derniereMiseAJour != null &&
                this.derniereMiseAJour.isAfter(LocalDateTime.now().minusHours(1));
    }

    /**
     * Obtenir l'URL complète de l'icône OpenWeatherMap
     */
    public String getIconeUrl() {
        if (iconeCode == null)
            return null;
        return "https://openweathermap.org/img/wn/" + iconeCode + "@2x.png";
    }
}