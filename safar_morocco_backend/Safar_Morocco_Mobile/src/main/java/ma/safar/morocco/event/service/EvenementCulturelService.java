package ma.safar.morocco.event.service;

import lombok.RequiredArgsConstructor;
import ma.safar.morocco.event.entity.EvenementCulturel;
import ma.safar.morocco.event.repository.EvenementCulturelRepository;
import ma.safar.morocco.destination.entity.Destination;
import ma.safar.morocco.destination.repository.DestinationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class EvenementCulturelService {

    private final EvenementCulturelRepository evenementRepository;
    private final DestinationRepository destinationRepository;

    /**
     * Récupère tous les événements
     */
    public List<EvenementCulturel> findAll() {
        return evenementRepository.findAll();
    }

    /**
     * Récupère un événement par ID
     */
    public Optional<EvenementCulturel> findById(Long id) {
        return evenementRepository.findById(id);
    }

    /**
     * Récupère les événements d'une destination
     */
    public List<EvenementCulturel> findByDestinationId(Long destinationId) {
        return evenementRepository.findByDestinationId(destinationId);
    }

    /**
     * Crée un nouvel événement
     */
    @Transactional
    public EvenementCulturel create(Long destinationId, EvenementCulturel evenement) {
        Destination destination = destinationRepository.findById(destinationId)
                .orElseThrow(() -> new RuntimeException("Destination non trouvée"));

        evenement.setDestination(destination);
        return evenementRepository.save(evenement);
    }

    /**
     * Met à jour un événement
     */
    @Transactional
    public EvenementCulturel update(Long id, EvenementCulturel updated) {
        EvenementCulturel existing = evenementRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Événement non trouvé"));

        existing.setNom(updated.getNom());
        existing.setDescription(updated.getDescription());
        existing.setDateDebut(updated.getDateDebut());
        existing.setDateFin(updated.getDateFin());
        existing.setLieu(updated.getLieu());
        existing.setTypeEvenement(updated.getTypeEvenement());
        existing.setImageUrl(updated.getImageUrl());

        return evenementRepository.save(existing);
    }

    /**
     * Supprime un événement
     */
    @Transactional
    public void delete(Long id) {
        if (!evenementRepository.existsById(id)) {
            throw new RuntimeException("Événement non trouvé");
        }
        evenementRepository.deleteById(id);
    }

    /**
     * Récupère les événements à venir
     */
    public List<EvenementCulturel> findUpcoming() {
        LocalDateTime now = LocalDateTime.now();
        return evenementRepository.findAll().stream()
                .filter(e -> e.getDateDebut().isAfter(now))
                .sorted((e1, e2) -> e1.getDateDebut().compareTo(e2.getDateDebut()))
                .toList();
    }

    /**
     * Récupère les événements en cours
     */
    public List<EvenementCulturel> findOngoing() {
        LocalDateTime now = LocalDateTime.now();
        return evenementRepository.findAll().stream()
                .filter(e -> e.getDateDebut().isBefore(now) && e.getDateFin().isAfter(now))
                .toList();
    }

    /**
     * Récupère les événements passés
     */
    public List<EvenementCulturel> findPast() {
        LocalDateTime now = LocalDateTime.now();
        return evenementRepository.findAll().stream()
                .filter(e -> e.getDateFin().isBefore(now))
                .sorted((e1, e2) -> e2.getDateFin().compareTo(e1.getDateFin()))
                .toList();
    }

    /**
     * Récupère les événements par type
     */
    public List<EvenementCulturel> findByType(String type) {
        return evenementRepository.findAll().stream()
                .filter(e -> e.getTypeEvenement().equalsIgnoreCase(type))
                .toList();
    }

    /**
     * Récupère les événements par lieu
     */
    public List<EvenementCulturel> findByLieu(String lieu) {
        return evenementRepository.findAll().stream()
                .filter(e -> e.getLieu() != null && e.getLieu().contains(lieu))
                .toList();
    }

    /**
     * Compte les événements d'une destination
     */
    public long countByDestinationId(Long destinationId) {
        return findByDestinationId(destinationId).size();
    }
}
