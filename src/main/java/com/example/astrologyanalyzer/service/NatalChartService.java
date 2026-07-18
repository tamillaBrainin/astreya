package com.example.astrologyanalyzer.service;

import com.example.astrologyanalyzer.dto.*;
import com.example.astrologyanalyzer.dto.ChartResponse.HouseInfo;
import com.example.astrologyanalyzer.dto.ChartResponse.ParsFortunaInfo;
import com.example.astrologyanalyzer.dto.TransitResponse.TransitItem;
import com.example.astrologyanalyzer.NatalChartCalculator;
import org.springframework.stereotype.Service;
import io.github.cosinekitty.astronomy.*;
import io.github.cosinekitty.astronomy.Observer;

import java.time.*;
import java.util.*;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.LinkedHashMap;

@Service
public class NatalChartService {

    private final ChatService chatService;

    public NatalChartService(ChatService chatService) {
        this.chatService = chatService;
    }

    private static final String[] SIGNS = {
        "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
        "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
    };

    public ChartResponse getNatalChart(BirthDataRequest birth) {
        // Convert local time → UT
        LocalDateTime localDt = LocalDateTime.of(
            birth.getYear(), birth.getMonth(), birth.getDay(),
            birth.getHour(), birth.getMinute(), 0);
        ZoneOffset zoneOffset = ZoneOffset.ofTotalSeconds((int)(birth.getUtcOffset() * 3600));
        LocalDateTime utDt = OffsetDateTime.of(localDt, zoneOffset)
                .withOffsetSameInstant(ZoneOffset.UTC).toLocalDateTime();

        DateTime date = new DateTime(utDt.getYear(), utDt.getMonthValue(), utDt.getDayOfMonth(),
                utDt.getHour(), utDt.getMinute(), 0);
        Time t = date.toTime();

        io.github.cosinekitty.astronomy.Observer observer = new io.github.cosinekitty.astronomy.Observer(birth.getLatitude(), birth.getLongitude(), 0.0);

        double asc = calculateAscendant(t, observer);
        double mc = calculateMidheaven(t, observer);
        int ascSignIdx = (int) (asc / 30);
        int mcSignIdx = (int) (mc / 30);

        System.out.println("ASC: " + SIGNS[ascSignIdx] + " " + String.format("%.2f", asc % 30) + "°  MC: " + SIGNS[mcSignIdx] + " " + String.format("%.2f", mc % 30) + "°");

        ChartResponse resp = new ChartResponse();
        resp.setAscendant(round2(asc));
        resp.setAscendantSign(SIGNS[ascSignIdx]);
        resp.setMc(round2(mc));
        resp.setMcSign(SIGNS[mcSignIdx]);

        // ── Placidus house cusps ──────────────────────────────────────────────
        double ramcVal = (Astronomy.siderealTime(t) * 15.0 + observer.getLongitude() + 360.0) % 360.0;
        double epsVal  = 23.4392911 - 0.0130004167 * (t.getUt() / 36525.0);
        double[] placidus = calculatePlacidusHouseCusps(asc, mc, ramcVal, epsVal, birth.getLatitude());

        List<HouseInfo> housesList = new ArrayList<>();
        for (int h = 0; h < 12; h++) {
            double cusp = (placidus[h] + 360) % 360;
            int signIdx = (int)(cusp / 30);
            housesList.add(new HouseInfo(h + 1, SIGNS[signIdx], round2(cusp)));
        }
        resp.setHouses(housesList);

        Body[] bodies = {Body.Sun, Body.Moon, Body.Mercury, Body.Venus, Body.Mars, Body.Jupiter, Body.Saturn, Body.Uranus, Body.Neptune, Body.Pluto};
        String[] planetNames = {"Sun", "Moon", "Mercury", "Venus", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"};

        List<PlanetPosition> planets = new ArrayList<>();
        double sunLong = 0, moonLong = 0;

        for (int i = 0; i < bodies.length; i++) {
            double lon = geocentricLongitude(bodies[i], t);
            int signIdx = (int) (lon / 30);
            double deg = lon % 30;
            int house = houseFromCusps(lon, placidus);

            double lonNext = geocentricLongitude(bodies[i], t.addDays(0.1));
            boolean retro = lonNext < lon;
            if (Math.abs(lonNext - lon) > 180) retro = !retro;

            planets.add(new PlanetPosition(planetNames[i], SIGNS[signIdx], round2(deg), round2(lon), house, retro));
            System.out.printf("  %-10s %-13s %5.2f°  house %d%s%n", planetNames[i], SIGNS[signIdx], deg, house, retro ? " R" : "");
            if (i == 0) sunLong = lon;
            if (i == 1) moonLong = lon;
        }

        planets.add(new PlanetPosition("Ascendant", SIGNS[ascSignIdx], round2(asc % 30), round2(asc), 1, false));
        resp.setPlanets(planets);

        double pf = (asc + moonLong - sunLong + 360) % 360;
        int pfHouse = houseFromCusps(pf, placidus);
        resp.setParsFortuna(new ParsFortunaInfo(round2(pf), SIGNS[(int)(pf/30)], pfHouse));
        System.out.printf("  %-10s %-13s %5.2f°  house %d%n", "ParsFortuna", SIGNS[(int)(pf/30)], pf % 30, pfHouse);

        resp.setPatterns(detectPatterns(planets));
        resp.setAspects(calculateAspects(planets));

        // Extra points without Swiss Ephemeris:
        // - True North/South Node (from lunar node events)
        // - Lilith approximation (nearest lunar apogee longitude)
        try {
            double northNodeLon = approximateNorthNodeLongitude(t);
            double southNodeLon = (northNodeLon + 180.0) % 360.0;
            int nnHouse = houseFromCusps(northNodeLon, placidus);
            int snHouse = houseFromCusps(southNodeLon, placidus);

            planets.add(new PlanetPosition(
                    "North Node",
                    SIGNS[(int) (northNodeLon / 30.0)],
                    round2(northNodeLon % 30.0),
                    round2(northNodeLon),
                    nnHouse,
                    false));

            planets.add(new PlanetPosition(
                    "South Node",
                    SIGNS[(int) (southNodeLon / 30.0)],
                    round2(southNodeLon % 30.0),
                    round2(southNodeLon),
                    snHouse,
                    false));
        } catch (Exception e) {
            System.err.println("Node calculation warning: " + e.getMessage());
        }

        try {
            double lilithLon = approximateLilithLongitude(t);
            int lilithHouse = houseFromCusps(lilithLon, placidus);
            planets.add(new PlanetPosition(
                    "Lilith",
                    SIGNS[(int) (lilithLon / 30.0)],
                    round2(lilithLon % 30.0),
                    round2(lilithLon),
                    lilithHouse,
                    false));
        } catch (Exception e) {
            System.err.println("Lilith calculation warning: " + e.getMessage());
        }

        resp.setInterpretation("");
        resp.setPlanetaryInterpretations(java.util.Collections.emptyMap());
        resp.setPatternInterpretations(java.util.Collections.emptyMap());
        resp.setAspectInterpretations(java.util.Collections.emptyMap());

        return resp;
    }

    public ChartInterpretationResponse getNatalInterpretation(BirthDataRequest birth) {
        ChartResponse chart = getNatalChart(birth);
        String language = birth.getLanguage() != null ? birth.getLanguage() : "Eng";
        String natalData = buildNatalData(chart);
        String interpretation = chatService.getInterpretation(natalData, language);
        if (interpretation == null || interpretation.isBlank()) {
            interpretation = buildFallbackInterpretation(chart.getPlanets(), language);
        }
        return new ChartInterpretationResponse(interpretation);
    }

    public ChartEnrichmentResponse getNatalEnrichment(BirthDataRequest birth) {
        ChartResponse chart = getNatalChart(birth);
        String language = birth.getLanguage() != null ? birth.getLanguage() : "Eng";

        Map<String, String> planetary = chatService.getPlanetaryInterpretations(chart.getPlanets(), language);
        Map<String, String> patterns = chatService.getPatternInterpretations(chart.getPatterns(), language);
        Map<String, String> aspects = chatService.getAspectInterpretations(chart.getAspects(), language);

        return new ChartEnrichmentResponse(planetary, patterns, aspects);
    }

    private String buildNatalData(ChartResponse chart) {
        StringBuilder natalData = new StringBuilder();

        natalData.append("ANGLES\n");
        natalData.append("Ascendant: ")
                .append(chart.getAscendantSign())
                .append(" ")
                .append(String.format(Locale.US, "%.2f", chart.getAscendant() % 30))
                .append("°\n");
        natalData.append("MC: ")
                .append(chart.getMcSign())
                .append(" ")
                .append(String.format(Locale.US, "%.2f", chart.getMc() % 30))
                .append("°\n");

        if (chart.getParsFortuna() != null) {
            natalData.append("Pars Fortuna: ")
                    .append(chart.getParsFortuna().getSign())
                    .append(" (House ")
                    .append(chart.getParsFortuna().getHouse())
                    .append(")\n");
        }

        natalData.append("\nPLANETS\n");
        if (chart.getPlanets() != null) {
            for (PlanetPosition p : chart.getPlanets()) {
                natalData.append(p.getName()).append(" in ").append(p.getSign())
                        .append(" (House ").append(p.getHouse()).append(", ")
                        .append(String.format(Locale.US, "%.2f", p.getDegrees())).append("°")
                        .append(p.isRetrograde() ? ", Retrograde" : "")
                        .append(")\n");
            }
        }

        natalData.append("\nHOUSES\n");
        if (chart.getHouses() != null) {
            for (HouseInfo house : chart.getHouses()) {
                natalData.append("House ")
                        .append(house.getNumber())
                        .append(": ")
                        .append(house.getSign())
                        .append(" (cusp ")
                        .append(String.format(Locale.US, "%.2f", house.getCusp() % 30))
                        .append("°)\n");
            }
        }

        natalData.append("\nMAJOR ASPECTS\n");
        if (chart.getAspects() != null && !chart.getAspects().isEmpty()) {
            List<ChartResponse.AspectInfo> sorted = new ArrayList<>(chart.getAspects());
            sorted.sort(Comparator.comparingDouble(ChartResponse.AspectInfo::getOrb));
            int max = Math.min(12, sorted.size());
            for (int i = 0; i < max; i++) {
                ChartResponse.AspectInfo a = sorted.get(i);
                natalData.append(a.getPlanet1())
                        .append(" ")
                        .append(a.getAspect())
                        .append(" ")
                        .append(a.getPlanet2())
                        .append(" (orb ")
                        .append(String.format(Locale.US, "%.2f", a.getOrb()))
                        .append("°)\n");
            }
        } else {
            natalData.append("none\n");
        }

        natalData.append("\nCONFIGURATIONS\n");
        if (chart.getPatterns() != null && !chart.getPatterns().isEmpty()) {
            for (String p : chart.getPatterns()) {
                natalData.append("- ").append(p).append("\n");
            }
        } else {
            natalData.append("none\n");
        }

        return natalData.toString();
    }

    private String buildFallbackInterpretation(List<PlanetPosition> planets, String language) {
        PlanetPosition sun = findPlanet(planets, "Sun");
        PlanetPosition moon = findPlanet(planets, "Moon");
        PlanetPosition ascendant = findPlanet(planets, "Ascendant");
        PlanetPosition jupiter = findPlanet(planets, "Jupiter");
        PlanetPosition saturn = findPlanet(planets, "Saturn");

        String sunSign = sun != null ? sun.getSign() : "Unknown";
        String moonSign = moon != null ? moon.getSign() : "Unknown";
        String ascSign = ascendant != null ? ascendant.getSign() : "Unknown";
        int sunHouse = sun != null ? sun.getHouse() : 0;
        int moonHouse = moon != null ? moon.getHouse() : 0;

        switch (language) {
            case "Rus":
                return String.format(
                        "Ваш основной астрологический рисунок сочетает Солнце в %s, Луну в %s и Асцендент в %s. Это дает смесь %s, %s и %s.\n\n"
                                + "Главные жизненные темы раскрываются через %s и %s. %s %s",
                        sunSign,
                        moonSign,
                        ascSign,
                        getSunTrait(sunSign, language),
                        getMoonTrait(moonSign, language),
                        getAscTrait(ascSign, language),
                        describeHouseFocus(sunHouse, "identity", language),
                        describeHouseFocus(moonHouse, "emotions", language),
                        describePlanetSupport(jupiter, language),
                        describePlanetChallenge(saturn, language));
            case "Heb":
                return String.format(
                        "המבנה המרכזי של המפה שלך משלב שמש ב-%s, ירח ב-%s ואופק ב-%s. השילוב הזה יוצר אופי של %s, %s ו-%s.\n\n"
                                + "הנושאים המרכזיים בחיים מודגשים דרך %s ו-%s. %s %s",
                        sunSign,
                        moonSign,
                        ascSign,
                        getSunTrait(sunSign, language),
                        getMoonTrait(moonSign, language),
                        getAscTrait(ascSign, language),
                        describeHouseFocus(sunHouse, "identity", language),
                        describeHouseFocus(moonHouse, "emotions", language),
                        describePlanetSupport(jupiter, language),
                        describePlanetChallenge(saturn, language));
            case "Spa":
                return String.format(
                        "Tu firma central combina Sol en %s, Luna en %s y Ascendente en %s. Esto crea una mezcla de %s, %s y %s.\n\n"
                                + "Los temas principales de vida se activan a traves de %s y %s. %s %s",
                        sunSign,
                        moonSign,
                        ascSign,
                        getSunTrait(sunSign, language),
                        getMoonTrait(moonSign, language),
                        getAscTrait(ascSign, language),
                        describeHouseFocus(sunHouse, "identity", language),
                        describeHouseFocus(moonHouse, "emotions", language),
                        describePlanetSupport(jupiter, language),
                        describePlanetChallenge(saturn, language));
            default:
                return String.format(
                        "Your core signature blends a %s Sun, %s Moon, and %s Rising. This points to a personality that is %s, emotionally %s, and outwardly %s.\n\n"
                                + "The chart puts extra emphasis on %s and %s. %s %s",
                        sunSign,
                        moonSign,
                        ascSign,
                        getSunTrait(sunSign, language),
                        getMoonTrait(moonSign, language),
                        getAscTrait(ascSign, language),
                        describeHouseFocus(sunHouse, "identity", language),
                        describeHouseFocus(moonHouse, "emotions", language),
                        describePlanetSupport(jupiter, language),
                        describePlanetChallenge(saturn, language));
        }
    }

    private PlanetPosition findPlanet(List<PlanetPosition> planets, String name) {
        for (PlanetPosition planet : planets) {
            if (name.equals(planet.getName())) {
                return planet;
            }
        }
        return null;
    }

    private String getSunTrait(String sign, String language) {
        switch (sign) {
            case "Aries": return translate(language, "direct and courageous", "прямой и смелый", "ישיר ואמיץ", "directo y valiente");
            case "Taurus": return translate(language, "steady and grounded", "устойчивый и практичный", "יציב ומקורקע", "estable y con los pies en la tierra");
            case "Gemini": return translate(language, "curious and mentally quick", "любознательный и быстрый умом", "סקרן ומהיר מחשבה", "curioso y mentalmente rapido");
            case "Cancer": return translate(language, "protective and sensitive", "заботливый и чувствительный", "מגן ורגיש", "protector y sensible");
            case "Leo": return translate(language, "creative and radiant", "творческий и яркий", "יצירתי וזוהר", "creativo y radiante");
            case "Virgo": return translate(language, "observant and thoughtful", "наблюдательный и вдумчивый", "קשוב ועמוק", "observador y reflexivo");
            case "Libra": return translate(language, "diplomatic and relationship-oriented", "дипломатичный и ориентированный на отношения", "דיפלומטי ומכוון קשרים", "diplomatico y orientado a las relaciones");
            case "Scorpio": return translate(language, "intense and transformative", "глубокий и трансформирующий", "עוצמתי ומשנה", "intenso y transformador");
            case "Sagittarius": return translate(language, "idealistic and expansive", "идеалистичный и широкий", "אידיאליסטי ומתרחב", "idealista y expansivo");
            case "Capricorn": return translate(language, "disciplined and ambitious", "дисциплинированный и амбициозный", "ממושמע ושאפתן", "disciplinado y ambicioso");
            case "Aquarius": return translate(language, "independent and future-minded", "независимый и устремленный в будущее", "עצמאי וחושב קדימה", "independiente y orientado al futuro");
            case "Pisces": return translate(language, "intuitive and imaginative", "интуитивный и воображающий", "אינטואיטיבי ובעל דמיון", "intuitivo e imaginativo");
            default: return translate(language, "complex", "сложный", "מורכב", "complejo");
        }
    }

    private String getMoonTrait(String sign, String language) {
        switch (sign) {
            case "Aries": return translate(language, "fast-reacting and fiery", "быстро реагирующий и огненный", "מגיב מהר וסוער", "reactivo y fogoso");
            case "Taurus": return translate(language, "stable and comfort-seeking", "стабильный и ищущий комфорт", "יציב ומחפש נוחות", "estable y orientado a la comodidad");
            case "Gemini": return translate(language, "restless and expressive", "подвижный и выразительный", "חסר מנוחה ומבטא", "inquieto y expresivo");
            case "Cancer": return translate(language, "deeply nurturing", "очень заботливый", "מטפח מאוד", "profundamente nutritivo");
            case "Leo": return translate(language, "warm and proud", "теплый и гордый", "חם וגאה", "calido y orgulloso");
            case "Virgo": return translate(language, "careful and self-aware", "осторожный и самонаблюдательный", "זהיר ומודע לעצמו", "cuidadoso y consciente de si");
            case "Libra": return translate(language, "harmonizing and relational", "гармонизирующий и партнерский", "שואף להרמוניה ולקשר", "armonizador y relacional");
            case "Scorpio": return translate(language, "intense and private", "интенсивный и закрытый", "עוצמתי ופרטי", "intenso y reservado");
            case "Sagittarius": return translate(language, "optimistic and freedom-seeking", "оптимистичный и любящий свободу", "אופטימי ואוהב חופש", "optimista y amante de la libertad");
            case "Capricorn": return translate(language, "contained and responsible", "сдержанный и ответственный", "מאופק ואחראי", "contenido y responsable");
            case "Aquarius": return translate(language, "detached yet idealistic", "отстраненный, но идеалистичный", "מרוחק אך אידיאליסטי", "distante pero idealista");
            case "Pisces": return translate(language, "porous and empathic", "очень эмпатичный", "אמפתי מאוד", "permeable y empatico");
            default: return translate(language, "layered", "многослойный", "רב שכבתי", "matizado");
        }
    }

    private String getAscTrait(String sign, String language) {
        switch (sign) {
            case "Aries": return translate(language, "bold", "смелый", "נועז", "atrevido");
            case "Taurus": return translate(language, "steady", "устойчивый", "יציב", "constante");
            case "Gemini": return translate(language, "adaptable", "гибкий", "מסתגל", "adaptable");
            case "Cancer": return translate(language, "protective", "защитный", "מגן", "protector");
            case "Leo": return translate(language, "charismatic", "харизматичный", "כריזמטי", "carismatico");
            case "Virgo": return translate(language, "precise", "точный", "מדויק", "preciso");
            case "Libra": return translate(language, "graceful", "изящный", "אלגנטי", "armonioso");
            case "Scorpio": return translate(language, "magnetic", "магнетичный", "מגנטי", "magnetico");
            case "Sagittarius": return translate(language, "open and adventurous", "открытый и авантюрный", "פתוח והרפתקני", "abierto y aventurero");
            case "Capricorn": return translate(language, "serious and composed", "собранный и серьезный", "רציני ומאופק", "serio y compuesto");
            case "Aquarius": return translate(language, "unconventional", "нестандартный", "לא שגרתי", "poco convencional");
            case "Pisces": return translate(language, "soft and intuitive", "мягкий и интуитивный", "רך ואינטואיטיבי", "suave e intuitivo");
            default: return translate(language, "distinctive", "особенный", "ייחודי", "particular");
        }
    }

    private String describeHouseFocus(int house, String focusType, String language) {
        String area;
        switch (house) {
            case 1: area = translate(language, "self-definition and personal presence", "самоопределение и личное присутствие", "זהות ונוכחות אישית", "identidad y presencia personal"); break;
            case 2: area = translate(language, "values, money, and self-worth", "ценности, деньги и самооценка", "ערך עצמי, כסף ומשאבים", "valores, dinero y autoestima"); break;
            case 3: area = translate(language, "communication, learning, and everyday movement", "общение, обучение и повседневные связи", "תקשורת, למידה ותנועה יומיומית", "comunicacion, aprendizaje y movimiento diario"); break;
            case 4: area = translate(language, "home, roots, and emotional foundations", "дом, корни и эмоциональная опора", "בית, שורשים ובסיס רגשי", "hogar, raices y base emocional"); break;
            case 5: area = translate(language, "creativity, romance, and self-expression", "творчество, романтика и самовыражение", "יצירה, רומנטיקה וביטוי עצמי", "creatividad, romance y expresion personal"); break;
            case 6: area = translate(language, "work, routines, and wellbeing", "работа, режим и здоровье", "עבודה, שגרה ורווחה", "trabajo, rutinas y bienestar"); break;
            case 7: area = translate(language, "partnerships and reflection through others", "партнерство и отражение через других", "שותפויות ולמידה דרך אחרים", "pareja y reflejo a traves de otros"); break;
            case 8: area = translate(language, "shared resources, trust, and transformation", "общие ресурсы, доверие и трансформация", "משאבים משותפים, אמון וטרנספורמציה", "recursos compartidos, confianza y transformacion"); break;
            case 9: area = translate(language, "travel, belief, and expansion of perspective", "путешествия, вера и расширение горизонтов", "מסע, אמונה והרחבת אופקים", "viajes, creencias y expansion de perspectiva"); break;
            case 10: area = translate(language, "career, reputation, and direction", "карьера, репутация и направление", "קריירה, מוניטין וכיוון", "carrera, reputacion y direccion"); break;
            case 11: area = translate(language, "community, friendships, and future goals", "сообщество, друзья и цели будущего", "קהילה, חברויות ומטרות עתידיות", "comunidad, amistades y metas futuras"); break;
            case 12: area = translate(language, "inner life, healing, and surrender", "внутренний мир, исцеление и отпускание", "עולם פנימי, ריפוי ושחרור", "vida interior, sanacion y entrega"); break;
            default: area = translate(language, "important life themes", "важные жизненные темы", "נושאי חיים חשובים", "temas importantes de vida"); break;
        }

        if ("emotions".equals(focusType)) {
            return translate(language,
                    "emotional security around " + area,
                    "эмоциональная устойчивость через " + area,
                    "ביטחון רגשי סביב " + area,
                    "seguridad emocional alrededor de " + area);
        }

        return translate(language,
                "identity and purpose through " + area,
                "самореализацию через " + area,
                "זהות ומטרה דרך " + area,
                "identidad y proposito a traves de " + area);
    }

    private String describePlanetSupport(PlanetPosition planet, String language) {
        if (planet == null) {
            return "";
        }

        return translate(language,
                "Jupiter in " + planet.getSign() + " suggests growth through trust, learning, and a wider horizon.",
                "Юпитер в " + planet.getSign() + " показывает рост через доверие, обучение и расширение горизонтов.",
                "יופיטר ב-" + planet.getSign() + " מצביע על צמיחה דרך אמון, למידה והרחבת אופקים.",
                "Jupiter en " + planet.getSign() + " sugiere crecimiento a traves de confianza, aprendizaje y una vision mas amplia.");
    }

    private String describePlanetChallenge(PlanetPosition planet, String language) {
        if (planet == null) {
            return "";
        }

        return translate(language,
                "Saturn in " + planet.getSign() + " asks for patience, maturity, and consistent effort.",
                "Сатурн в " + planet.getSign() + " требует терпения, зрелости и последовательных усилий.",
                "שבתאי ב-" + planet.getSign() + " מבקש סבלנות, בגרות ומאמץ עקבי.",
                "Saturno en " + planet.getSign() + " pide paciencia, madurez y esfuerzo constante.");
    }

    private String translate(String language, String english, String russian, String hebrew, String spanish) {
        switch (language) {
            case "Rus": return russian;
            case "Heb": return hebrew;
            case "Spa": return spanish;
            default: return english;
        }
    }

    public DailyEnergyResponse getDailyEnergy() {
        Time t = Time.Companion.fromMillisecondsSince1970(System.currentTimeMillis());
        double sunLon = geocentricLongitude(Body.Sun, t);
        double moonLon = geocentricLongitude(Body.Moon, t);
        
        String sunSign = SIGNS[(int) (sunLon / 30)];
        String moonSign = SIGNS[(int) (moonLon / 30)];
        
        double diff = (moonLon - sunLon + 360) % 360;
        String moonPhase = getMoonPhase(diff);

        DailyEnergyResponse resp = new DailyEnergyResponse();
        resp.setMoonSign(moonSign);
        resp.setMoonPhase(moonPhase);
        resp.setHeadline(moonPhase + " in " + moonSign);
        resp.setDescription("Sun is in " + sunSign + ", Moon in " + moonSign);
        return resp;
    }

    public TransitResponse getTransits(BirthDataRequest birth) {
        LocalDateTime localDt = LocalDateTime.of(
            birth.getYear(), birth.getMonth(), birth.getDay(),
            birth.getHour(), birth.getMinute(), 0);
        ZoneOffset zoneOffset = ZoneOffset.ofTotalSeconds((int) (birth.getUtcOffset() * 3600));
        LocalDateTime utDt = OffsetDateTime.of(localDt, zoneOffset)
            .withOffsetSameInstant(ZoneOffset.UTC)
            .toLocalDateTime();

        DateTime natalDate = new DateTime(
            utDt.getYear(), utDt.getMonthValue(), utDt.getDayOfMonth(),
            utDt.getHour(), utDt.getMinute(), 0);
        Time natalT = natalDate.toTime();
        io.github.cosinekitty.astronomy.Observer observer = new io.github.cosinekitty.astronomy.Observer(birth.getLatitude(), birth.getLongitude(), 0.0);

        Map<String, Double> natalPos = new LinkedHashMap<>();
        Body[] bodies = {Body.Sun, Body.Moon, Body.Mercury, Body.Venus, Body.Mars, Body.Jupiter, Body.Saturn, Body.Uranus, Body.Neptune, Body.Pluto};
        String[] names = {"Sun", "Moon", "Mercury", "Venus", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"};

        double natalAsc = calculateAscendant(natalT, observer);
        double natalMc = calculateMidheaven(natalT, observer);
        
        // Calculate NATAL Placidus house cusps for accurate transit house assignment (v2)
        double ramcVal = (Astronomy.siderealTime(natalT) * 15.0 + observer.getLongitude() + 360.0) % 360.0;
        double epsVal  = 23.4392911 - 0.0130004167 * (natalT.getUt() / 36525.0);
        double[] placidus = calculatePlacidusHouseCusps(natalAsc, natalMc, ramcVal, epsVal, birth.getLatitude());
        System.out.println("[TRANSIT DEBUG] Using NATAL cusps: H9=" + placidus[8] + ", H10=" + placidus[9]);

        for (int i = 0; i < bodies.length; i++) {
            natalPos.put(names[i], geocentricLongitude(bodies[i], natalT));
        }
        natalPos.put("Ascendant", natalAsc);

        Time todayT = Time.Companion.fromMillisecondsSince1970(System.currentTimeMillis());
        List<TransitItem> items = new ArrayList<>();
        double orb = 5.0;

        for (int i = 0; i < bodies.length; i++) {
            double tLon = geocentricLongitude(bodies[i], todayT);
            int tSignIdx = (int) (tLon / 30);
            int tHouse = houseFromCusps(tLon, placidus);
            if (i == 0) System.out.println("[TRANSIT DEBUG] Sun: tLon=" + tLon + ", house=" + tHouse + ", cusps[8]=" + placidus[8] + ", cusps[9]=" + placidus[9]);

            for (Map.Entry<String, Double> n : natalPos.entrySet()) {
                double angle = aspectAngle(tLon, n.getValue());
                String aspect = getAspectName(angle, orb);
                if (aspect != null) {
                    items.add(new TransitItem(names[i], SIGNS[tSignIdx], tHouse, n.getKey(), aspect, round2(Math.abs(angle - getExactAngle(aspect)))));
                }
            }
        }
        TransitResponse resp = new TransitResponse();
        resp.setTransits(items);

        // Build text summary and ask Claude to interpret
        StringBuilder transitData = new StringBuilder();
        for (TransitItem item : items) {
            transitData.append(item.getTransitPlanet())
                    .append(" in ").append(item.getTransitSign())
                    .append(" (House ").append(item.getTransitHouse()).append(")")
                    .append(" ").append(item.getAspect())
                    .append(" natal ").append(item.getNatalPlanet())
                    .append(" (orb: ").append(item.getOrb()).append("°)\n");
        }
        String language = birth.getLanguage() != null ? birth.getLanguage() : "Eng";
        resp.setInterpretation(chatService.getTransitInterpretation(transitData.toString(), language));

        return resp;
    }

    // ── Placidus house system ────────────────────────────────────────────────

    /**
     * Calculates Placidus house cusps.
     * Verified formulas:
     *   H11: RA(H11) = RAMC + DSA(H11)/3
     *   H12: RA(H12) = RAMC + 2·DSA(H12)/3
     *   H2:  RA(H2)  = RAIC - 2·NSA(H2)/3
     *   H3:  RA(H3)  = RAIC - NSA(H3)/3
     *   H5,6,8,9 are opposite to H11,12,2,3
     * @param asc  Ascendant ecliptic longitude (degrees 0-360)
     * @param mc   Midheaven ecliptic longitude (degrees 0-360)
     * @param ramc RAMC in degrees 0-360
     * @param eps  Obliquity of ecliptic in degrees
     * @param lat  Geographic latitude in degrees
     * @return 12-element array cusps[0..11] = house 1..12 ecliptic longitudes
     */
    private double[] calculatePlacidusHouseCusps(double asc, double mc, double ramc, double eps, double lat) {
        double epsR  = Math.toRadians(eps);
        double latR  = Math.toRadians(lat);
        double ramcR = Math.toRadians(ramc);
        double raicR = ramcR + Math.PI;  // RAIC = RAMC + 180°

        double[] cusps = new double[12];
        cusps[0]  = asc;                  // H1  = ASC
        cusps[3]  = (mc + 180) % 360;     // H4  = IC
        cusps[6]  = (asc + 180) % 360;    // H7  = DSC
        cusps[9]  = mc;                   // H10 = MC

        // Upper cusps (between MC and ASC)
        cusps[10] = placidusUpperCusp(ramcR, epsR, latR, 1.0 / 3.0, mc + 30);  // H11
        cusps[11] = placidusUpperCusp(ramcR, epsR, latR, 2.0 / 3.0, mc + 60);  // H12

        // Lower cusps (between ASC and IC)
        cusps[1]  = placidusLowerCusp(raicR, epsR, latR, 2.0 / 3.0, asc + 30); // H2
        cusps[2]  = placidusLowerCusp(raicR, epsR, latR, 1.0 / 3.0, asc + 60); // H3

        // Opposite cusps
        cusps[4]  = (cusps[10] + 180) % 360; // H5
        cusps[5]  = (cusps[11] + 180) % 360; // H6
        cusps[7]  = (cusps[1]  + 180) % 360; // H8
        cusps[8]  = (cusps[2]  + 180) % 360; // H9

        return cusps;
    }

    /** Upper Placidus cusp: RA(cusp) = RAMC + fraction * DSA(cusp) */
    private double placidusUpperCusp(double ramcR, double epsR, double latR, double fraction, double guessEclDeg) {
        double lambda = Math.toRadians(((guessEclDeg % 360) + 360) % 360);
        for (int i = 0; i < 30; i++) {
            double dec   = Math.asin(Math.sin(epsR) * Math.sin(lambda));
            double sinAD = Math.max(-1.0, Math.min(1.0, Math.tan(latR) * Math.tan(dec)));
            double dsa   = Math.PI / 2 + Math.asin(sinAD);
            double targetRA  = ramcR + fraction * dsa;
            double newLambda = eclipticFromRA(targetRA, epsR);
            double diff = newLambda - lambda;
            if (diff >  Math.PI) diff -= 2 * Math.PI;
            if (diff < -Math.PI) diff += 2 * Math.PI;
            if (Math.abs(diff) < 1e-8) break;
            lambda = newLambda;
        }
        return Math.toDegrees(lambda);
    }

    /** Lower Placidus cusp: RA(cusp) = RAIC - fraction * NSA(cusp) */
    private double placidusLowerCusp(double raicR, double epsR, double latR, double fraction, double guessEclDeg) {
        double lambda = Math.toRadians(((guessEclDeg % 360) + 360) % 360);
        for (int i = 0; i < 30; i++) {
            double dec   = Math.asin(Math.sin(epsR) * Math.sin(lambda));
            double sinAD = Math.max(-1.0, Math.min(1.0, Math.tan(latR) * Math.tan(dec)));
            double nsa   = Math.PI / 2 - Math.asin(sinAD);
            double targetRA  = raicR - fraction * nsa;
            double newLambda = eclipticFromRA(targetRA, epsR);
            double diff = newLambda - lambda;
            if (diff >  Math.PI) diff -= 2 * Math.PI;
            if (diff < -Math.PI) diff += 2 * Math.PI;
            if (Math.abs(diff) < 1e-8) break;
            lambda = newLambda;
        }
        return Math.toDegrees(lambda);
    }

    /**
     * Convert Right Ascension → ecliptic longitude (radians, range [0, 2π)).
     * For a point on the ecliptic (β=0):
     *   tan(λ) = tan(α) / cos(ε)
     * atan2 is used to preserve the correct quadrant by matching
     * the sign of sin(λ) with sin(α), and cos(λ) with cos(α).
     */
    private double eclipticFromRA(double raR, double epsR) {
        // Normalize RA to [0, 2π)
        double ra = ((raR % (2 * Math.PI)) + 2 * Math.PI) % (2 * Math.PI);
        // tan(λ) = tan(α) / cos(ε)  →  atan2(sin(α), cos(α)·cos(ε))
        double sinL = Math.sin(ra);
        double cosL = Math.cos(ra) * Math.cos(epsR);
        double lambda = Math.atan2(sinL, cosL);
        return ((lambda % (2 * Math.PI)) + 2 * Math.PI) % (2 * Math.PI);
    }

    /** Determine house number (1-12) from Placidus cusp array. */
    private int houseFromCusps(double lon, double[] cusps) {
        for (int h = 0; h < 12; h++) {
            double start = cusps[h];
            double end   = cusps[(h + 1) % 12];
            double span  = (end - start + 360) % 360;
            double offset = (lon - start + 360) % 360;
            if (offset < span) return h + 1;
        }
        return 1;
    }

    // ── End Placidus ─────────────────────────────────────────────────────────

    private double calculateAscendant(Time t, io.github.cosinekitty.astronomy.Observer observer) {
        double ramc = Astronomy.siderealTime(t) * 15.0 + observer.getLongitude();
        ramc = (ramc + 360.0) % 360.0;
        // Mean obliquity of ecliptic — nutationEps() is only a tiny correction, not the full obliquity
        double T = t.getUt() / 36525.0;
        double eps = 23.4392911 - 0.0130004167 * T;
        double ra = Math.toRadians(ramc);
        double phi = Math.toRadians(observer.getLatitude());
        double e = Math.toRadians(eps);
        // Correct Ascendant formula
        double ascRad = Math.atan2(Math.cos(ra), -(Math.sin(ra) * Math.cos(e) + Math.tan(phi) * Math.sin(e)));
        double asc = (Math.toDegrees(ascRad) + 360) % 360;

        return asc;
    }

    private double calculateMidheaven(Time t, io.github.cosinekitty.astronomy.Observer observer) {
        double ramc = Astronomy.siderealTime(t) * 15.0 + observer.getLongitude();
        ramc = (ramc + 360.0) % 360.0;
        double T = t.getUt() / 36525.0;
        double eps = 23.4392911 - 0.0130004167 * T;
        double ra = Math.toRadians(ramc);
        double e = Math.toRadians(eps);
        double mcRad = Math.atan2(Math.tan(ra), Math.cos(e));
        double mcDeg = Math.toDegrees(mcRad);
        if (ramc > 90 && ramc < 270) mcDeg += 180;
        return (mcDeg + 360) % 360;
    }

    private double aspectAngle(double lon1, double lon2) {
        double angle = Math.abs(lon1 - lon2);
        return angle > 180 ? 360 - angle : angle;
    }

    private String getAspectName(double angle, double orb) {
        if (Math.abs(angle - 0) <= orb)   return "Conjunction";
        if (Math.abs(angle - 60) <= orb)  return "Sextile";
        if (Math.abs(angle - 90) <= orb)  return "Square";
        if (Math.abs(angle - 120) <= orb) return "Trine";
        if (Math.abs(angle - 150) <= orb) return "Quincunx";
        if (Math.abs(angle - 180) <= orb) return "Opposition";
        return null;
    }

    private double getExactAngle(String aspectName) {
        switch (aspectName) {
            case "Conjunction": return 0;
            case "Sextile": return 60;
            case "Square": return 90;
            case "Trine": return 120;
            case "Quincunx": return 150;
            case "Opposition": return 180;
            default: return 0;
        }
    }

    private String getMoonPhase(double diff) {
        if (diff < 45) return "New Moon";
        if (diff < 90) return "Waxing Crescent";
        if (diff < 135) return "First Quarter";
        if (diff < 180) return "Waxing Gibbous";
        if (diff < 225) return "Full Moon";
        if (diff < 270) return "Waning Gibbous";
        if (diff < 315) return "Last Quarter";
        return "Waning Crescent";
    }

    private List<String> detectPatterns(List<PlanetPosition> planets) {
        List<String> patterns = new ArrayList<>();
        double orbTight = 6.0;   // T-Square, Grand Cross, Grand Trine, Kite, Bisextile
        double orbYod   = 6.0;   // Yod (quincunx orb — standard 6° per most schools)
        double orbStell = 8.0;   // Stellium (conjunction orb)
        int n = planets.size();

        // ── Stellium: 3+ planets within orbStell of each other (same sign cluster) ──
        for (int i = 0; i < n; i++) {
            List<String> cluster = new ArrayList<>();
            cluster.add(planets.get(i).getName());
            for (int j = i + 1; j < n; j++) {
                if (aspectAngle(planets.get(i).getLongitude(), planets.get(j).getLongitude()) <= orbStell) {
                    cluster.add(planets.get(j).getName());
                }
            }
            if (cluster.size() >= 3) {
                String key = String.join("+", cluster);
                String entry = "Stellium: " + String.join(", ", cluster);
                if (!patterns.contains(entry)) patterns.add(entry);
            }
        }

        // ── T-Square: opposition + two squares to apex ──
        for (int i = 0; i < n; i++) {
            for (int j = i + 1; j < n; j++) {
                double angIJ = aspectAngle(planets.get(i).getLongitude(), planets.get(j).getLongitude());
                if (Math.abs(angIJ - 180) <= orbTight) {
                    for (int k = 0; k < n; k++) {
                        if (k == i || k == j) continue;
                        double angIK = aspectAngle(planets.get(i).getLongitude(), planets.get(k).getLongitude());
                        double angJK = aspectAngle(planets.get(j).getLongitude(), planets.get(k).getLongitude());
                        if (Math.abs(angIK - 90) <= orbTight && Math.abs(angJK - 90) <= orbTight) {
                            patterns.add("T-Square: " + planets.get(i).getName() + " ☍ " + planets.get(j).getName() + " → apex " + planets.get(k).getName());
                        }
                    }
                }
            }
        }

        // ── Grand Cross: two oppositions + four squares ──
        for (int i = 0; i < n; i++) {
            for (int j = i + 1; j < n; j++) {
                double angIJ = aspectAngle(planets.get(i).getLongitude(), planets.get(j).getLongitude());
                if (Math.abs(angIJ - 180) <= orbTight) {
                    for (int k = j + 1; k < n; k++) {
                        for (int l = k + 1; l < n; l++) {
                            if (l == i || l == j) continue;
                            double angKL = aspectAngle(planets.get(k).getLongitude(), planets.get(l).getLongitude());
                            if (Math.abs(angKL - 180) <= orbTight) {
                                double angIK = aspectAngle(planets.get(i).getLongitude(), planets.get(k).getLongitude());
                                double angIL = aspectAngle(planets.get(i).getLongitude(), planets.get(l).getLongitude());
                                double angJK = aspectAngle(planets.get(j).getLongitude(), planets.get(k).getLongitude());
                                double angJL = aspectAngle(planets.get(j).getLongitude(), planets.get(l).getLongitude());
                                if (Math.abs(angIK - 90) <= orbTight && Math.abs(angIL - 90) <= orbTight
                                        && Math.abs(angJK - 90) <= orbTight && Math.abs(angJL - 90) <= orbTight) {
                                    patterns.add("Grand Cross: " + planets.get(i).getName() + ", "
                                            + planets.get(j).getName() + ", "
                                            + planets.get(k).getName() + ", "
                                            + planets.get(l).getName());
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Grand Trine: three planets each 120° from each other ──
        for (int i = 0; i < n; i++) {
            for (int j = i + 1; j < n; j++) {
                double angIJ = aspectAngle(planets.get(i).getLongitude(), planets.get(j).getLongitude());
                if (Math.abs(angIJ - 120) <= orbTight) {
                    for (int k = j + 1; k < n; k++) {
                        double angIK = aspectAngle(planets.get(i).getLongitude(), planets.get(k).getLongitude());
                        double angJK = aspectAngle(planets.get(j).getLongitude(), planets.get(k).getLongitude());
                        if (Math.abs(angIK - 120) <= orbTight && Math.abs(angJK - 120) <= orbTight) {
                            patterns.add("Grand Trine: " + planets.get(i).getName() + ", "
                                    + planets.get(j).getName() + ", " + planets.get(k).getName());

                            // ── Kite: Grand Trine + opposition to one vertex, sextiles to other two ──
                            for (int m = 0; m < n; m++) {
                                if (m == i || m == j || m == k) continue;
                                double angMI = aspectAngle(planets.get(m).getLongitude(), planets.get(i).getLongitude());
                                double angMJ = aspectAngle(planets.get(m).getLongitude(), planets.get(j).getLongitude());
                                double angMK = aspectAngle(planets.get(m).getLongitude(), planets.get(k).getLongitude());
                                // m opposite i, sextile j and k
                                if (Math.abs(angMI - 180) <= orbTight && Math.abs(angMJ - 60) <= orbTight && Math.abs(angMK - 60) <= orbTight) {
                                    patterns.add("Kite: apex " + planets.get(m).getName() + " ☍ " + planets.get(i).getName()
                                            + " (trine: " + planets.get(j).getName() + ", " + planets.get(k).getName() + ")");
                                }
                                // m opposite j, sextile i and k
                                if (Math.abs(angMJ - 180) <= orbTight && Math.abs(angMI - 60) <= orbTight && Math.abs(angMK - 60) <= orbTight) {
                                    patterns.add("Kite: apex " + planets.get(m).getName() + " ☍ " + planets.get(j).getName()
                                            + " (trine: " + planets.get(i).getName() + ", " + planets.get(k).getName() + ")");
                                }
                                // m opposite k, sextile i and j
                                if (Math.abs(angMK - 180) <= orbTight && Math.abs(angMI - 60) <= orbTight && Math.abs(angMJ - 60) <= orbTight) {
                                    patterns.add("Kite: apex " + planets.get(m).getName() + " ☍ " + planets.get(k).getName()
                                            + " (trine: " + planets.get(i).getName() + ", " + planets.get(j).getName() + ")");
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Yod (Finger of God): two quincunxes (150°) + sextile (60°) at base ──
        // sextile base uses orbTight (5°), quincunxes use orbYod (3°)
        for (int i = 0; i < n; i++) {
            for (int j = i + 1; j < n; j++) {
                double angIJ = aspectAngle(planets.get(i).getLongitude(), planets.get(j).getLongitude());
                if (Math.abs(angIJ - 60) <= orbTight) {
                    for (int k = 0; k < n; k++) {
                        if (k == i || k == j) continue;
                        double angIK = aspectAngle(planets.get(i).getLongitude(), planets.get(k).getLongitude());
                        double angJK = aspectAngle(planets.get(j).getLongitude(), planets.get(k).getLongitude());
                        if (Math.abs(angIK - 150) <= orbYod && Math.abs(angJK - 150) <= orbYod) {
                            patterns.add("Yod: " + planets.get(i).getName() + " ⚹ " + planets.get(j).getName()
                                    + " → apex " + planets.get(k).getName());
                        }
                    }
                }
            }
        }

        // ── Bisextile (Minor Grand Trine): trine base + two sextiles to apex ──
        for (int i = 0; i < n; i++) {
            for (int j = i + 1; j < n; j++) {
                double angIJ = aspectAngle(planets.get(i).getLongitude(), planets.get(j).getLongitude());
                if (Math.abs(angIJ - 120) <= orbTight) {
                    for (int k = 0; k < n; k++) {
                        if (k == i || k == j) continue;
                        double angIK = aspectAngle(planets.get(i).getLongitude(), planets.get(k).getLongitude());
                        double angJK = aspectAngle(planets.get(j).getLongitude(), planets.get(k).getLongitude());
                        if (Math.abs(angIK - 60) <= orbTight && Math.abs(angJK - 60) <= orbTight) {
                            patterns.add("Bisextile: " + planets.get(i).getName() + " △ " + planets.get(j).getName()
                                    + " → focal " + planets.get(k).getName());
                        }
                    }
                }
            }
        }

        return patterns;
    }

    private List<ChartResponse.AspectInfo> calculateAspects(List<PlanetPosition> planets) {
        double[] angles  = {0, 60, 90, 120, 150, 180};
        double[] maxOrbs = {8, 6,  8,  8,   6,   8};
        String[] names   = {"Conjunction", "Sextile", "Square", "Trine", "Quincunx", "Opposition"};

        List<ChartResponse.AspectInfo> result = new ArrayList<>();
        for (int i = 0; i < planets.size(); i++) {
            for (int j = i + 1; j < planets.size(); j++) {
                double diff  = Math.abs(planets.get(i).getLongitude() - planets.get(j).getLongitude());
                double angle = diff > 180 ? 360 - diff : diff;
                for (int k = 0; k < angles.length; k++) {
                    double orb = Math.abs(angle - angles[k]);
                    if (orb <= maxOrbs[k]) {
                        result.add(new ChartResponse.AspectInfo(
                            planets.get(i).getName(), planets.get(j).getName(),
                            names[k], round2(orb)
                        ));
                        break;
                    }
                }
            }
        }
        result.sort(Comparator.comparingDouble(ChartResponse.AspectInfo::getOrb));
        return result;
    }

    private double round2(double val) {
        return Math.round(val * 100.0) / 100.0;
    }

    /**
     * Geocentric ecliptic longitude for any body.
     * eclipticLongitude() does NOT support Sun or Moon — use dedicated APIs for those.
     */
    private double geocentricLongitude(Body body, Time t) {
        if (body == Body.Sun) {
            return (Astronomy.sunPosition(t).getElon() + 360.0) % 360.0;
        } else if (body == Body.Moon) {
            return (Astronomy.eclipticGeoMoon(t).getLon() + 360.0) % 360.0;
        } else {
            // eclipticLongitude() is HELIOCENTRIC — use geoVector + ecliptic rotation for geocentric
            io.github.cosinekitty.astronomy.Vector eq = Astronomy.geoVector(body, t, Aberration.Corrected);
            double T = t.getUt() / 36525.0;
            double epsRad = Math.toRadians(23.4392911 - 0.0130004167 * T);
            double ye = eq.getY() * Math.cos(epsRad) + eq.getZ() * Math.sin(epsRad);
            double lon = Math.toDegrees(Math.atan2(ye, eq.getX()));
            return (lon + 360.0) % 360.0;
        }
    }

    /**
     * Approximates true North Node longitude by using the nearest lunar node crossing event.
     */
    private double approximateNorthNodeLongitude(Time t) {
        final double targetUt = t.getUt();
        NodeEventInfo event = Astronomy.searchMoonNode(t.addDays(-35.0));
        NodeEventInfo prev = event;
        NodeEventInfo next = Astronomy.nextMoonNode(event);

        int guard = 0;
        while (next.getTime().getUt() <= targetUt && guard++ < 24) {
            prev = next;
            next = Astronomy.nextMoonNode(next);
        }

        NodeEventInfo nearest =
                Math.abs(prev.getTime().getUt() - targetUt) <= Math.abs(next.getTime().getUt() - targetUt)
                        ? prev
                        : next;

        double eventLon = normalize360(Astronomy.eclipticGeoMoon(nearest.getTime()).getLon());
        if (nearest.getKind() == NodeEventKind.Ascending) {
            return eventLon;
        }
        return normalize360(eventLon + 180.0);
    }

    /**
     * Approximates Lilith as the lunar apogee longitude near birth time.
     * This is a practical no-SwissEphem approximation.
     */
    private double approximateLilithLongitude(Time t) {
        final double targetUt = t.getUt();
        ApsisInfo apsis = Astronomy.searchLunarApsis(t.addDays(-20.0));
        ApsisInfo prevApocenter = null;
        ApsisInfo nextApocenter = null;

        int guard = 0;
        while (apsis != null && guard++ < 40) {
            if (apsis.getKind() == ApsisKind.Apocenter) {
                if (apsis.getTime().getUt() <= targetUt) {
                    prevApocenter = apsis;
                } else {
                    nextApocenter = apsis;
                    break;
                }
            }
            apsis = Astronomy.nextLunarApsis(apsis);
        }

        ApsisInfo chosen;
        if (prevApocenter == null && nextApocenter == null) {
            throw new IllegalStateException("No lunar apocenter found near target time");
        } else if (prevApocenter == null) {
            chosen = nextApocenter;
        } else if (nextApocenter == null) {
            chosen = prevApocenter;
        } else {
            chosen = Math.abs(prevApocenter.getTime().getUt() - targetUt)
                    <= Math.abs(nextApocenter.getTime().getUt() - targetUt)
                    ? prevApocenter
                    : nextApocenter;
        }

        return normalize360(Astronomy.eclipticGeoMoon(chosen.getTime()).getLon());
    }

    private double normalize360(double value) {
        double v = value % 360.0;
        return v < 0 ? v + 360.0 : v;
    }
}