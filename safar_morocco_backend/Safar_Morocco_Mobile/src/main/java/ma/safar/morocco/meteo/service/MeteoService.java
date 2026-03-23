package ma.safar.morocco.meteo.service;

import ma.safar.morocco.destination.entity.Destination;
import ma.safar.morocco.destination.repository.DestinationRepository;
import ma.safar.morocco.meteo.dto.MeteoDTO;
import ma.safar.morocco.meteo.dto.OpenMeteoResponse;
import ma.safar.morocco.meteo.entity.Meteo;
import ma.safar.morocco.meteo.repository.MeteoRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MeteoService {

    private final MeteoRepository meteoRepository;
    private final DestinationRepository destinationRepository;
    private final OpenMeteoService openMeteoService;

    @Transactional
    public MeteoDTO getMeteoForDestination(Long destinationId) {
        Destination destination = destinationRepository.findById(destinationId)
                .orElseThrow(() -> new RuntimeException("Destination non trouvée avec l'ID: " + destinationId));

        // Vérifier cache
        var meteoRecente = meteoRepository.findLatestByDestinationId(destinationId);

        if (meteoRecente.isPresent() && meteoRecente.get().isRecent()) {
            log.info("✓ Utilisation météo en cache pour destination {} ({})",
                    destinationId, destination.getNom());
            return convertToDTO(meteoRecente.get());
        }

        // Récupérer depuis API Open-Meteo
        log.info("→ Récupération nouvelles données météo pour destination {} ({})",
                destinationId, destination.getNom());

        OpenMeteoResponse apiResponse = openMeteoService.getWeatherByCoordinates(
                destination.getLatitude(),
                destination.getLongitude()
        );

        // Créer ou mettre à jour
        Meteo meteo = meteoRecente.orElse(new Meteo());
        mapOpenMeteoToEntity(apiResponse, meteo, destination);

        Meteo savedMeteo = meteoRepository.save(meteo);
        log.info("✓ Météo sauvegardée pour destination {} - Temp: {}°C",
                destination.getNom(), savedMeteo.getTemperature());

        return convertToDTO(savedMeteo);
    }

    /**
     * Récupérer toutes les prévisions pour une destination
     */
    @Transactional(readOnly = true)
    public List<MeteoDTO> getAllMeteoForDestination(Long destinationId) {
        log.info("Récupération de toutes les prévisions météo pour destination {}", destinationId);

        return meteoRepository.findByDestinationIdOrderByDatePrevisionAsc(destinationId)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Générer 7 jours de prévisions pour une destination
     */
    @Transactional
    public List<MeteoDTO> generate7DayForecast(Long destinationId) {
        log.info("Génération de 7 jours de prévisions pour destination {}", destinationId);
        
        List<MeteoDTO> forecast = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();
        
        // Récupérer la météo actuelle comme référence
        MeteoDTO currentWeather = getMeteoForDestination(destinationId);
        
        for (int i = 0; i < 7; i++) {
            LocalDateTime forecastDate = now.plusDays(i);
            MeteoDTO dayForecast = new MeteoDTO();
            
            // Copier les données de base
            dayForecast.setDestinationId(destinationId);
            dayForecast.setDestinationNom(currentWeather.getDestinationNom());
            dayForecast.setTemperature(currentWeather.getTemperature() + (Math.random() - 0.5) * 4);
            dayForecast.setTemperatureMin(dayForecast.getTemperature() - 2);
            dayForecast.setTemperatureMax(dayForecast.getTemperature() + 2);
            dayForecast.setTemperatureRessentie(dayForecast.getTemperature() - 1);
            dayForecast.setConditions(currentWeather.getConditions());
            dayForecast.setDescription(currentWeather.getDescription());
            dayForecast.setIconeCode(currentWeather.getIconeCode());
            dayForecast.setVitesseVent(currentWeather.getVitesseVent() + (Math.random() - 0.5) * 5);
            dayForecast.setHumidite(currentWeather.getHumidite() + (int)((Math.random() - 0.5) * 10));
            dayForecast.setPressionAtmospherique(currentWeather.getPressionAtmospherique());
            dayForecast.setVisibilite(currentWeather.getVisibilite());
            dayForecast.setDatePrevision(forecastDate);
            dayForecast.setDerniereMiseAJour(now);
            
            forecast.add(dayForecast);
        }
        
        return forecast;
    }

    /**
     * Récupérer les prévisions dans une plage de dates
     * ← MÉTHODE MANQUANTE AJOUTÉE ICI
     */
    @Transactional(readOnly = true)
    public List<MeteoDTO> getMeteoByDateRange(Long destinationId, LocalDateTime debut, LocalDateTime fin) {
        log.info("Récupération prévisions météo pour destination {} entre {} et {}",
                destinationId, debut, fin);

        return meteoRepository.findByDestinationIdAndDateRange(destinationId, debut, fin)
                .stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * MAPPER : Open-Meteo Response → Entity
     */
    private void mapOpenMeteoToEntity(OpenMeteoResponse api, Meteo meteo, Destination destination) {
        meteo.setDestination(destination);

        if (api.getCurrent() != null) {
            OpenMeteoResponse.Current current = api.getCurrent();

            // Températures
            meteo.setTemperature(current.getTemperature());
            meteo.setTemperatureRessentie(current.getFeelsLike());

            // Min/Max du jour
            if (api.getDaily() != null && !api.getDaily().getTemperatureMax().isEmpty()) {
                meteo.setTemperatureMax(api.getDaily().getTemperatureMax().get(0));
                meteo.setTemperatureMin(api.getDaily().getTemperatureMin().get(0));
            }

            // Conditions
            Integer weatherCode = current.getWeatherCode();
            meteo.setConditions(openMeteoService.getWeatherDescription(weatherCode));
            meteo.setDescription(openMeteoService.getWeatherDescription(weatherCode));
            meteo.setIconeCode(openMeteoService.getWeatherIcon(weatherCode));

            // Vent
            meteo.setVitesseVent(current.getWindSpeed());
            meteo.setDirectionVent(current.getWindDirection());

            // Atmosphère
            meteo.setHumidite(current.getHumidity());
            meteo.setPressionAtmospherique(current.getPressure());

            // Précipitations
            meteo.setPrecipitation1h(current.getPrecipitation());

            // Nuages
            meteo.setCouvertureNuageuse(current.getCloudCover());

            // Date prévision
            if (current.getTime() != null) {
                meteo.setDatePrevision(LocalDateTime.parse(current.getTime(),
                        DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            }
        }

        // Soleil (lever/coucher)
        if (api.getDaily() != null && !api.getDaily().getSunrise().isEmpty()) {
            meteo.setHeureLeverSoleil(LocalDateTime.parse(api.getDaily().getSunrise().get(0),
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            meteo.setHeureCoucherSoleil(LocalDateTime.parse(api.getDaily().getSunset().get(0),
                    DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        }

        meteo.setDerniereMiseAJour(LocalDateTime.now());
        meteo.mettreAJourDonnees(api.toString());
    }

    /**
     * Nettoyer les anciennes prévisions (tâche planifiée)
     */
    @Scheduled(cron = "0 0 2 * * ?")
    @Transactional
    public void cleanOldForecasts() {
        LocalDateTime cutoffDate = LocalDateTime.now().minusDays(7);
        meteoRepository.deleteByDatePrevisionBefore(cutoffDate);
        log.info("✓ Anciennes prévisions météo supprimées");
    }

    /**
     * Convertir Entity → DTO
     */
    private MeteoDTO convertToDTO(Meteo meteo) {
        MeteoDTO dto = new MeteoDTO();
        dto.setId(meteo.getId());
        dto.setTemperature(meteo.getTemperature());
        dto.setTemperatureMin(meteo.getTemperatureMin());
        dto.setTemperatureMax(meteo.getTemperatureMax());
        dto.setTemperatureRessentie(meteo.getTemperatureRessentie());
        dto.setConditions(meteo.getConditions());
        dto.setDescription(meteo.getDescription());
        dto.setIconeCode(meteo.getIconeCode());
        dto.setIconeUrl(meteo.getIconeUrl());
        dto.setVitesseVent(meteo.getVitesseVent());
        dto.setDirectionVent(meteo.getDirectionVent());
        dto.setRafalesVent(meteo.getRafalesVent());
        dto.setHumidite(meteo.getHumidite());
        dto.setPressionAtmospherique(meteo.getPressionAtmospherique());
        dto.setPrecipitation1h(meteo.getPrecipitation1h());
        dto.setPrecipitation3h(meteo.getPrecipitation3h());
        dto.setVisibilite(meteo.getVisibilite());
        dto.setCouvertureNuageuse(meteo.getCouvertureNuageuse());
        dto.setHeureLeverSoleil(meteo.getHeureLeverSoleil());
        dto.setHeureCoucherSoleil(meteo.getHeureCoucherSoleil());
        dto.setDatePrevision(meteo.getDatePrevision());
        dto.setDerniereMiseAJour(meteo.getDerniereMiseAJour());

        if (meteo.getDestination() != null) {
            dto.setDestinationId(meteo.getDestination().getId());
            dto.setDestinationNom(meteo.getDestination().getNom());
        }

        return dto;
    }
}