package ma.safar.morocco.review.service;

import lombok.RequiredArgsConstructor;
import ma.safar.morocco.review.entity.Avis;
import ma.safar.morocco.review.repository.AvisRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AvisService {
    private final AvisRepository avisRepository;

    public List<Avis> findByDestination(Long destinationId) {
        return avisRepository.findByDestinationId(destinationId);
    }

    @Transactional
    public Avis addAvis(Avis a) {
        return avisRepository.save(a);
    }

    public void deleteAvis(Long id) {
        avisRepository.deleteById(id);
    }
    
    @Transactional
    public Avis update(Long id, Avis updated) {
        Avis existing = avisRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Avis non trouvé"));
        existing.setCommentaire(updated.getCommentaire());
        existing.setNote(updated.getNote());
        return avisRepository.save(existing);
    }
    
    public Optional<Avis> findById(Long id) {
        return avisRepository.findById(id);
    }
    
    public double calculateAverageRating(Long destinationId) {
        List<Avis> avisList = findByDestination(destinationId);
        if (avisList.isEmpty()) return 0.0;
        return avisList.stream()
                .mapToInt(Avis::getNote)
                .average()
                .orElse(0.0);
    }
    
    public long countByDestination(Long destinationId) {
        return findByDestination(destinationId).size();
    }

    /**
     * Récupère tous les avis par statut
     */
    public List<Avis> findByStatus(String status) {
        return avisRepository.findByStatus(status);
    }

    /**
     * Récupère tous les avis
     */
    public List<Avis> findAll() {
        return avisRepository.findAll();
    }

    /**
     * Approuve un avis (change le statut en APPROVED)
     */
    @Transactional
    public Avis approveAvis(Long id) {
        Avis avis = avisRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Avis non trouvé"));
        avis.setStatus("APPROVED");
        return avisRepository.save(avis);
    }
}

