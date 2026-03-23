package ma.safar.morocco.event.repository;

import ma.safar.morocco.event.entity.EvenementCulturel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EvenementRepository extends JpaRepository<EvenementCulturel, Long> {
    List<EvenementCulturel> findByDestinationId(Long destinationId);
}

