package ma.safar.morocco.meteo.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class OpenMeteoResponse {

    @JsonProperty("latitude")
    private Double latitude;

    @JsonProperty("longitude")
    private Double longitude;

    @JsonProperty("timezone")
    private String timezone;

    @JsonProperty("current")
    private Current current;

    @JsonProperty("daily")
    private Daily daily;

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Current {
        @JsonProperty("time")
        private String time;

        @JsonProperty("temperature_2m")
        private Double temperature;

        @JsonProperty("relative_humidity_2m")
        private Integer humidity;

        @JsonProperty("precipitation")
        private Double precipitation;

        @JsonProperty("weather_code")
        private Integer weatherCode;

        @JsonProperty("cloud_cover")
        private Integer cloudCover;

        @JsonProperty("wind_speed_10m")
        private Double windSpeed;

        @JsonProperty("wind_direction_10m")
        private Integer windDirection;

        @JsonProperty("pressure_msl")
        private Integer pressure;

        @JsonProperty("apparent_temperature")
        private Double feelsLike;
    }

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class Daily {
        @JsonProperty("time")
        private List<String> time;

        @JsonProperty("temperature_2m_max")
        private List<Double> temperatureMax;

        @JsonProperty("temperature_2m_min")
        private List<Double> temperatureMin;

        @JsonProperty("sunrise")
        private List<String> sunrise;

        @JsonProperty("sunset")
        private List<String> sunset;

        @JsonProperty("precipitation_sum")
        private List<Double> precipitationSum;
    }
}