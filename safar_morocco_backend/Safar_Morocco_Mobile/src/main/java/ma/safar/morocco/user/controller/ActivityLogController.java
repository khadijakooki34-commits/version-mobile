package ma.safar.morocco.user.controller;

import lombok.RequiredArgsConstructor;
import ma.safar.morocco.user.entity.ActivityLog;
import ma.safar.morocco.user.entity.Utilisateur;
import ma.safar.morocco.user.service.ActivityLogService;
import ma.safar.morocco.user.service.UtilisateurService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/activities")
@RequiredArgsConstructor
public class ActivityLogController {

    private final ActivityLogService activityLogService;
    private final UtilisateurService utilisateurService;

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getMyActivities() {
        Utilisateur user = utilisateurService.getCurrentUser();
        List<ActivityLog> activities = activityLogService.getUserActivities(user);

        List<Map<String, Object>> response = activities.stream().map(log -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id", log.getId());
            map.put("action", log.getAction());
            map.put("details", log.getDetails() != null ? log.getDetails() : "");
            map.put("timestamp", log.getTimestamp());
            return map;
        }).collect(Collectors.toList());

        return ResponseEntity.ok(response);
    }
}
