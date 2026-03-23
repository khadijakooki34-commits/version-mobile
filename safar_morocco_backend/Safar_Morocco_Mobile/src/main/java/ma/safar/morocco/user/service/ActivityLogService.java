package ma.safar.morocco.user.service;

import lombok.RequiredArgsConstructor;
import ma.safar.morocco.user.entity.ActivityLog;
import ma.safar.morocco.user.entity.Utilisateur;
import ma.safar.morocco.user.repository.ActivityLogRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ActivityLogService {

    private final ActivityLogRepository activityLogRepository;

    @Transactional
    public void logActivity(Utilisateur user, String action, String details) {
        ActivityLog log = ActivityLog.builder()
                .utilisateur(user)
                .action(action)
                .details(details)
                .build();
        activityLogRepository.save(log);
    }

    public List<ActivityLog> getUserActivities(Utilisateur user) {
        return activityLogRepository.findByUtilisateurOrderByTimestampDesc(user);
    }
}
