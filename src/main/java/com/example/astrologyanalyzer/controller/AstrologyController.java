package com.example.astrologyanalyzer.controller;

import com.example.astrologyanalyzer.dto.*;
import com.example.astrologyanalyzer.service.ChatService;
import com.example.astrologyanalyzer.service.GeocodingService;
import com.example.astrologyanalyzer.service.NatalChartService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
public class AstrologyController {

    private final NatalChartService natalChartService;
    private final ChatService chatService;
    private final GeocodingService geocodingService;

    public AstrologyController(NatalChartService natalChartService,
                                ChatService chatService,
                                GeocodingService geocodingService) {
        this.natalChartService = natalChartService;
        this.chatService = chatService;
        this.geocodingService = geocodingService;
    }

    // ── Natal Chart ──────────────────────────────────────────────
    @GetMapping("/chart")
    public ResponseEntity<?> getChart(
            @RequestParam("year") int year,
            @RequestParam("month") int month,
            @RequestParam("day") int day,
            @RequestParam("hour") int hour,
            @RequestParam("minute") int minute,
            @RequestParam("city") String city,
            @RequestParam(value = "language", defaultValue = "Eng") String language) {

        BirthDataRequest birth = buildBirthData(year, month, day, hour, minute, city, language);
        if (birth == null) {
            return ResponseEntity.badRequest().body("City not found: " + city);
        }
        return ResponseEntity.ok(natalChartService.getNatalChart(birth));
    }

    @GetMapping("/chart/interpretation")
    public ResponseEntity<?> getChartInterpretation(
            @RequestParam("year") int year,
            @RequestParam("month") int month,
            @RequestParam("day") int day,
            @RequestParam("hour") int hour,
            @RequestParam("minute") int minute,
            @RequestParam("city") String city,
            @RequestParam(value = "language", defaultValue = "Eng") String language) {

        BirthDataRequest birth = buildBirthData(year, month, day, hour, minute, city, language);
        if (birth == null) {
            return ResponseEntity.badRequest().body("City not found: " + city);
        }
        return ResponseEntity.ok(natalChartService.getNatalInterpretation(birth));
    }

    @GetMapping("/chart/enrichment")
    public ResponseEntity<?> getChartEnrichment(
            @RequestParam("year") int year,
            @RequestParam("month") int month,
            @RequestParam("day") int day,
            @RequestParam("hour") int hour,
            @RequestParam("minute") int minute,
            @RequestParam("city") String city,
            @RequestParam(value = "language", defaultValue = "Eng") String language) {

        BirthDataRequest birth = buildBirthData(year, month, day, hour, minute, city, language);
        if (birth == null) {
            return ResponseEntity.badRequest().body("City not found: " + city);
        }
        return ResponseEntity.ok(natalChartService.getNatalEnrichment(birth));
    }

    // ── Daily Energy (Home page card) ────────────────────────────
    @GetMapping("/daily/energy")
    public DailyEnergyResponse getDailyEnergy() {
        return natalChartService.getDailyEnergy();
    }

    // ── Transits list ────────────────────────────────────────────
    @GetMapping("/transits")
    public ResponseEntity<?> getTransits(
            @RequestParam("year") int year,
            @RequestParam("month") int month,
            @RequestParam("day") int day,
            @RequestParam("hour") int hour,
            @RequestParam("minute") int minute,
            @RequestParam("city") String city,
            @RequestParam(value = "language", defaultValue = "Eng") String language) {

        BirthDataRequest birth = buildBirthData(year, month, day, hour, minute, city, language);
        if (birth == null) {
            return ResponseEntity.badRequest().body("City not found: " + city);
        }
        return ResponseEntity.ok(natalChartService.getTransits(birth));
    }

    // ── AI Chat ──────────────────────────────────────────────────
    @PostMapping("/chat/message")
    public ChatResponse chat(@RequestBody ChatRequest request) {
        return chatService.chat(request.getMessage(), request.getLanguage());
    }

    // ── Helper: build BirthDataRequest with geocoding ────────────
    private BirthDataRequest buildBirthData(int year, int month, int day,
                                             int hour, int minute,
                                             String city, String language) {
        double[] coords = geocodingService.getCoordinates(city);
        if (coords == null) {
            return null;
        }

        double longitude = coords[1];
        double utcOffset = resolveUtcOffset(city, longitude);

        BirthDataRequest birth = new BirthDataRequest();
        birth.setYear(year);
        birth.setMonth(month);
        birth.setDay(day);
        birth.setHour(hour);
        birth.setMinute(minute);
        birth.setCity(city);
        birth.setLatitude(coords[0]);
        birth.setLongitude(longitude);
        birth.setLanguage(language);
        birth.setUtcOffset(utcOffset);
        return birth;
    }

    /**
     * UTC offsets that differ from simple geographic rounding.
     * Key = lowercase city name, value = UTC offset in hours.
     */
    private static final java.util.Map<String, Double> CITY_UTC_OVERRIDE =
        new java.util.HashMap<>(java.util.Map.ofEntries(
            // Soviet "decree time": Uzbekistan was UTC+6 from 1930 to 1991
            java.util.Map.entry("tashkent",  6.0),
            java.util.Map.entry("samarkand", 6.0),
            java.util.Map.entry("bukhara",   6.0),
            java.util.Map.entry("namangan",  6.0),
            java.util.Map.entry("andijan",   6.0),
            java.util.Map.entry("almaty",    6.0),
            java.util.Map.entry("astana",    6.0),
            java.util.Map.entry("bishkek",   6.0),
            java.util.Map.entry("dushanbe",  6.0),
            java.util.Map.entry("ashgabat",  5.0),
            // India: UTC+5:30 → round to 5.5
            java.util.Map.entry("mumbai",    5.5),
            java.util.Map.entry("delhi",     5.5),
            java.util.Map.entry("kolkata",   5.5),
            // Iran: UTC+3:30 → round to 3.5
            java.util.Map.entry("tehran",    3.5)
        ));

    private double resolveUtcOffset(String city, double longitude) {
        String key = city.toLowerCase().trim();
        Double override = CITY_UTC_OVERRIDE.get(key);
        if (override != null) return override;
        return Math.round(longitude / 15.0);
    }
}