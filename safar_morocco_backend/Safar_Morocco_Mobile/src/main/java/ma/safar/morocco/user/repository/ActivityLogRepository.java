package ma.safar.morocco.user.repository;

import ma.safar.morocco.user.entity.ActivityLog;
import ma.safar.morocco.user.entity.Utilisateur;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ActivityLogRepository extends JpaRepository<ActivityLog, Long> {
    List<ActivityLog> findByUtilisateurOrderByTimestampDesc(Utilisateur utilisateur);
}
