package ma.safar.morocco.media.repository;

import ma.safar.morocco.media.entity.Media;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MediaRepository extends JpaRepository<Media, Long> {
    List<Media> findByDestinationId(Long destinationId);
}

