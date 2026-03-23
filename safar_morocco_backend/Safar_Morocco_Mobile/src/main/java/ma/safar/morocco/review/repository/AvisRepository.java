package ma.safar.morocco.review.repository;

import ma.safar.morocco.review.entity.Avis;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AvisRepository extends JpaRepository<Avis, Long> {
    List<Avis> findByDestinationId(Long destinationId);
    List<Avis> findByAuteurId(Long auteurId);
    List<Avis> findByStatus(String status);
}

