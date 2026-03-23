package ma.safar.morocco.destination.service;

import lombok.RequiredArgsConstructor;
import ma.safar.morocco.destination.entity.Destination;
import ma.safar.morocco.destination.repository.DestinationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class DestinationService {
    private final DestinationRepository destinationRepository;

    public List<Destination> findAll() {
        return destinationRepository.findAll();
    }

    public Optional<Destination> findById(Long id) {
        return destinationRepository.findById(id);
    }

    @Transactional
    public Destination create(Destination d) {
        return destinationRepository.save(d);
    }

    @Transactional
    public Destination update(Long id, Destination updated) {
        Destination existing = destinationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Destination non trouvée"));
        existing.setNom(updated.getNom());
        existing.setDescription(updated.getDescription());
        existing.setHistoire(updated.getHistoire());
        existing.setType(updated.getType());
        existing.setLatitude(updated.getLatitude());
        existing.setLongitude(updated.getLongitude());
        existing.setCategorie(updated.getCategorie());
        return destinationRepository.save(existing);
    }

    public List<Destination> findByCategorie(String categorie) {
        return destinationRepository.findByCategorie(categorie);
    }

    @Transactional
    public void delete(Long id) {
        if (!destinationRepository.existsById(id)) {
            throw new RuntimeException("Destination non trouvée");
        }
        destinationRepository.deleteById(id);
    }

    @Transactional
    public void incrementViewCount(Long id) {
        Destination destination = destinationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Destination non trouvée"));
        destination.setViewCount(destination.getViewCount() == null ? 1 : destination.getViewCount() + 1);
        destinationRepository.save(destination);
    }

    /**
     * Met à jour toutes les destinations avec les données d'historique par défaut
     * Cette méthode est utilisée pour corriger les destinations existantes sans historique
     */
    @Transactional
    public void updateAllDestinationsWithHistory() {
        List<Destination> destinations = destinationRepository.findAll();
        
        for (Destination destination : destinations) {
            if (destination.getHistoire() == null || destination.getHistoire().isEmpty()) {
                // Utiliser les données d'historique basées sur le nom de la destination
                String history = getHistoryForDestination(destination.getNom());
                destination.setHistoire(history);
                destinationRepository.save(destination);
            }
        }
    }

    private String getHistoryForDestination(String destinationName) {
        // Retourner l'historique approprié selon le nom de la destination
        switch (destinationName.toLowerCase()) {
            case "jemaa el-fnaa":
                return "La place Jemaa el-Fnaa est le cœur battant de Marrakech depuis la fondation de la ville au XIe siècle par les Almoravides. Historiquement, elle servait de lieu de justice publique où les criminels étaient décapités, d'où son nom macabre qui signifierait \"assemblée des morts\". Au fil des siècles, cet espace s'est transformé en un carrefour de commerce et de rencontres culturelles, attirant des caravaniers du monde entier. Son importance culturelle est telle que l'UNESCO l'a déclarée chef-d'œuvre du patrimoine oral et immatériel de l'humanité.";
            case "hassan ii mosque":
                return "La Mosquée Hassan II, érigée sur les flots de l'Océan Atlantique à Casablanca, est un chef-d'œuvre monumental de l'architecture islamique contemporaine. Achevée en 1993 sur la demande de feu le Roi Hassan II, elle symbolise la renaissance de l'artisanat traditionnel marocain allié aux technologies modernes. Des milliers d'artisans venus de tout le royaume ont contribué à la création de ses zelliges intriqués, de ses plafonds en bois de cèdre sculpté, et de son stuc délicat.";
            case "ait ben haddou":
                return "Aït-ben-Haddou est un ksar du Maroc inscrit sur la liste du patrimoine mondial de l'UNESCO depuis 1987. Situé dans la province de Ouarzazate, c'est un exemple frappant de l'architecture sud-marocaine traditionnelle. Ce village fortifié, constitué d'un ensemble de bâtiments de terre entourés de murailles, était autrefois une étape importante pour les caravanes reliant le Sahara à Marrakech.";
            case "merzouga desert":
                return "Le désert de Merzouga, avec ses imposantes dunes d'Erg Chebbi qui peuvent atteindre jusqu'à 150 mètres de hauteur, est une merveille géologique du sud-est marocain. Historiquement, cette région a été habitée par des tribus nomades amazighes qui ont développé une connaissance intime des écosystèmes arides et des routes des oasis.";
            case "ouzoud waterfalls":
                return "Les cascades d'Ouzoud, nichées au cœur des majestueuses montagnes du Moyen Atlas, constituent l'une des attractions naturelles les plus spectaculaires d'Afrique du Nord, s'écrasant férocement d'une hauteur impressionnante de 110 mètres. Ayant le sens d'olive en amazigh, Ouzoud témoigne de l'importance de la culture de l'olivier qui a façonné la vie économique des Berbères de la région.";
            case "fes el bali":
                return "Fès el-Bali, la plus ancienne médina fortifiée de Fès, a été fondée à la fin du VIIIe siècle par la dynastie idrisside. Avec son incroyable réseau de près de 9 000 ruelles entremêlées, ce chef-d'œuvre urbain est reconnu comme la plus vaste zone piétonne au monde et classé au patrimoine mondial de l'UNESCO.";
            default:
                return "Cette destination fait partie du riche patrimoine culturel et naturel du Maroc, offrant aux visiteurs une expérience unique de découverte et d'émerveillement.";
        }
    }
}
