package com.example.astrologyanalyzer.dto;

public class ChartInterpretationResponse {
    private String interpretation;

    public ChartInterpretationResponse() {
    }

    public ChartInterpretationResponse(String interpretation) {
        this.interpretation = interpretation;
    }

    public String getInterpretation() {
        return interpretation;
    }

    public void setInterpretation(String interpretation) {
        this.interpretation = interpretation;
    }
}
