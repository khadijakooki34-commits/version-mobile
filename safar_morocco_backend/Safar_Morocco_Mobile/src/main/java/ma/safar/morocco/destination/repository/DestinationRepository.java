package ma.safar.morocco.destination.repository;

import ma.safar.morocco.destination.entity.Destination;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DestinationRepository extends JpaRepository<Destination, Long> {
    List<Destination> findByCategorie(String categorie);
}

