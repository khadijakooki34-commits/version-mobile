package ma.safar.morocco.favori.service;

import lombok.RequiredArgsConstructor;
import ma.safar.morocco.destination.entity.Destination;
import ma.safar.morocco.destination.repository.DestinationRepository;
import ma.safar.morocco.favori.entity.Favori;
import ma.safar.morocco.favori.repository.FavoriRepository;
import ma.safar.morocco.user.entity.Utilisateur;
import ma.safar.morocco.user.service.UtilisateurService; // Assuming this exists
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FavoriService {

    private final FavoriRepository favoriRepository;
    private final DestinationRepository destinationRepository;
    private final UtilisateurService utilisateurService; // Retrieve current user

    @Transactional
    public Favori addFavori(Long destinationId) {
        Utilisateur currentUser = utilisateurService.getCurrentUser();
        if (favoriRepository.existsByUtilisateurIdAndDestinationId(currentUser.getId(), destinationId)) {
            throw new RuntimeException("Destination déjà dans les favoris");
        }

        Destination destination = destinationRepository.findById(destinationId)
                .orElseThrow(() -> new RuntimeException("Destination non trouvée"));

        Favori favori = Favori.builder()
                .utilisateur(currentUser)
                .destination(destination)
                .build();

        return favoriRepository.save(favori);
    }

    @Transactional
    public void removeFavori(Long destinationId) {
        Utilisateur currentUser = utilisateurService.getCurrentUser();
        favoriRepository.deleteByUtilisateurIdAndDestinationId(currentUser.getId(), destinationId);
    }

    public List<Favori> getMyFavoris() {
        Utilisateur currentUser = utilisateurService.getCurrentUser();
        return favoriRepository.findByUtilisateurId(currentUser.getId());
    }

    public boolean isFavori(Long destinationId) {
        Utilisateur currentUser = utilisateurService.getCurrentUser();
        return favoriRepository.existsByUtilisateurIdAndDestinationId(currentUser.getId(), destinationId);
    }
}
