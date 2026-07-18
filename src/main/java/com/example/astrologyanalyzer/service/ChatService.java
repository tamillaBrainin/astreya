package com.example.astrologyanalyzer.service;

import com.example.astrologyanalyzer.dto.ChatResponse;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.SocketTimeoutException;
import java.net.URL;

@Service
public class ChatService {

    private static final String CLAUDE_API_URL = "https://api.anthropic.com/v1/messages";

    @Value("${claude.api.key:${ANTHROPIC_API_KEY:${CLAUDE_API_KEY:}}}")
    private String claudeApiKey;

    @Value("${claude.api.model:${CLAUDE_API_MODEL:claude-sonnet-4-6}}")
    private String claudeModel;

    @Value("${claude.transit.read-timeout-ms:${CLAUDE_TRANSIT_READ_TIMEOUT_MS:25000}}")
    private int transitReadTimeoutMs;

    private static final String SYSTEM_PROMPT =
            "You are AstroBot — a friendly, wise, and insightful astrologer. "
            + "You answer questions about astrology, natal charts, transits, compatibility, "
            + "and spiritual growth. Keep your answers warm, clear, and concise. "
            + "Use emojis sparingly to add personality. "
            + "If the user asks something unrelated to astrology, gently steer back to astrology topics.";

    public ChatResponse chat(String userMessage) {
        return chat(userMessage, "Eng");
    }

    public ChatResponse chat(String userMessage, String language) {
        try {
            String reply = callClaude(userMessage, language);
            if (reply != null) {
                return new ChatResponse(reply);
            } else {
                return new ChatResponse("✨ I'm having trouble connecting to the stars right now. Please try again in a moment.");
            }
        } catch (Exception e) {
            System.err.println("Chat error: " + e.getMessage());
            return new ChatResponse("✨ Something went wrong. Please try again.");
        }
    }

    private String callClaude(String userMessage) throws IOException {
        return callClaude(userMessage, "Eng", 1024, 25000);
    }

    private String callClaude(String userMessage, String language) throws IOException {
        return callClaude(userMessage, language, 1024, 25000);
    }

    private String callClaude(String userMessage, int maxTokens, int readTimeoutMillis) throws IOException {
        return callClaude(userMessage, "Eng", maxTokens, readTimeoutMillis);
    }

    private String callClaude(String userMessage, String language, int maxTokens, int readTimeoutMillis) throws IOException {
        String escapedSystem = escapeJson(buildSystemPrompt(language));
        String escapedUser = escapeJson(userMessage);

        String requestBody = "{"
                + "\"model\": \"" + claudeModel + "\","
                + "\"max_tokens\": " + maxTokens + ","
                + "\"system\": \"" + escapedSystem + "\","
                + "\"messages\": [{\"role\": \"user\", \"content\": \"" + escapedUser + "\"}]"
                + "}";

        URL url = new URL(CLAUDE_API_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("x-api-key", claudeApiKey);
        conn.setRequestProperty("anthropic-version", "2023-06-01");
        conn.setDoOutput(true);
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(readTimeoutMillis);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(requestBody.getBytes("UTF-8"));
        }

        int statusCode = conn.getResponseCode();
        System.out.println("Claude Chat API Status: " + statusCode);

        BufferedReader reader = new BufferedReader(new InputStreamReader(
                statusCode == 200 ? conn.getInputStream() : conn.getErrorStream()));
        StringBuilder responseBody = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            responseBody.append(line);
        }
        reader.close();

        if (statusCode == 200) {
            System.out.println("Claude API response OK, parsing JSON...");
            JSONObject json = new JSONObject(responseBody.toString());
            String text = json.getJSONArray("content").getJSONObject(0).getString("text");
            System.out.println("Claude API text response length: " + text.length());
            return text;
        } else {
            System.err.println("Claude Chat API error (" + statusCode + "): " + responseBody.toString());
            System.err.println("Claude Model being used: " + claudeModel);
            System.err.println("Full error response: " + responseBody.toString());
            return null;
        }
    }

    private String buildSystemPrompt(String language) {
        String langInstruction;
        switch (normalizeLanguage(language)) {
            case "Rus":
                langInstruction = "IMPORTANT: Reply only in Russian. Do not switch to English.";
                break;
            case "Heb":
                langInstruction = "IMPORTANT: Reply only in Hebrew. Do not switch to English.";
                break;
            case "Spa":
                langInstruction = "IMPORTANT: Reply only in Spanish. Do not switch to English.";
                break;
            default:
                langInstruction = "IMPORTANT: Reply only in English.";
                break;
        }
        return SYSTEM_PROMPT + " " + langInstruction;
    }

    private String normalizeLanguage(String language) {
        if (language == null || language.isBlank()) return "Eng";
        String value = language.trim();
        switch (value) {
            case "Rus":
            case "Heb":
            case "Spa":
            case "Eng":
                return value;
            default:
                return "Eng";
        }
    }

    /**
     * Get Claude interpretation of a natal chart — same as the Telegram bot does.
     */
    public String getInterpretation(String natalData, String language) {
        try {
            String langInstruction;
            switch (language) {
                case "Rus": langInstruction = "Write only in Russian."; break;
                case "Heb": langInstruction = "Write only in Hebrew."; break;
                case "Spa": langInstruction = "Write only in Spanish."; break;
                default: langInstruction = "Write only in English."; break;
            }

            String prompt = "You are a professional astrologer writing a premium, detailed natal reading. "
                    + langInstruction + " "
                    + "Use ONLY the provided chart data. Do not invent planets or points that are not present. "
                    + "Write in rich, practical language with emotional insight and clear meaning.\n\n"
                    + "FORMAT REQUIREMENTS:\n"
                    + "- Use markdown with emoji section headings.\n"
                    + "- Use this style: '# 🌞 **Sun in ...**' followed by explanation and bullet points.\n"
                    + "- Create separate sections for: Sun, Moon, Mercury, Venus, Mars.\n"
                    + "- Add sections for Jupiter+Saturn influence, MC/career, relationships (7th house), major aspects, configurations, and final summary portrait.\n"
                    + "- Include concrete bullet points in each section (3-6 bullets).\n"
                    + "- Keep the reading substantial (around 900-1400 words).\n"
                    + "- End with a final section titled equivalent to 'Final Portrait'.\n"
                    + "- Never switch language.\n\n"
                    + "CHART DATA:\n" + natalData;

            try {
                String first = callClaude(prompt, language, 1500, 45000);
                if (isWeakInterpretation(first)) {
                    String retryPrompt = prompt
                            + "\n\nIMPORTANT QUALITY CHECK:\n"
                            + "- Cover ALL major planets present in chart data, not only Sun/Moon.\n"
                            + "- Include explicit sections for Mercury, Venus, Mars, Jupiter, Saturn at minimum.\n"
                            + "- Keep full structure with headings and bullet points.\n";
                    String second = callClaude(retryPrompt, language, 1800, 75000);
                    if (!isWeakInterpretation(second)) {
                        return second;
                    }
                    return second != null ? second : first;
                }
                return first;
            } catch (SocketTimeoutException timeout) {
                System.err.println("Interpretation timeout, retrying once with extended timeout...");
                String retryPrompt = prompt
                        + "\n\nIMPORTANT QUALITY CHECK:\n"
                        + "- Cover ALL major planets present in chart data, not only Sun/Moon.\n"
                        + "- Include explicit sections for Mercury, Venus, Mars, Jupiter, Saturn at minimum.\n";
                return callClaude(retryPrompt, language, 1800, 75000);
            }
        } catch (Exception e) {
            System.err.println("Interpretation error: " + e.getMessage());
            return null;
        }
    }

    public String getTransitInterpretation(String transitData, String language) {
        System.out.println("[TRANSIT] Starting getTransitInterpretation, language=" + language);
        try {
            String compactTransitData = buildCompactTransitData(transitData, 12);
            String langInstruction;
            String depthInstruction;
            switch (language) {
                case "Rus":
                    langInstruction = "Write only in Russian.";
                    depthInstruction = "Keep the Russian output full and rich (roughly 850-1300 words), never shorter than the English version in detail.";
                    break;
                case "Heb":
                    langInstruction = "Write only in Hebrew.";
                    depthInstruction = "Keep the Hebrew output full and rich (roughly 850-1300 words), never shorter than the English version in detail.";
                    break;
                case "Spa":
                    langInstruction = "Write only in Spanish.";
                    depthInstruction = "Keep the Spanish output full and rich (roughly 850-1300 words), never shorter than the English version in detail.";
                    break;
                default:
                    langInstruction = "Write only in English.";
                    depthInstruction = "Keep the output substantial (roughly 850-1300 words) while staying practical and readable.";
                    break;
            }

                String prompt;
                if ("Rus".equals(normalizeLanguage(language))) {
                prompt = "Ты — профессиональный астролог. Пиши только по-русски. Используй ТОЛЬКО данные из JSON, без пересчётов и выдуманных фактов.\n\n"
                    + "Сделай короткий и практичный разбор (примерно 350-600 слов) в markdown с ОБЯЗАТЕЛЬНЫМИ разделами:\n"
                    + "## Быстрые планеты\n"
                    + "## Медленные планеты\n"
                    + "## Деньги и работа\n"
                    + "## Отношения\n"
                    + "## Эмоциональный фон\n"
                    + "## Что делать сегодня\n"
                    + "## Куда не сливать энергию\n"
                    + "## Главный узел периода\n\n"
                    + "Правила:\n"
                    + "- Выбери 3-5 самых сильных влияний (приоритет: меньший orb, затем медленные планеты).\n"
                    + "- Для каждого влияния обязательно укажи: планета, знак, дом, аспект к натальной планете и практический вывод.\n"
                    + "- Особо выдели аспекты с orb < 1°.\n"
                    + "- Если повторяются темы по одному дому/натальной планете, отметь как усиленную тему.\n"
                    + "- В 'Главный узел периода' сведи 2-3 ключевые темы в единую картину.\n"
                    + "- Без фатализма, только тенденции и практичные рекомендации.\n\n"
                    + "Данные транзитов (JSON):\n"
                    + compactTransitData;
                } else {
                prompt = "You are an astrological interpreter for daily transits. "
                    + "Do not recalculate astrology. Use ONLY the provided transit data. "
                    + "Tone: warm, clear, practical, psychologically insightful. "
                    + "No fatal predictions. No fear language. Use probabilities and guidance. "
                    + langInstruction + " " + depthInstruction + "\n\n"
                    + "OUTPUT FORMAT (markdown):\n"
                    + "1) Title: 'Transits for Today — <date if available>'.\n"
                    + "2) Short intro (2-4 sentences): main daily theme.\n"
                    + "3) Main picture: 3-5 strongest influences only (do not list everything).\n"
                    + "   For each influence include:\n"
                    + "   - planet + house/aspect\n"
                    + "   - transit house meaning: explain what the house means in everyday life\n"
                    + "   - psychological theme\n"
                    + "   - practical everyday manifestation\n"
                    + "   - short actionable takeaway\n"
                    + "4) Separate section: Money and Work Today.\n"
                    + "5) Separate section: Relationships Today.\n"
                    + "6) Separate section: Emotional Background (use transit Moon if present).\n"
                    + "7) Section: What To Do Today (3-6 bullets).\n"
                    + "8) Section: Where Not To Spend Energy (3-5 bullets).\n"
                    + "9) Final one-line summary of the day.\n\n"
                    + "PRIORITIZATION RULES:\n"
                    + "- Prioritize slow planets by house: Pluto, Neptune, Uranus, Saturn.\n"
                    + "- Treat the transit house as the main life area being activated by each planet.\n"
                    + "- Prioritize tight aspects with small orb first.\n"
                    + "- Then personal planets and Moon emotional tone.\n"
                    + "- If data is missing for a section, give careful practical guidance without inventing facts.\n\n"
                    + "STYLE RULES:\n"
                    + "- Speak like to a real person, not textbook language.\n"
                    + "- Keep it grounded and useful.\n"
                    + "- Use markdown with visible section headers and bullet points.\n"
                    + "- Ensure each required section has at least 2-3 lines of practical detail.\n"
                    + "- Do not claim certainty ('this will definitely happen').\n\n"
                    + "HOUSE INTERPRETATION RULE:\n"
                    + "- For every transit, explain the transit house as the area of life being activated.\n"
                    + "- If a transit is in House 10, tie it to career, reputation, and public direction.\n"
                    + "- If a transit is in House 7, tie it to relationships and partnerships.\n"
                    + "- If a transit is in House 4, tie it to home, roots, and emotional foundations.\n"
                    + "- If a transit is in House 8, tie it to shared resources, trust, and transformation.\n\n"
                    + "TRANSIT DATA:\n" + compactTransitData;
                }

            try {
                int transitTimeout = Math.max(10000, transitReadTimeoutMs);
                System.out.println("[TRANSIT] Calling Claude API (single attempt, 1000 tokens, timeout " + transitTimeout + "ms)...");
                String first = callClaude(prompt, language, 1000, transitTimeout);
                System.out.println("[TRANSIT] First Claude response received, length=" + (first != null ? first.length() : "null"));
                if (first == null) {
                    System.out.println("[TRANSIT] First response was null, using fallback");
                    return getFallbackTransitInterpretation(transitData, language);
                }
                if (isWeakTransitInterpretation(first)) {
                    System.out.println("[TRANSIT] First response too weak, returning fallback");
                    return getFallbackTransitInterpretation(transitData, language);
                }
                System.out.println("[TRANSIT] First response is good quality, returning it");
                    return normalizeRuMainNodeHeading(first, language);
            } catch (SocketTimeoutException timeout) {
                System.err.println("[TRANSIT] SocketTimeoutException, trying fast recovery prompt (10s)...");
                try {
                    String fastPrompt = "Пиши только по-русски. Кратко (220-360 слов), markdown. "
                            + "Обязательные разделы: Быстрые планеты, Медленные планеты, Главный узел периода, Что делать сегодня. "
                            + "Выбери только самые сильные влияния по минимальному orb. Без выдумок.\n\nДанные:\n"
                            + buildCompactTransitData(transitData, 8);
                    String recovered = callClaude(fastPrompt, language, 700, 10000);
                    if (!isWeakTransitInterpretation(recovered)) {
                        System.out.println("[TRANSIT] Fast recovery succeeded");
                        return normalizeRuMainNodeHeading(recovered, language);
                    }
                } catch (Exception fastErr) {
                    System.err.println("[TRANSIT] Fast recovery failed: " + fastErr.getMessage());
                }
                System.err.println("[TRANSIT] Returning fallback after timeout recovery failure...");
                return getFallbackTransitInterpretation(transitData, language);
            }
        } catch (Exception e) {
            System.err.println("[TRANSIT] Exception in getTransitInterpretation: " + e.getClass().getName());
            System.err.println("[TRANSIT] Message: " + e.getMessage());
            System.err.println("[TRANSIT] Claude Model: " + claudeModel);
            System.err.println("[TRANSIT] API Key set: " + (claudeApiKey != null && !claudeApiKey.isEmpty()));
            e.printStackTrace(System.err);
            System.out.println("[TRANSIT] Returning fallback transit interpretation...");
            return getFallbackTransitInterpretation(transitData, language);
        }
    }

    private String normalizeRuMainNodeHeading(String text, String language) {
        if (!"Rus".equals(normalizeLanguage(language)) || text == null || text.isBlank()) {
            return text;
        }

        if (text.toLowerCase(java.util.Locale.ROOT).contains("главный узел периода")) {
            return text;
        }

        String normalized = text;
        String[] variants = new String[] {
                "## Итоговая картина",
                "## Главная тема периода",
                "## Ключевая тема периода",
                "## Ключевой узел периода",
                "## Основной узел периода",
                "## Итог",
                "## Вывод"
        };

        for (String variant : variants) {
            if (normalized.contains(variant)) {
                return normalized.replace(variant, "## Главный узел периода");
            }
        }

        return normalized + "\n\n## Главный узел периода\n- Ключевая линия периода уже отражена в разделах выше: соберите повторяющиеся темы по домам и самым точным аспектам (orb < 1°) и действуйте через приоритеты дня.";
    }

    private boolean isWeakTransitInterpretation(String text) {
        if (text == null || text.isBlank()) return true;
        String normalized = text.trim();
        String lower = normalized.toLowerCase(java.util.Locale.ROOT);
        int length = normalized.length();
        int headers = 0;
        int sectionLike = 0;
        int bullets = 0;

        String[] lines = normalized.split("\\r?\\n");
        for (String line : lines) {
            String l = line.trim();
            if (l.startsWith("#")) headers++;
            // Some model outputs use short titled lines instead of markdown headers.
            if (!l.startsWith("#") && l.endsWith(":") && l.length() <= 80) sectionLike++;

            if (l.startsWith("- ") || l.startsWith("* ") || l.startsWith("• ") || l.startsWith("— ")) {
                bullets++;
            }

            // Accept numbered list formatting (e.g., "1. ..." / "2) ...") as structured guidance.
            if (l.matches("^\\d+[\\.\\)].+")) bullets++;
        }

        int structure = headers + sectionLike;
        boolean hasCoreSection = lower.contains("главный узел периода")
                || lower.contains("what to do today")
                || lower.contains("что делать сегодня")
                || lower.contains("money and work")
                || lower.contains("деньги и работа");

        // Accept substantial responses even when formatting is compact.
        if (length >= 1200 && (structure >= 2 || hasCoreSection)) {
            return false;
        }

        // Reject only clearly weak outputs: too short and almost no structure.
        return length < 550 || (structure < 2 && bullets < 2 && !hasCoreSection);
    }

    private String buildCompactTransitData(String transitData, int maxItems) {
        try {
            JSONObject source = new JSONObject(transitData);
            JSONArray transits = source.optJSONArray("transits");
            if (transits == null || transits.isEmpty()) {
                return transitData;
            }

            java.util.List<JSONObject> items = new java.util.ArrayList<>();
            for (int i = 0; i < transits.length(); i++) {
                JSONObject t = transits.optJSONObject(i);
                if (t != null) {
                    items.add(t);
                }
            }

            items.sort(java.util.Comparator.comparingDouble(o -> o.optDouble("orb", 999.0)));

            int limit = Math.min(Math.max(6, maxItems), items.size());
            JSONArray compact = new JSONArray();
            int exactCount = 0;
            for (int i = 0; i < limit; i++) {
                JSONObject src = items.get(i);
                JSONObject row = new JSONObject();
                row.put("transitPlanet", src.optString("transitPlanet", ""));
                row.put("transitSign", src.optString("transitSign", ""));
                row.put("transitHouse", src.optInt("transitHouse", 0));
                row.put("natalPlanet", src.optString("natalPlanet", ""));
                row.put("aspect", src.optString("aspect", ""));
                double orb = src.optDouble("orb", 0.0);
                orb = Math.round(orb * 100.0) / 100.0;
                row.put("orb", orb);
                if (orb > 0 && orb < 1.0) {
                    exactCount++;
                }
                compact.put(row);
            }

            JSONObject reduced = new JSONObject();
            reduced.put("date", source.opt("date"));
            reduced.put("totalTransits", transits.length());
            reduced.put("usedForInterpretation", limit);
            reduced.put("exactAspectsUnder1deg", exactCount);
            reduced.put("transits", compact);
            return reduced.toString();
        } catch (Exception ignored) {
            return transitData;
        }
    }

    private String normalizeTransitInterpretation(String text, String language) {
        if (text == null) return null;
        if (!"Rus".equals(normalizeLanguage(language))) return text;

        String normalized = text;
        String lower = normalized.toLowerCase(java.util.Locale.ROOT);
        if (lower.contains("главный узел периода")) {
            return normalized;
        }

        String[] alternatives = new String[] {
                "ключевая тема периода",
                "главная тема периода",
                "ключевой узел периода",
                "главный фокус периода",
                "итог периода",
                "итог",
                "вывод"
        };

        for (String alt : alternatives) {
            String pattern = "(?im)^#{1,6}\\s*.*" + java.util.regex.Pattern.quote(alt) + ".*$";
            if (normalized.matches("(?s).*" + pattern + ".*")) {
                return normalized.replaceFirst(pattern, "## Главный узел периода");
            }
        }

        return normalized
                + "\n\n## Главный узел периода\n"
                + "- Главная линия периода: сфокусируйтесь на темах домов с наибольшим числом активных аспектов и на самых точных орбах.\n"
                + "- Практика: объединяйте краткосрочные импульсы быстрых планет с долгосрочной стратегией медленных планет.\n";
    }


    /**
     * Get per-planet Russian keyword interpretations via Claude.
     * Returns a map of English planet name -> 3 short Russian keyword lines.
     */
    public java.util.Map<String, String> getPlanetaryInterpretations(
            java.util.List<com.example.astrologyanalyzer.dto.PlanetPosition> planets,
            String language) {
        try {
            String langInstruction;
            switch (language) {
                case "Rus": langInstruction = "Answer in Russian."; break;
                case "Heb": langInstruction = "Answer in Hebrew."; break;
                case "Spa": langInstruction = "Answer in Spanish."; break;
                default: langInstruction = "Answer in Russian."; break;
            }

            StringBuilder planetList = new StringBuilder();
            for (com.example.astrologyanalyzer.dto.PlanetPosition p : planets) {
                if (p.getName().equals("Ascendant")) continue;
                planetList.append(p.getName()).append(" in ").append(p.getSign())
                          .append(", house ").append(p.getHouse()).append("\n");
            }

            String prompt = "You are a professional astrologer. " + langInstruction + "\n\n"
                + "For each planet below, write exactly 3 short keyword phrases (2-5 words each) "
                + "describing the energy of that planet in that sign and house.\n\n"
                + "Return ONLY a valid JSON object � no markdown, no extra text � "
                + "where each key is the English planet name and the value is the 3 phrases separated by \\n.\n\n"
                + "Example format:\n"
                + "{\"Sun\": \"???????? ????? ???????\\n?????????? ?????\\n??????? ?????????\"}\n\n"
                + "Planets:\n" + planetList.toString();

            String raw = callClaude(prompt, language);
            if (raw == null) return java.util.Collections.emptyMap();

            String json = extractFirstJsonObject(raw);
            if (json == null) {
                throw new IllegalStateException("No JSON object found in Claude response");
            }

            org.json.JSONObject obj = new org.json.JSONObject(json);
            java.util.Map<String, String> result = new java.util.LinkedHashMap<>();
            for (String key : obj.keySet()) {
                result.put(key, obj.getString(key));
            }
            return result;
        } catch (Exception e) {
            System.err.println("Planet interpretations error: " + e.getMessage());
            return java.util.Collections.emptyMap();
        }
    }
    public java.util.Map<String, String> getPatternInterpretations(
            java.util.List<String> patterns,
            String language) {
        if (patterns == null || patterns.isEmpty()) return java.util.Collections.emptyMap();
        try {
            String langInstruction;
            switch (language) {
                case "Rus": langInstruction = "Answer in Russian."; break;
                case "Heb": langInstruction = "Answer in Hebrew."; break;
                case "Spa": langInstruction = "Answer in Spanish."; break;
                default:    langInstruction = "Answer in English."; break;
            }

            StringBuilder patternList = new StringBuilder();
            for (String p : patterns) {
                patternList.append("- ").append(p).append("\n");
            }

            String prompt = "You are a professional astrologer. " + langInstruction + "\n\n"
                + "For each astrological configuration below, write exactly 2-3 sentences "
                + "describing its meaning and influence in the natal chart.\n\n"
                + "Return ONLY a valid JSON object \u2014 no markdown, no extra text \u2014 "
                + "where each key is the EXACT configuration string provided and the value is your description.\n\n"
                + "Configurations:\n" + patternList.toString();

            String raw = callClaude(prompt, language);
            if (raw == null) return java.util.Collections.emptyMap();

            String json = extractFirstJsonObject(raw);
            if (json == null) {
                throw new IllegalStateException("No JSON object found in Claude response");
            }

            org.json.JSONObject obj = new org.json.JSONObject(json);
            java.util.Map<String, String> result = new java.util.LinkedHashMap<>();
            for (String key : obj.keySet()) {
                result.put(key, obj.getString(key));
            }
            return result;
        } catch (Exception e) {
            System.err.println("Pattern interpretations error: " + e.getMessage());
            return java.util.Collections.emptyMap();
        }
    }

    public java.util.Map<String, String> getAspectInterpretations(
            java.util.List<com.example.astrologyanalyzer.dto.ChartResponse.AspectInfo> aspects,
            String language) {
        if (aspects == null || aspects.isEmpty()) return java.util.Collections.emptyMap();
        try {
            // Keep only the 5 major Ptolemaic aspects, sorted by orb, capped at 15
            java.util.Set<String> major = new java.util.HashSet<>(java.util.Arrays.asList(
                "Conjunction", "Sextile", "Square", "Trine", "Opposition"
            ));
            java.util.List<com.example.astrologyanalyzer.dto.ChartResponse.AspectInfo> filtered =
                aspects.stream()
                    .filter(a -> major.contains(a.getAspect()))
                    .sorted(java.util.Comparator.comparingDouble(
                        com.example.astrologyanalyzer.dto.ChartResponse.AspectInfo::getOrb))
                    .limit(15)
                    .collect(java.util.stream.Collectors.toList());
            if (filtered.isEmpty()) return java.util.Collections.emptyMap();

            String langInstruction;
            switch (language) {
                case "Rus": langInstruction = "Answer in Russian."; break;
                case "Heb": langInstruction = "Answer in Hebrew."; break;
                case "Spa": langInstruction = "Answer in Spanish."; break;
                default:    langInstruction = "Answer in English."; break;
            }

            StringBuilder aspectList = new StringBuilder();
            for (com.example.astrologyanalyzer.dto.ChartResponse.AspectInfo a : filtered) {
                aspectList.append(a.getPlanet1()).append(" ").append(a.getAspect())
                          .append(" ").append(a.getPlanet2()).append("\n");
            }

            String prompt = "You are a professional astrologer. " + langInstruction + "\n\n"
                + "For each planetary aspect below, write exactly 1-2 sentences describing "
                + "its personal meaning in the natal chart.\n\n"
                + "Return ONLY a valid JSON object \u2014 no markdown, no extra text \u2014 "
                + "where each key is EXACTLY the aspect string provided (e.g. 'Sun Trine Moon') "
                + "and the value is your 1-2 sentence description.\n\n"
                + "Aspects:\n" + aspectList.toString();

            String raw = callClaude(prompt, language);
            if (raw == null) return java.util.Collections.emptyMap();

            String json = extractFirstJsonObject(raw);
            if (json == null) {
                throw new IllegalStateException("No JSON object found in Claude response");
            }

            org.json.JSONObject obj = new org.json.JSONObject(json);
            java.util.Map<String, String> result = new java.util.LinkedHashMap<>();
            for (String key : obj.keySet()) {
                result.put(key, obj.getString(key));
            }
            return result;
        } catch (Exception e) {
            System.err.println("Aspect interpretations error: " + e.getMessage());
            return java.util.Collections.emptyMap();
        }
    }

    private String escapeJson(String text) {
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "")
                   .replace("\t", "\\t");
    }

    private String extractFirstJsonObject(String raw) {
        if (raw == null) return null;
        String text = raw.trim();

        // Remove markdown code fences if present anywhere.
        if (text.contains("```")) {
            text = text.replaceAll("(?s)```[a-zA-Z]*\\n", "").replace("```", "").trim();
        }

        int start = text.indexOf('{');
        if (start < 0) return null;

        int depth = 0;
        boolean inString = false;
        boolean escaped = false;
        for (int i = start; i < text.length(); i++) {
            char c = text.charAt(i);

            if (inString) {
                if (escaped) {
                    escaped = false;
                } else if (c == '\\') {
                    escaped = true;
                } else if (c == '"') {
                    inString = false;
                }
                continue;
            }

            if (c == '"') {
                inString = true;
            } else if (c == '{') {
                depth++;
            } else if (c == '}') {
                depth--;
                if (depth == 0) {
                    return text.substring(start, i + 1);
                }
            }
        }

        return null;
    }

    private boolean isWeakInterpretation(String text) {
        if (text == null) return true;
        String normalized = text.trim();
        if (normalized.length() < 2200) return true;

        int headings = 0;
        for (int i = 0; i < normalized.length(); i++) {
            if (normalized.charAt(i) == '#') headings++;
        }
        if (headings < 6) return true;

        return false;
    }

    /**
     * Fallback transit interpretation when Claude API fails.
     * Parses transit data and returns structured daily guidance.
     */
    private String getFallbackTransitInterpretation(String transitData, String language) {
        StringBuilder result = new StringBuilder();
        java.util.LinkedHashSet<Integer> houses = new java.util.LinkedHashSet<>();
        java.util.regex.Matcher matcher = java.util.regex.Pattern.compile("\\(House\\s*(\\d{1,2})\\)").matcher(transitData != null ? transitData : "");
        while (matcher.find()) {
            try {
                houses.add(Integer.parseInt(matcher.group(1)));
            } catch (NumberFormatException ignored) {
                // Ignore malformed house numbers.
            }
        }
        java.util.regex.Matcher jsonHouseMatcher = java.util.regex.Pattern
                .compile("\\\"transitHouse\\\"\\s*:\\s*(\\d{1,2})")
                .matcher(transitData != null ? transitData : "");
        while (jsonHouseMatcher.find()) {
            try {
                houses.add(Integer.parseInt(jsonHouseMatcher.group(1)));
            } catch (NumberFormatException ignored) {
                // Ignore malformed house numbers.
            }
        }
        
        String title, intro, money, relationships, emotions, whatToDo, whereNot, summary;
        if ("Rus".equals(language)) {
            class TransitRow {
                String tp;
                String ts;
                int th;
                String np;
                String asp;
                double orb;
            }

            java.util.List<TransitRow> rows = new java.util.ArrayList<>();
            try {
                JSONObject source = new JSONObject(transitData != null ? transitData : "{}");
                JSONArray arr = source.optJSONArray("transits");
                if (arr != null) {
                    for (int i = 0; i < arr.length(); i++) {
                        JSONObject t = arr.optJSONObject(i);
                        if (t == null) continue;

                        TransitRow r = new TransitRow();
                        r.tp = t.optString("transitPlanet", "");
                        r.ts = t.optString("transitSign", "");
                        r.th = t.optInt("transitHouse", 0);
                        r.np = t.optString("natalPlanet", "");
                        r.asp = t.optString("aspect", "");
                        r.orb = t.optDouble("orb", 0.0);

                        if (!r.tp.isBlank() && r.th > 0) {
                            rows.add(r);
                            houses.add(r.th);
                        }
                    }
                }
            } catch (Exception ignored) {
                // Keep fallback resilient; if JSON parsing fails we continue with minimal template output.
            }

            if (rows.isEmpty()) {
                title = "# Транзиты на сегодня\n";
                intro = "## Введение\nТранзиты активны, но подробный структурный разбор временно недоступен. Ниже — базовый фокус по домам.\n";
                StringBuilder houseFocus = new StringBuilder("## Фокус по домам\n");
                for (Integer house : houses) {
                    houseFocus.append("- Дом ").append(house).append(": ").append(getTransitHouseMeaning(house, language)).append("\n");
                }
                result.append(title)
                      .append("\n").append(intro)
                      .append("\n").append(houseFocus)
                      .append("\n\n*Примечание: детальный разбор будет доступен при активном Claude API.*");
                return result.toString();
            }

            java.util.Set<String> fastSet = new java.util.LinkedHashSet<>(java.util.Arrays.asList("Sun", "Moon", "Mercury", "Venus", "Mars"));
            java.util.Set<String> slowSet = new java.util.LinkedHashSet<>(java.util.Arrays.asList("Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"));

            java.util.Map<String, java.util.List<TransitRow>> byTransitPlanet = new java.util.LinkedHashMap<>();
            java.util.Map<Integer, Integer> houseCounts = new java.util.HashMap<>();
            java.util.Map<String, java.util.Set<String>> natalToTransitPlanets = new java.util.HashMap<>();
            java.util.List<TransitRow> exactRows = new java.util.ArrayList<>();

            for (TransitRow r : rows) {
                byTransitPlanet.computeIfAbsent(r.tp, k -> new java.util.ArrayList<>()).add(r);
                houseCounts.put(r.th, houseCounts.getOrDefault(r.th, 0) + 1);
                natalToTransitPlanets.computeIfAbsent(r.np, k -> new java.util.LinkedHashSet<>()).add(r.tp);
                if (r.orb < 1.0) {
                    exactRows.add(r);
                }
            }

            java.util.List<String> fastPlanets = new java.util.ArrayList<>();
            java.util.List<String> slowPlanets = new java.util.ArrayList<>();
            for (String tp : byTransitPlanet.keySet()) {
                if (fastSet.contains(tp)) fastPlanets.add(tp);
                if (slowSet.contains(tp)) slowPlanets.add(tp);
            }

            result.append("# Разбор активных транзитов\n\n");
            result.append("## 1) Быстрые и медленные планеты\n");
            result.append("- **Быстрые:** ");
            if (fastPlanets.isEmpty()) {
                result.append("нет данных\n");
            } else {
                result.append(String.join(", ", fastPlanets.stream().map(this::ruPlanetName).toList())).append("\n");
            }
            result.append("- **Медленные:** ");
            if (slowPlanets.isEmpty()) {
                result.append("нет данных\n");
            } else {
                result.append(String.join(", ", slowPlanets.stream().map(this::ruPlanetName).toList())).append("\n");
            }

            result.append("\n## 2) Анализ по транзитным планетам\n");
            for (java.util.Map.Entry<String, java.util.List<TransitRow>> e : byTransitPlanet.entrySet()) {
                String tp = e.getKey();
                java.util.List<TransitRow> list = e.getValue();
                TransitRow anchor = list.get(0);

                result.append("### ").append(ruPlanetName(tp))
                      .append(" в доме ").append(anchor.th)
                      .append(" (знак ").append(anchor.ts).append(")\n");
                result.append("- Общий фокус: ").append(getTransitHouseMeaning(anchor.th, "Rus")).append(".\n");
                result.append("- Аспекты к наталу:\n");

                list.sort(java.util.Comparator.comparingDouble(r -> r.orb));
                for (TransitRow r : list) {
                    result.append("  - ")
                          .append(ruAspectName(r.asp)).append(" к ")
                          .append(ruPlanetName(r.np)).append(" (орб ")
                          .append(String.format(java.util.Locale.US, "%.2f", r.orb)).append("°)")
                          .append(r.orb < 1.0 ? " **[точный]**" : "")
                          .append("\n");
                }
            }

            result.append("\n## 3) Повторяющиеся темы\n");
            boolean repeatedFound = false;
            for (java.util.Map.Entry<String, java.util.Set<String>> entry : natalToTransitPlanets.entrySet()) {
                if (entry.getValue().size() >= 2) {
                    repeatedFound = true;
                    result.append("- ")
                          .append(ruPlanetName(entry.getKey()))
                          .append(" получает давление/активацию сразу от нескольких транзитных планет: ")
                          .append(String.join(", ", entry.getValue().stream().map(this::ruPlanetName).toList()))
                          .append(". Это усиленная тема периода.\n");
                }
            }
            if (!repeatedFound) {
                result.append("- Явно повторяющихся многократных ударов по одной натальной точке немного; акценты распределены по нескольким сферам.\n");
            }

            java.util.List<java.util.Map.Entry<Integer, Integer>> topHouses = new java.util.ArrayList<>(houseCounts.entrySet());
            topHouses.sort((a, b) -> Integer.compare(b.getValue(), a.getValue()));
            java.util.List<TransitRow> topExact = new java.util.ArrayList<>(exactRows);
            topExact.sort(java.util.Comparator.comparingDouble(r -> r.orb));

            result.append("\n## 4) Главный узел периода\n");
            if (!topHouses.isEmpty()) {
                int h1 = topHouses.get(0).getKey();
                result.append("- Ведущая сцена периода: **дом ").append(h1).append("** — ")
                      .append(getTransitHouseMeaning(h1, "Rus")).append(".\n");
                if (topHouses.size() > 1) {
                    int h2 = topHouses.get(1).getKey();
                    result.append("- Второй акцент: **дом ").append(h2).append("** — ")
                          .append(getTransitHouseMeaning(h2, "Rus")).append(".\n");
                }
            }
            if (!topExact.isEmpty()) {
                TransitRow r = topExact.get(0);
                result.append("- Наиболее точный триггер сейчас: ")
                      .append(ruPlanetName(r.tp)).append(" ")
                      .append(ruAspectName(r.asp)).append(" ")
                      .append(ruPlanetName(r.np)).append(" (орб ")
                      .append(String.format(java.util.Locale.US, "%.2f", r.orb)).append("°).\n");
            }
            result.append("- Взаимодействие тем: краткосрочные эмоциональные/событийные волны от быстрых планет накладываются на более длинные решения и перестройки, и это требует осознанной приоритизации в ключевых домах.\n");

            result.append("\n*Примечание: это fallback-разбор по структуре при недоступном Claude API.*");
            return result.toString();
        } else if ("Heb".equals(language)) {
            title = "# מעברים היום — הדרכה מובנית\n";
            intro = "## הקדמה\nיש מעברים משמעותיים פעילים היום. הניתוח המובנה להלן יעזור לך לתמצא את אנרגיות היום.\n";
            StringBuilder houseFocus = new StringBuilder("## מיקוד לפי בתים\n");
            for (Integer house : houses) {
                houseFocus.append("- בית ").append(house).append(": ").append(getTransitHouseMeaning(house, language)).append("\n");
            }
            money = "## כסף ועבודה היום\n- היזהר בהחלטות כלכליות גדולות\n- התמקד בהתחייבויות הנוכחיות\n- יום טוב לתכנון, לא לסיכון\n";
            relationships = "## יחסים היום\n- תקשורת דורשת תשומת לב נוספת\n- קשוב יותר מהרגיל\n- פגישות ושיחות מעניינות אפשריות\n";
            emotions = "## רקע רגשי\n- הרגשות יכולים להיות אינטנסיביים\n- צא זמן להשתקפות פנימיות\n- אל תמהר בהחלטות רגשיות\n";
            whatToDo = "## מה לעשות היום\n- התרגל בהמנמוניקה או מודעות\n- התמקד בעניינים מעשיים\n- דבר עם אנשים שאתה מעריך\n- תכנן זמן לפיתוח אישי\n";
            whereNot = "## איפה לא לבזבז אנרגיה\n- הימנע מעימותים וויכוחים\n- אל תקבל החלטות חיגרות\n- אל תתחיל פרויקטים חדשים ללא הכנה\n- אל תתעלם מהאינטואיציה שלך\n";
            summary = "**סיכום יומי:** היום דורש איזון אנרגיות ויחס קשוב לפרטים.";
            result.append(title)
                  .append("\n").append(intro)
                  .append("\n").append(houseFocus)
                  .append("\n").append(money)
                  .append("\n").append(relationships)
                  .append("\n").append(emotions)
                  .append("\n").append(whatToDo)
                  .append("\n").append(whereNot)
                  .append("\n").append(summary)
                  .append("\n\n---\n*Note: This interpretation was generated using structural templates. For deeper insights, please ensure your Claude API key is properly configured.*");
            return result.toString();
        } else if ("Spa".equals(language)) {
            title = "# Tránsitos de Hoy — Guía Estructurada\n";
            intro = "## Introducción\nHay tránsitos significativos activos hoy. El análisis estructurado a continuación te ayudará a navegar las energías del día.\n";
            StringBuilder houseFocus = new StringBuilder("## Enfoque por casas\n");
            for (Integer house : houses) {
                houseFocus.append("- Casa ").append(house).append(": ").append(getTransitHouseMeaning(house, language)).append("\n");
            }
            money = "## Dinero y Trabajo Hoy\n- Ten cuidado con decisiones financieras grandes\n- Enfócate en obligaciones actuales\n- Buen día para planificar, no para riesgo\n";
            relationships = "## Relaciones Hoy\n- La comunicación requiere atención adicional\n- Escucha más de lo usual\n- Encuentros y conversaciones interesantes posibles\n";
            emotions = "## Fondo Emocional\n- Los sentimientos pueden ser intensos\n- Encuentra tiempo para reflexión interna\n- No te apresures con decisiones emocionales\n";
            whatToDo = "## Qué Hacer Hoy\n- Medita o practica mindfulness\n- Enfócate en asuntos prácticos\n- Habla con gente que valoras\n- Planifica tiempo para desarrollo personal\n";
            whereNot = "## Dónde No Gastar Energía\n- Evita conflictos y debates\n- No tomes decisiones precipitadas\n- No inicies proyectos nuevos sin preparación\n- No ignores tu intuición\n";
            summary = "**Resumen Diario:** El día requiere equilibrio de energías y atención cuidadosa a los detalles.";
            result.append(title)
                  .append("\n").append(intro)
                  .append("\n").append(houseFocus)
                  .append("\n").append(money)
                  .append("\n").append(relationships)
                  .append("\n").append(emotions)
                  .append("\n").append(whatToDo)
                  .append("\n").append(whereNot)
                  .append("\n").append(summary)
                  .append("\n\n---\n*Note: This interpretation was generated using structural templates. For deeper insights, please ensure your Claude API key is properly configured.*");
            return result.toString();
        } else {
            title = "# Transits for Today — Structured Guidance\n";
            intro = "## Introduction\nSignificant transits are active today. The structured analysis below will help you navigate the day's energies.\n";
            StringBuilder houseFocus = new StringBuilder("## House Focus\n");
            for (Integer house : houses) {
                houseFocus.append("- House ").append(house).append(": ").append(getTransitHouseMeaning(house, language)).append("\n");
            }
            money = "## Money and Work Today\n- Be cautious with major financial decisions\n- Focus on current obligations\n- Good day for planning, not for risk-taking\n";
            relationships = "## Relationships Today\n- Communication requires extra attention\n- Listen more than usual\n- Interesting meetings and conversations possible\n";
            emotions = "## Emotional Background\n- Feelings may be intense\n- Find time for inner reflection\n- Don't rush emotional decisions\n";
            whatToDo = "## What to Do Today\n- Meditate or practice mindfulness\n- Focus on practical matters\n- Talk with people you value\n- Plan time for personal development\n";
            whereNot = "## Where Not to Spend Energy\n- Avoid conflicts and arguments\n- Don't make hasty decisions\n- Don't start new projects without preparation\n- Don't ignore your intuition\n";
            summary = "**Daily Summary:** The day requires energy balance and careful attention to details.";
            result.append(title)
                  .append("\n").append(intro)
                  .append("\n").append(houseFocus)
                  .append("\n").append(money)
                  .append("\n").append(relationships)
                  .append("\n").append(emotions)
                  .append("\n").append(whatToDo)
                  .append("\n").append(whereNot)
                  .append("\n").append(summary)
                  .append("\n\n---\n*Note: This interpretation was generated using structural templates. For deeper insights, please ensure your Claude API key is properly configured.*");
            return result.toString();
        }
    }

    private String getTransitHouseMeaning(int house, String language) {
        switch (house) {
            case 1:
                return translate(language,
                        "identity, body, and personal initiative",
                        "личная идентичность, тело и инициатива",
                        "זהות אישית, גוף ויוזמה",
                        "identidad, cuerpo e iniciativa personal");
            case 2:
                return translate(language,
                        "money, values, and self-worth",
                        "деньги, ценности и самооценка",
                        "כסף, ערכים ושווי עצמי",
                        "dinero, valores y autoestima");
            case 3:
                return translate(language,
                        "communication, learning, and daily movement",
                        "общение, обучение и повседневные контакты",
                        "תקשורת, למידה ותנועה יומיומית",
                        "comunicacion, aprendizaje y movimiento diario");
            case 4:
                return translate(language,
                        "home, roots, and emotional foundations",
                        "дом, корни и эмоциональная опора",
                        "בית, שורשים ובסיס רגשי",
                        "hogar, raices y base emocional");
            case 5:
                return translate(language,
                        "creativity, romance, and self-expression",
                        "творчество, романтика и самовыражение",
                        "יצירה, רומנטיקה וביטוי עצמי",
                        "creatividad, romance y expresion personal");
            case 6:
                return translate(language,
                        "work, routines, and wellbeing",
                        "работа, режим и здоровье",
                        "עבודה, שגרה ורווחה",
                        "trabajo, rutinas y bienestar");
            case 7:
                return translate(language,
                        "partnerships, relationships, and cooperation",
                        "партнерство, отношения и сотрудничество",
                        "שותפויות, יחסים ושיתוף פעולה",
                        "pareja, relaciones y cooperacion");
            case 8:
                return translate(language,
                        "shared resources, trust, and transformation",
                        "общие ресурсы, доверие и трансформация",
                        "משאבים משותפים, אמון וטרנספורמציה",
                        "recursos compartidos, confianza y transformacion");
            case 9:
                return translate(language,
                        "travel, beliefs, and expansion of perspective",
                        "путешествия, вера и расширение горизонтов",
                        "מסע, אמונות והרחבת אופקים",
                        "viajes, creencias y expansion de perspectiva");
            case 10:
                return translate(language,
                        "career, reputation, and public direction",
                        "карьера, репутация и публичное направление",
                        "קריירה, מוניטין וכיוון ציבורי",
                        "carrera, reputacion y direccion publica");
            case 11:
                return translate(language,
                        "community, friendships, and future goals",
                        "сообщество, друзья и цели будущего",
                        "קהילה, חברויות ומטרות עתידיות",
                        "comunidad, amistades y metas futuras");
            case 12:
                return translate(language,
                        "inner life, healing, and release",
                        "внутренний мир, исцеление и отпускание",
                        "עולם פנימי, ריפוי ושחרור",
                        "vida interior, sanacion y soltar");
            default:
                return translate(language,
                        "an important life area",
                        "важная жизненная сфера",
                        "תחום חיים חשוב",
                        "un area importante de vida");
        }
    }

    private String ruPlanetName(String name) {
        if (name == null) return "планета";
        switch (name) {
            case "Sun": return "Солнце";
            case "Moon": return "Луна";
            case "Mercury": return "Меркурий";
            case "Venus": return "Венера";
            case "Mars": return "Марс";
            case "Jupiter": return "Юпитер";
            case "Saturn": return "Сатурн";
            case "Uranus": return "Уран";
            case "Neptune": return "Нептун";
            case "Pluto": return "Плутон";
            case "Ascendant": return "Асцендент";
            case "North Node": return "Северный узел";
            case "South Node": return "Южный узел";
            default: return name;
        }
    }

    private String ruAspectName(String aspect) {
        if (aspect == null) return "аспект";
        switch (aspect) {
            case "Conjunction": return "соединение";
            case "Sextile": return "секстиль";
            case "Square": return "квадрат";
            case "Trine": return "трин";
            case "Opposition": return "оппозиция";
            case "Quincunx": return "квинконс";
            default: return aspect;
        }
    }

    private String translate(String language, String english, String russian, String hebrew, String spanish) {
        switch (language) {
            case "Rus":
                return russian;
            case "Heb":
                return hebrew;
            case "Spa":
                return spanish;
            default:
                return english;
        }
    }
}
