package com.example.astrologyanalyzer;

import io.github.cosinekitty.astronomy.*;

/**
 * House Calculator using astronomy-engine.
 * Displays a formatted console table of natal chart with Whole Sign houses.
 */
public class HouseCalculator {

    private static final String[] SIGNS = {
        "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
        "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
    };

    private static double calculateAscendant(Time t, io.github.cosinekitty.astronomy.Observer observer) {
        double ramc = Astronomy.siderealTime(t) * 15.0 + observer.getLongitude();
        ramc = (ramc + 360.0) % 360.0;
        double eps = t.nutationEps();
        double ra = Math.toRadians(ramc);
        double phi = Math.toRadians(observer.getLatitude());
        double e = Math.toRadians(eps);
        double ascRad = Math.atan2(Math.cos(ra), -(Math.sin(ra) * Math.cos(e) + Math.tan(phi) * Math.sin(e)));
        return (Math.toDegrees(ascRad) + 360) % 360;
    }

    public static double calculateHouseCusp(int house, Time t, io.github.cosinekitty.astronomy.Observer observer) {
        double ramc = Astronomy.siderealTime(t) * 15.0 + observer.getLongitude();
        ramc = (ramc + 360.0) % 360.0;
        double eps = t.nutationEps();
        double ra = Math.toRadians(ramc);
        double phi = Math.toRadians(observer.getLatitude());
        double e = Math.toRadians(eps);

        // Calculate the house cusp using the Ascendant and the house number
        double cusp = (Math.toDegrees(ra) + 360) % 360;
        cusp += (house - 1) * 30; // Each house is 30 degrees
        cusp = cusp % 360;

        return cusp;
    }

    public static void getPlanetHouses(int year, int month, int day, double time,
                                        String latitude, String longitude) {

        int hour = (int) time;
        int minute = (int) ((time - hour) * 60);
        int second = (int) (((time - hour) * 60 - minute) * 60);
        
        DateTime date = new DateTime(year, month, day, hour, minute, second);
        Time t = date.toTime();
        io.github.cosinekitty.astronomy.Observer observer = new io.github.cosinekitty.astronomy.Observer(Double.parseDouble(latitude), Double.parseDouble(longitude), 0.0);

        // Whole Sign House System calculation starts with the Ascendant
        // In astronomy-engine, we can compute the sidereal time and then the Ascendant
        
        // Actually, let's use a more direct approach if possible or keep the placeholder.
        
        double ascendant = calculateAscendant(t, observer); 
        int ascSignIndex = (int)(ascendant / 30);

        System.out.println("╔══════════════════════════════════════════════════════════════╗");
        System.out.println("║                  NATAL CHART - WHOLE SIGN HOUSES            ║");
        System.out.println("╠══════════════════════════════════════════════════════════════╣");
        System.out.printf("║  Ascendant: %s %.2f°%n", SIGNS[ascSignIndex], ascendant % 30);
        System.out.println("╠══════════════════════════════════════════════════════════════╣");
        System.out.printf("║  %-12s %-6s %-14s %-8s %-10s%n", "Planet", "House", "Sign", "Degree", "Status");
        System.out.println("╠══════════════════════════════════════════════════════════════╣");

        Body[] bodies = {
            Body.Sun, Body.Moon, Body.Mercury,
            Body.Venus, Body.Mars, Body.Jupiter,
            Body.Saturn, Body.Uranus, Body.Neptune,
            Body.Pluto
        };

        String[] planetNames = {"Sun", "Moon", "Mercury", "Venus", "Mars",
                                "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"};

        for (int i = 0; i < bodies.length; i++) {
            double lon = Astronomy.eclipticLongitude(bodies[i], t);
            
            // For retrograde, we check velocity
            double lonNext = Astronomy.eclipticLongitude(bodies[i], t.addDays(0.1));
            boolean isRetrograde = lonNext < lon;
            // Handle wrap around
            if (Math.abs(lonNext - lon) > 180) {
                isRetrograde = !isRetrograde;
            }

            int house = NatalChartCalculator.determineHouse(lon, ascendant);
            int signIndex = (int)(lon / 30);
            String sign = SIGNS[signIndex];
            double degreeInSign = lon % 30;
            String retroStatus = isRetrograde ? "Retrograde" : "Direct";

            System.out.printf("║  %-12s %-6d %-14s %-8.2f %-10s%n",
                    planetNames[i], house, sign, degreeInSign, retroStatus);
        }
        System.out.println("╚══════════════════════════════════════════════════════════════╝");
    }

    public static double getSiderealTime(Time t, double longitude) {
        double st = Astronomy.siderealTime(t) * 15.0 + longitude;
        return (st + 360.0) % 360.0;
    }
}