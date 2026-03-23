package ma.safar.morocco.meteo.service;

import ma.safar.morocco.meteo.dto.OpenMeteoResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

@Service
@Slf4j
public class OpenMeteoService {

    private static final String API_URL = "https://api.open-meteo.com/v1/forecast";

    private final RestTemplate restTemplate;

    public OpenMeteoService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    /**
     * Récupérer la météo par coordonnées géographiques
     * AUCUNE CLÉ API NÉCESSAIRE !
     */
    public OpenMeteoResponse getWeatherByCoordinates(Double latitude, Double longitude) {
        try {
            String url = UriComponentsBuilder.fromUriString(API_URL)
                    .queryParam("latitude", latitude)
                    .queryParam("longitude", longitude)
                    .queryParam("current", "temperature_2m,relative_humidity_2m,apparent_temperature," +
                            "precipitation,weather_code,cloud_cover,pressure_msl," +
                            "wind_speed_10m,wind_direction_10m")
                    .queryParam("daily", "temperature_2m_max,temperature_2m_min,sunrise,sunset," +
                            "precipitation_sum")
                    .queryParam("timezone", "auto")
                    .toUriString();

            log.info("Appel API Open-Meteo pour lat={}, lon={}", latitude, longitude);

            OpenMeteoResponse response = restTemplate.getForObject(url, OpenMeteoResponse.class);

            if (response != null && response.getCurrent() != null) {
                log.info("Météo récupérée avec succès - Temperature: {}°C",
                        response.getCurrent().getTemperature());
            }

            return response;

        } catch (Exception e) {
            log.error("Erreur lors de l'appel à Open-Meteo API pour lat={}, lon={}",
                    latitude, longitude, e);
            throw new RuntimeException("Impossible de récupérer les données météo: " + e.getMessage(), e);
        }
    }

    /**
     * Mapper le code météo en description
     */
    public String getWeatherDescription(Integer weatherCode) {
        if (weatherCode == null) return "Inconnu";

        switch (weatherCode) {
            case 0: return "Ciel dégagé";
            case 1: return "Principalement dégagé";
            case 2: return "Partiellement nuageux";
            case 3: return "Couvert";
            case 45: return "Brouillard";
            case 48: return "Brouillard givrant";
            case 51: return "Bruine légère";
            case 53: return "Bruine modérée";
            case 55: return "Bruine dense";
            case 61: return "Pluie légère";
            case 63: return "Pluie modérée";
            case 65: return "Pluie forte";
            case 71: return "Neige légère";
            case 73: return "Neige modérée";
            case 75: return "Neige forte";
            case 80: return "Averses légères";
            case 81: return "Averses modérées";
            case 82: return "Averses violentes";
            case 95: return "Orage";
            case 96: return "Orage avec grêle légère";
            case 99: return "Orage avec grêle forte";
            default: return "Conditions mixtes";
        }
    }

    /**
     * Obtenir l'icône correspondante (compatible avec OpenWeatherMap icons)
     */
    public String getWeatherIcon(Integer weatherCode) {
        if (weatherCode == null) return "01d";

        switch (weatherCode) {
            case 0: return "01d"; // Ciel dégagé
            case 1: return "02d"; // Peu nuageux
            case 2: return "03d"; // Nuageux
            case 3: return "04d"; // Couvert
            case 45:
            case 48: return "50d"; // Brouillard
            case 51:
            case 53:
            case 55:
            case 61:
            case 63:
            case 65: return "10d"; // Pluie
            case 71:
            case 73:
            case 75: return "13d"; // Neige
            case 80:
            case 81:
            case 82: return "09d"; // Averses
            case 95:
            case 96:
            case 99: return "11d"; // Orage
            default: return "01d";
        }
    }
}