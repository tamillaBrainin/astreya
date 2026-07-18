package com.example.astrologyanalyzer.service;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

@Service
public class GeocodingService {

    private static final Map<String, double[]> CITY_FALLBACK = new HashMap<>();
    static {
        CITY_FALLBACK.put("tashkent",         new double[]{ 41.2995,  69.2401 });
        CITY_FALLBACK.put("moscow",           new double[]{ 55.7558,  37.6176 });
        CITY_FALLBACK.put("saint petersburg", new double[]{ 59.9311,  30.3609 });
        CITY_FALLBACK.put("kyiv",             new double[]{ 50.4501,  30.5234 });
        CITY_FALLBACK.put("kiev",             new double[]{ 50.4501,  30.5234 });
        CITY_FALLBACK.put("london",           new double[]{ 51.5074,  -0.1278 });
        CITY_FALLBACK.put("paris",            new double[]{ 48.8566,   2.3522 });
        CITY_FALLBACK.put("berlin",           new double[]{ 52.5200,  13.4050 });
        CITY_FALLBACK.put("new york",         new double[]{ 40.7128, -74.0060 });
        CITY_FALLBACK.put("los angeles",      new double[]{ 34.0522,-118.2437 });
        CITY_FALLBACK.put("tokyo",            new double[]{ 35.6762, 139.6503 });
        CITY_FALLBACK.put("dubai",            new double[]{ 25.2048,  55.2708 });
        CITY_FALLBACK.put("istanbul",         new double[]{ 41.0082,  28.9784 });
        CITY_FALLBACK.put("almaty",           new double[]{ 43.2220,  76.8512 });
        CITY_FALLBACK.put("baku",             new double[]{ 40.4093,  49.8671 });
        CITY_FALLBACK.put("tbilisi",          new double[]{ 41.6938,  44.8015 });
        CITY_FALLBACK.put("minsk",            new double[]{ 53.9045,  27.5615 });
        CITY_FALLBACK.put("yerevan",          new double[]{ 40.1872,  44.5152 });
        CITY_FALLBACK.put("astana",           new double[]{ 51.1801,  71.4460 });
        CITY_FALLBACK.put("bishkek",          new double[]{ 42.8746,  74.5698 });
        CITY_FALLBACK.put("dushanbe",         new double[]{ 38.5598,  68.7733 });
        CITY_FALLBACK.put("ashgabat",         new double[]{ 37.9601,  58.3261 });
        CITY_FALLBACK.put("rome",             new double[]{ 41.9028,  12.4964 });
        CITY_FALLBACK.put("madrid",           new double[]{ 40.4168,  -3.7038 });
        CITY_FALLBACK.put("amsterdam",        new double[]{ 52.3676,   4.9041 });
        CITY_FALLBACK.put("warsaw",           new double[]{ 52.2297,  21.0122 });
        CITY_FALLBACK.put("prague",           new double[]{ 50.0755,  14.4378 });
        CITY_FALLBACK.put("vienna",           new double[]{ 48.2082,  16.3738 });
        CITY_FALLBACK.put("sydney",           new double[]{-33.8688, 151.2093 });
        CITY_FALLBACK.put("toronto",          new double[]{ 43.6532, -79.3832 });
        CITY_FALLBACK.put("mumbai",           new double[]{ 19.0760,  72.8777 });
        CITY_FALLBACK.put("delhi",            new double[]{ 28.7041,  77.1025 });
        CITY_FALLBACK.put("tel aviv",         new double[]{ 32.0853,  34.7818 });
        CITY_FALLBACK.put("tel aviv-yafo",    new double[]{ 32.0853,  34.7818 });
        CITY_FALLBACK.put("jerusalem",        new double[]{ 31.7683,  35.2137 });
        CITY_FALLBACK.put("haifa",            new double[]{ 32.7940,  34.9896 });
    }

    public double[] getCoordinates(String city) {
        String normalizedCity = city.toLowerCase().trim();
        double[] fallback = CITY_FALLBACK.get(normalizedCity);
        if (fallback != null) {
            System.out.println("Geocoding fallback for \"" + city + "\" -> lat=" + fallback[0] + ", lon=" + fallback[1]);
            return fallback;
        }

        try {
            String encodedCity = URLEncoder.encode(city, "UTF-8");
            String url = "https://nominatim.openstreetmap.org/search?q=" + encodedCity + "&format=json&limit=1";

            HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();
            connection.setConnectTimeout(5000);
            connection.setReadTimeout(5000);
            connection.setRequestProperty("User-Agent", "AstrologyAnalyzer/1.0");

            BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            StringBuilder jsonResult = new StringBuilder();
            String line;
            while ((line = in.readLine()) != null) {
                jsonResult.append(line);
            }
            in.close();

            JSONArray results = new JSONArray(jsonResult.toString());
            if (results.length() > 0) {
                JSONObject location = results.getJSONObject(0);
                double lat = Double.parseDouble(location.getString("lat"));
                double lon = Double.parseDouble(location.getString("lon"));
                System.out.println("Geocoded \"" + city + "\" → lat=" + lat + ", lon=" + lon);
                return new double[]{lat, lon};
            }
            // nominatim returned empty results — fall through to fallback
        } catch (Exception e) {
            System.err.println("Geocoding error for \"" + city + "\": " + e.getMessage() + " -- trying fallback");
        }
        // Fallback: built-in city coordinate map
        fallback = CITY_FALLBACK.get(normalizedCity);
        if (fallback != null) {
            System.out.println("Geocoding fallback for \"" + city + "\" -> lat=" + fallback[0] + ", lon=" + fallback[1]);
            return fallback;
        }
        System.err.println("Geocoding: city not found -- \"" + city + "\"");
        return null;
    }
}
