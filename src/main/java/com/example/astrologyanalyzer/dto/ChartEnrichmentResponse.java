package com.example.astrologyanalyzer.dto;

import java.util.Collections;
import java.util.Map;

public class ChartEnrichmentResponse {
    private Map<String, String> planetaryInterpretations;
    private Map<String, String> patternInterpretations;
    private Map<String, String> aspectInterpretations;

    public ChartEnrichmentResponse() {
        this(Collections.emptyMap(), Collections.emptyMap(), Collections.emptyMap());
    }

    public ChartEnrichmentResponse(
            Map<String, String> planetaryInterpretations,
            Map<String, String> patternInterpretations,
            Map<String, String> aspectInterpretations
    ) {
        this.planetaryInterpretations = planetaryInterpretations;
        this.patternInterpretations = patternInterpretations;
        this.aspectInterpretations = aspectInterpretations;
    }

    public Map<String, String> getPlanetaryInterpretations() {
        return planetaryInterpretations;
    }

    public void setPlanetaryInterpretations(Map<String, String> planetaryInterpretations) {
        this.planetaryInterpretations = planetaryInterpretations;
    }

    public Map<String, String> getPatternInterpretations() {
        return patternInterpretations;
    }

    public void setPatternInterpretations(Map<String, String> patternInterpretations) {
        this.patternInterpretations = patternInterpretations;
    }

    public Map<String, String> getAspectInterpretations() {
        return aspectInterpretations;
    }

    public void setAspectInterpretations(Map<String, String> aspectInterpretations) {
        this.aspectInterpretations = aspectInterpretations;
    }
}
