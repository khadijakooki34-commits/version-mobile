package ma.safar.morocco.favori.repository;

import ma.safar.morocco.favori.entity.Favori;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavoriRepository extends JpaRepository<Favori, Long> {
    List<Favori> findByUtilisateurId(Long utilisateurId);

    boolean existsByUtilisateurIdAndDestinationId(Long utilisateurId, Long destinationId);

    void deleteByUtilisateurIdAndDestinationId(Long utilisateurId, Long destinationId);

    Optional<Favori> findByUtilisateurIdAndDestinationId(Long utilisateurId, Long destinationId);
}
