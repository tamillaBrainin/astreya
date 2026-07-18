package com.example.astrologyanalyzer;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.HashMap;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;

import io.github.cosinekitty.astronomy.*;

/**
 * Natal chart calculator using astronomy-engine.
 */
public class NatalChartCalculator {

    private static final String[] SIGNS = {
        "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
        "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
    };

    private static final String[] PLANET_NAMES = {
        "Sun", "Moon", "Mercury", "Venus", "Mars", "Jupiter", "Saturn",
        "Uranus", "Neptune", "Pluto", "True_Node", "White_Moon", "Black_Moon", "Ascendant"
    };

    public static ArrayList<String> analyzeTransits(int year, int month, int day, double time,
                                                     String latitude, String longitude, String language) {
        int hour = (int) time;
        int minute = (int) ((time - hour) * 60);
        int second = (int) (((time - hour) * 60 - minute) * 60);
        DateTime date = new DateTime(year, month, day, hour, minute, second);
        Time t = date.toTime();
        io.github.cosinekitty.astronomy.Observer observer = new io.github.cosinekitty.astronomy.Observer(Double.parseDouble(latitude), Double.parseDouble(longitude), 0.0);

        double asc = calculateAscendant(t, observer);
        int ascSignIndex = (int)(asc / 30);
        String ascSignString = SIGNS[ascSignIndex];

        Body[] bodies = {Body.Sun, Body.Moon, Body.Mercury, Body.Venus, Body.Mars, Body.Jupiter, Body.Saturn, Body.Uranus, Body.Neptune, Body.Pluto};
        HashMap<Integer, Planet> planetDataNatal = new HashMap<>();
        ArrayList<String> descriptions = new ArrayList<>();

        for (int i = 0; i < bodies.length; i++) {
            double lon = Astronomy.eclipticLongitude(bodies[i], t);
            int signIdx = (int)(lon / 30);
            int house = determineHouse(lon, asc);
            planetDataNatal.put(i, new Planet(SIGNS[signIdx], lon));
            String desc = getPlanetDescription(PLANET_NAMES[i], SIGNS[signIdx], language);
            descriptions.add("House " + house + ": " + PLANET_NAMES[i] + " in " + SIGNS[signIdx] + "\n" + desc);
        }

        Planet ascPlanet = new Planet(ascSignString, asc);
        planetDataNatal.put(13, ascPlanet);
        descriptions.add("House 1: Ascendant in " + ascSignString + "\n" + getPlanetDescription("Ascendant", ascSignString, language));

        return descriptions;
    }

    private static double calculateAscendant(Time t, io.github.cosinekitty.astronomy.Observer observer) {
        double ramc = Astronomy.siderealTime(t) * 15.0 + observer.getLongitude();
        ramc = (ramc + 360.0) % 360.0;
        double T = t.getUt() / 36525.0;
        double eps = 23.4392911 - 0.0130004167 * T;
        double ra = Math.toRadians(ramc);
        double phi = Math.toRadians(observer.getLatitude());
        double e = Math.toRadians(eps);
        double ascRad = Math.atan2(Math.cos(ra), -(Math.sin(ra) * Math.cos(e) + Math.tan(phi) * Math.sin(e)));
        return (Math.toDegrees(ascRad) + 360) % 360;
    }

    public static int determineHouse(double planetLongitude, double ascendantLongitude) {
        double offset = (planetLongitude - ascendantLongitude + 360) % 360;
        return (int)(offset / 30) + 1;
    }

    public static ArrayList<String> calculateTransits(int natalYear, int natalMonth, int natalDay, double natalTime,
                                                       String latitude, String longitude, String language) {
        return new ArrayList<>();
    }

    public static String getPlanetDescription(String planet, String inputSign, String language) {
        String resourcePath = "sources/" + planet + language + ".csv";
        try (InputStream is = NatalChartCalculator.class.getClassLoader().getResourceAsStream(resourcePath)) {
            if (is == null) return null;
            try (Reader reader = new InputStreamReader(is, "UTF-8");
                 CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT.withFirstRecordAsHeader())) {
                for (CSVRecord record : csvParser) {
                    if (record.get("Sign").trim().equalsIgnoreCase(inputSign)) {
                        return record.get("Description").trim();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}