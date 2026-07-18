package com.example.astrologyanalyzer;

import java.util.ArrayList;

public class AstrologyAnalyzer {

    public static ArrayList<String> analyzeTransits(int year, int month, int day, double time,
                                                     String latitude, String longitude, String language) {
        return NatalChartCalculator.analyzeTransits(year, month, day, time, latitude, longitude, language);
    }
}
