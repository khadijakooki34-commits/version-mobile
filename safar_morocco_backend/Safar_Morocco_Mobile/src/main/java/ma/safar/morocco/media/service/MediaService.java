package ma.safar.morocco.media.service;

import lombok.RequiredArgsConstructor;
import ma.safar.morocco.media.entity.Media;
import ma.safar.morocco.media.repository.MediaRepository;
import ma.safar.morocco.destination.entity.Destination;
import ma.safar.morocco.destination.repository.DestinationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MediaService {
    
    private final MediaRepository mediaRepository;
    private final DestinationRepository destinationRepository;
    private static final String UPLOAD_DIR = "uploads/media";
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024; // 10 MB
    
    /**
     * Récupère tous les médias d'une destination
     */
    public List<Media> findByDestinationId(Long destinationId) {
        return mediaRepository.findByDestinationId(destinationId);
    }
    
    /**
     * Récupère un média par ID
     */
    public Optional<Media> findById(Long id) {
        return mediaRepository.findById(id);
    }
    
    /**
     * Récupère tous les médias
     */
    public List<Media> findAll() {
        return mediaRepository.findAll();
    }
    
    /**
     * Crée un nouveau média pour une destination
     */
    @Transactional
    public Media create(Long destinationId, Media media) {
        Destination destination = destinationRepository.findById(destinationId)
                .orElseThrow(() -> new RuntimeException("Destination non trouvée"));
        
        media.setDestination(destination);
        return mediaRepository.save(media);
    }
    
    /**
     * Upload un fichier média
     */
    @Transactional
    public Media uploadMedia(Long destinationId, MultipartFile file, String description) throws IOException {
        // Vérifier la destination existe
        Destination destination = destinationRepository.findById(destinationId)
                .orElseThrow(() -> new RuntimeException("Destination non trouvée"));
        
        // Vérifier la taille du fichier
        if (file.getSize() > MAX_FILE_SIZE) {
            throw new RuntimeException("Fichier trop volumineux. Taille maximale: 10 MB");
        }
        
        // Créer le répertoire s'il n'existe pas
        Path uploadPath = Paths.get(UPLOAD_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
        
        // Générer un nom de fichier unique
        String filename = UUID.randomUUID() + "_" + file.getOriginalFilename();
        Path filePath = uploadPath.resolve(filename);
        
        // Sauvegarder le fichier
        Files.copy(file.getInputStream(), filePath);
        
        // Créer l'entité Media
        String type = determineMediaType(file.getContentType());
        Media media = Media.builder()
                .url("/uploads/media/" + filename)
                .type(type)
                .description(description)
                .destination(destination)
                .build();
        
        return mediaRepository.save(media);
    }
    
    /**
     * Met à jour un média
     */
    @Transactional
    public Media update(Long id, Media updated) {
        Media existing = mediaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Média non trouvé"));
        
        existing.setDescription(updated.getDescription());
        if (updated.getType() != null) {
            existing.setType(updated.getType());
        }
        
        return mediaRepository.save(existing);
    }
    
    /**
     * Supprime un média
     */
    @Transactional
    public void delete(Long id) {
        Media media = mediaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Média non trouvé"));
        
        // Supprimer le fichier
        try {
            Path filePath = Paths.get(media.getUrl().replace("/uploads/media/", UPLOAD_DIR + "/"));
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
            // Log l'erreur mais continue la suppression de l'enregistrement
            System.err.println("Erreur lors de la suppression du fichier: " + e.getMessage());
        }
        
        mediaRepository.deleteById(id);
    }
    
    /**
     * Détermine le type de média selon le content-type
     */
    private String determineMediaType(String contentType) {
        if (contentType == null) return "OTHER";
        
        if (contentType.startsWith("image/")) return "IMAGE";
        if (contentType.startsWith("video/")) return "VIDEO";
        if (contentType.startsWith("audio/")) return "AUDIO";
        
        return "OTHER";
    }
    
    /**
     * Récupère les médias par type
     */
    public List<Media> findByType(String type) {
        return mediaRepository.findAll().stream()
                .filter(m -> m.getType().equals(type))
                .toList();
    }
    
    /**
     * Compte les médias d'une destination
     */
    public long countByDestinationId(Long destinationId) {
        return mediaRepository.findByDestinationId(destinationId).size();
    }
}
