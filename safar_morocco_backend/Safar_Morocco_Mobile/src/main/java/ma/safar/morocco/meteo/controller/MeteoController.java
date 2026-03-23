package ma.safar.morocco.meteo.controller;

import ma.safar.morocco.meteo.dto.MeteoDTO;
import ma.safar.morocco.meteo.service.MeteoService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/meteo")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class MeteoController {

    private final MeteoService meteoService;

    /**
     * GET /api/meteo/destination/{destinationId}
     * Récupérer la météo actuelle pour une destination
     */
    @GetMapping("/destination/{destinationId}")
    public ResponseEntity<MeteoDTO> getMeteoByDestination(@PathVariable Long destinationId) {
        try {
            MeteoDTO meteo = meteoService.getMeteoForDestination(destinationId);
            return ResponseEntity.ok(meteo);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    /**
     * GET /api/meteo/destination/{destinationId}/all
     * Récupérer toutes les prévisions météo pour une destination
     */
    @GetMapping("/destination/{destinationId}/all")
    public ResponseEntity<List<MeteoDTO>> getAllMeteoByDestination(@PathVariable Long destinationId) {
        List<MeteoDTO> meteos = meteoService.getAllMeteoForDestination(destinationId);
        
        // Si aucune prévision trouvée, générer 7 jours
        if (meteos.isEmpty()) {
            meteos = meteoService.generate7DayForecast(destinationId);
        }
        
        return ResponseEntity.ok(meteos);
    }

    /**
     * GET /api/meteo/destination/{destinationId}/forecast/7days
     * Générer 7 jours de prévisions pour une destination
     */
    @GetMapping("/destination/{destinationId}/forecast/7days")
    public ResponseEntity<List<MeteoDTO>> get7DayForecast(@PathVariable Long destinationId) {
        List<MeteoDTO> forecast = meteoService.generate7DayForecast(destinationId);
        return ResponseEntity.ok(forecast);
    }

    /**
     * GET /api/meteo/destination/{destinationId}/range
     * Récupérer les prévisions météo dans une plage de dates
     * Exemple: /api/meteo/destination/1/range?debut=2025-01-20T00:00:00&fin=2025-01-27T23:59:59
     */
    @GetMapping("/destination/{destinationId}/range")
    public ResponseEntity<List<MeteoDTO>> getMeteoByDateRange(
            @PathVariable Long destinationId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime debut,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fin) {

        List<MeteoDTO> meteos = meteoService.getMeteoByDateRange(destinationId, debut, fin);
        return ResponseEntity.ok(meteos);
    }
}