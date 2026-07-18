package com.example.astrologyanalyzer;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONObject;
import org.telegram.telegrambots.bots.TelegramLongPollingBot;
import org.telegram.telegrambots.meta.api.objects.Update;
import org.telegram.telegrambots.meta.TelegramBotsApi;
import org.telegram.telegrambots.meta.api.methods.send.SendMessage;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;
import org.telegram.telegrambots.updatesreceivers.DefaultBotSession;

import java.io.OutputStream;

public class MyTelegramBot extends TelegramLongPollingBot {

    // Store user state
    private static final Map<Long, String> userState = new HashMap<>();
    private static final Map<Long, String> userLanguage = new HashMap<>();
    private static final Map<Long, String> userBirthDate = new HashMap<>();
    private static final Map<Long, String> userBirthTime = new HashMap<>();
    private static final Map<Long, String> userLatitude = new HashMap<>();
    private static final Map<Long, String> userLongitude = new HashMap<>();
    private static final Map<Long, String> userBirthPlace = new HashMap<>();
    // Store natal UT data for transit calculation
    private static final Map<Long, int[]> userNatalUT = new HashMap<>(); // [utYear, utMonth, utDay]
    private static final Map<Long, Double> userNatalUTTime = new HashMap<>();

    @Override
    public void onUpdateReceived(Update update) {
        System.out.println("DEBUG: Received update: " + update.toString());

        if (update.hasMessage() && update.getMessage().hasText()) {
            Long chatId = update.getMessage().getChatId();
            String userInput = update.getMessage().getText().trim();
            System.out.println("DEBUG: ChatId=" + chatId + ", Input=" + userInput);

            SendMessage message = new SendMessage();
            message.setChatId(chatId.toString());

            if (!userState.containsKey(chatId)) {
                System.out.println("DEBUG: New user, asking for language");
                message.setText("In what language do you want your natal description? Russian or English or Hebrew? Please write it.");
                userState.put(chatId, "waiting_for_language");
            } else if (userState.get(chatId).equals("waiting_for_language")) {
                System.out.println("DEBUG: Processing language: " + userInput);
                if (userInput.equalsIgnoreCase("Russian")) {
                    userLanguage.put(chatId, "Rus");
                    message.setText("Please enter your date of birth in the format: day-month-year (e.g., 12-12-1979).");
                    userState.put(chatId, "waiting_for_date");
                } else if (userInput.equalsIgnoreCase("English")) {
                    userLanguage.put(chatId, "Eng");
                    message.setText("Please enter your date of birth in the format: day-month-year (e.g., 12-12-1979).");
                    userState.put(chatId, "waiting_for_date");
                } else if (userInput.equalsIgnoreCase("Hebrew")) {
                    userLanguage.put(chatId, "Heb");
                    message.setText("Please enter your date of birth in the format: day-month-year (e.g., 12-12-1979).");
                    userState.put(chatId, "waiting_for_date");
                } else {
                    message.setText("Invalid choice. Please type 'Russian', 'English', or 'Hebrew'.");
                }
            } else if (userState.get(chatId).equals("waiting_for_date")) {
                SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");
                dateFormat.setLenient(false);
                try {
                    dateFormat.parse(userInput);
                    userBirthDate.put(chatId, userInput);
                    message.setText("Please enter your time of birth in the format: HH:mm (e.g., 14:30 for 2:30 PM).");
                    userState.put(chatId, "waiting_for_time");
                } catch (ParseException e) {
                    message.setText("Invalid date format. Please enter in the format dd-MM-yyyy.");
                }
            } else if (userState.get(chatId).equals("waiting_for_time")) {
                SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
                timeFormat.setLenient(false);
                try {
                    timeFormat.parse(userInput);
                    userBirthTime.put(chatId, userInput);
                    message.setText("Please enter your place of birth (e.g., New York, London, Moscow).");
                    userState.put(chatId, "waiting_for_place");
                } catch (ParseException e) {
                    message.setText("Invalid time format. Please enter in the format HH:mm (e.g., 14:30).");
                }
            } else if (userState.get(chatId).equals("waiting_for_place")) {
                String[] coordinates = getCoordinates(userInput);
                if (coordinates != null) {
                    userBirthPlace.put(chatId, userInput);
                    userLatitude.put(chatId, coordinates[0]);
                    userLongitude.put(chatId, coordinates[1]);

                    // Retrieve stored values
                    String birthDate = userBirthDate.get(chatId);
                    String birthTime = userBirthTime.get(chatId);
                    String birthPlace = userBirthPlace.get(chatId);
                    String language = userLanguage.get(chatId);

                    String[] dateParts = birthDate.split("-");
                    int day = Integer.parseInt(dateParts[0]);
                    int month = Integer.parseInt(dateParts[1]);
                    int year = Integer.parseInt(dateParts[2]);

                    String[] timeParts = birthTime.split(":");
                    int hour = Integer.parseInt(timeParts[0]);
                    int minute = Integer.parseInt(timeParts[1]);
                    double localTime = hour + (minute / 60.0);

                    // Convert local time to UT using longitude-based timezone offset
                    double lon = Double.parseDouble(coordinates[1]);
                    long tzOffset = Math.round(lon / 15.0);
                    double utTime = localTime - tzOffset;
                    int utDay = day;
                    int utMonth = month;
                    int utYear = year;

                    if (utTime < 0) {
                        utTime += 24;
                        utDay--;
                        if (utDay < 1) {
                            utMonth--;
                            if (utMonth < 1) {
                                utMonth = 12;
                                utYear--;
                            }
                            utDay = getLastDayOfMonth(utMonth, utYear);
                        }
                    } else if (utTime >= 24) {
                        utTime -= 24;
                        utDay++;
                        int lastDay = getLastDayOfMonth(utMonth, utYear);
                        if (utDay > lastDay) {
                            utDay = 1;
                            utMonth++;
                            if (utMonth > 12) {
                                utMonth = 1;
                                utYear++;
                            }
                        }
                    }

                    // Perform transit analysis using pure Java math
                    ArrayList<String> transitAnalysis = AstrologyAnalyzer.analyzeTransits(
                            utYear, utMonth, utDay, utTime, coordinates[0], coordinates[1], language);

                    // Print house table to console
                    System.out.println("\n=== PLANET HOUSES ===");
                    HouseCalculator.getPlanetHouses(utYear, utMonth, utDay, utTime, coordinates[0], coordinates[1]);

                    // Format natal data for potential AI interpretation
                    StringBuilder natalData = new StringBuilder();
                    for (String transit : transitAnalysis) {
                        natalData.append(transit).append("\n");
                    }

                    // Claude interpretation
                    String claudeInterpretation = getClaudeInterpretation(natalData.toString(), language);

                    // Format the results
                    StringBuilder formattedTransits = new StringBuilder();
                    for (String transit : transitAnalysis) {
                        formattedTransits.append("• ").append(transit).append("\n");
                    }

                    String responseText = "📅 Date accepted: " + birthDate +
                            "\n⏰ Time accepted: " + birthTime +
                            "\n📍 Place: " + birthPlace +
                            "\n🌐 Language: " + language +
                            "\n\n🔮 Natal :\n" + formattedTransits.toString();

                    if (claudeInterpretation != null && !claudeInterpretation.isEmpty()) {
                        responseText += "\n\n🔮 Interpretation:\n" + claudeInterpretation;
                    }

                    // Telegram messages have a 4096 char limit, split if needed
                    if (responseText.length() <= 4096) {
                        message.setText(responseText);
                    } else {
                        message.setText(responseText.substring(0, 4096));
                        try {
                            execute(message);
                        } catch (TelegramApiException e) {
                            e.printStackTrace();
                        }
                        String remaining = responseText.substring(4096);
                        while (remaining.length() > 0) {
                            SendMessage extraMsg = new SendMessage();
                            extraMsg.setChatId(chatId.toString());
                            int end = Math.min(remaining.length(), 4096);
                            extraMsg.setText(remaining.substring(0, end));
                            remaining = remaining.substring(end);
                            try {
                                execute(extraMsg);
                            } catch (TelegramApiException e) {
                                e.printStackTrace();
                            }
                        }
                        message = null;
                    }

                    // Store natal UT data for potential transit calculation
                    userNatalUT.put(chatId, new int[]{utYear, utMonth, utDay});
                    userNatalUTTime.put(chatId, utTime);
                    userState.put(chatId, "waiting_for_transit_choice");

                    // Ask about transits
                    SendMessage transitAsk = new SendMessage();
                    transitAsk.setChatId(chatId.toString());
                    transitAsk.setText("🌟 Would you like to see today's transits for your natal chart? (Yes / No)");
                    try {
                        execute(transitAsk);
                    } catch (TelegramApiException e) {
                        e.printStackTrace();
                    }
                } else {
                    message.setText("Sorry, I couldn't find this place. Please try another city.");
                }
            } else if (userState.get(chatId).equals("waiting_for_transit_choice")) {
                if (userInput.equalsIgnoreCase("Yes") || userInput.equalsIgnoreCase("Da") 
                        || userInput.equalsIgnoreCase("Да") || userInput.equalsIgnoreCase("כן")) {

                    int[] natalUT = userNatalUT.get(chatId);
                    double natalUTTime = userNatalUTTime.get(chatId);
                    String lat = userLatitude.get(chatId);
                    String lon = userLongitude.get(chatId);
                    String language = userLanguage.get(chatId);

                    ArrayList<String> transits = NatalChartCalculator.calculateTransits(
                            natalUT[0], natalUT[1], natalUT[2], natalUTTime, lat, lon, language);

                    StringBuilder transitText = new StringBuilder();
                    for (String t : transits) {
                        transitText.append(t).append("\n");
                    }

                    String transitResponse = "🌟 Today's Transits:\n\n" + transitText.toString();

                    // Send transit results (split if needed)
                    sendLongMessage(chatId, transitResponse);
                    message = null;

                    clearUserState(chatId);
                } else {
                    message.setText("✨ Thank you! Send any message to start a new reading.");
                    clearUserState(chatId);
                }
            }

            try {
                if (message != null) {
                    execute(message);
                }
            } catch (TelegramApiException e) {
                e.printStackTrace();
            }
        }
    }

    private static int getLastDayOfMonth(int month, int year) {
        switch (month) {
            case 2: return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28;
            case 4: case 6: case 9: case 11: return 30;
            default: return 31;
        }
    }

    private void clearUserState(Long chatId) {
        userState.remove(chatId);
        userLanguage.remove(chatId);
        userBirthDate.remove(chatId);
        userBirthTime.remove(chatId);
        userBirthPlace.remove(chatId);
        userLatitude.remove(chatId);
        userLongitude.remove(chatId);
        userNatalUT.remove(chatId);
        userNatalUTTime.remove(chatId);
    }

    private void sendLongMessage(Long chatId, String text) {
        String remaining = text;
        while (remaining.length() > 0) {
            int end = Math.min(remaining.length(), 4096);
            SendMessage msg = new SendMessage();
            msg.setChatId(chatId.toString());
            msg.setText(remaining.substring(0, end));
            remaining = remaining.substring(end);
            try {
                execute(msg);
            } catch (TelegramApiException e) {
                e.printStackTrace();
            }
        }
    }

    public static String[] getCoordinates(String city) {
        try {
            String encodedCity = URLEncoder.encode(city, "UTF-8");
            String url = "https://nominatim.openstreetmap.org/search?q=" + encodedCity + "&format=json&limit=1";

            HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();
            connection.setRequestProperty("User-Agent", "JavaGeoBot/1.0 (your@email.com)");

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
                String lat = location.getString("lat");
                String lon = location.getString("lon");
                return new String[]{lat, lon};
            } else {
                return null;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private String getClaudeInterpretation(String natalData, String language) {
        try {
            String langInstruction;
            switch (language) {
                case "Rus": langInstruction = "Answer in Russian."; break;
                case "Heb": langInstruction = "Answer in Hebrew."; break;
                default: langInstruction = "Answer in English."; break;
            }

            String prompt = "You are a professional astrologer. Based on the following natal chart data, "
                    + "provide a detailed and insightful astrological interpretation. "
                    + "Describe the person's character, strengths, challenges, and life themes based on "
                    + "the planet positions, signs, and houses. " + langInstruction + "\n\n"
                    + "Natal Chart Data:\n" + natalData;

            String escapedPrompt = prompt.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "")
                    .replace("\t", "\\t");

            String requestBody = "{\"model\": \"claude-sonnet-4-20250514\", "
                    + "\"max_tokens\": 4000, "
                    + "\"messages\": [{\"role\": \"user\", \"content\": \"" + escapedPrompt + "\"}]}";

            URL url = new URL("https://api.anthropic.com/v1/messages");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            String claudeApiKey = System.getenv("CLAUDE_API_KEY");
            if (claudeApiKey == null || claudeApiKey.isEmpty()) {
                throw new IllegalStateException("CLAUDE_API_KEY is not set");
            }
            conn.setRequestProperty("x-api-key", claudeApiKey);
            conn.setRequestProperty("anthropic-version", "2023-06-01");
            conn.setDoOutput(true);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(requestBody.getBytes("UTF-8"));
            }

            int statusCode = conn.getResponseCode();
            System.out.println("Claude API Status: " + statusCode);

            BufferedReader reader = new BufferedReader(new InputStreamReader(
                    statusCode == 200 ? conn.getInputStream() : conn.getErrorStream()));
            StringBuilder responseBody = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                responseBody.append(line);
            }
            reader.close();

            System.out.println("Claude API Response: " + responseBody.toString());

            if (statusCode == 200) {
                JSONObject json = new JSONObject(responseBody.toString());
                String text = json.getJSONArray("content").getJSONObject(0).getString("text");
                return text;
            } else {
                System.err.println("Claude API error: " + responseBody.toString());
                return null;
            }
        } catch (Exception e) {
            System.err.println("Error calling Claude API:");
            e.printStackTrace();
            return null;
        }
    }

    @Override
    public String getBotUsername() {
        return "AstrologycalBot";
    }

    @Override
    public String getBotToken() {
        return "7235328351:AAG2rHAANf5kyki75DssCxmJZXgNWUxy7_g";
    }

    public static void main(String[] args) {
        System.out.println("Starting bot...");
        try {
            TelegramBotsApi botsApi = new TelegramBotsApi(DefaultBotSession.class);
            System.out.println("TelegramBotsApi initialized.");
            MyTelegramBot bot = new MyTelegramBot();
            botsApi.registerBot(bot);
            System.out.println("Bot successfully started and registered!");
            System.out.println("Bot username: " + bot.getBotUsername());
            System.out.println("Bot is now listening for messages...");

            while (true) {
                Thread.sleep(1000);
            }
        } catch (TelegramApiException e) {
            System.out.println("ERROR initializing TelegramBotsApi:");
            e.printStackTrace();
        } catch (Exception e) {
            System.out.println("ERROR: Unexpected exception:");
            e.printStackTrace();
        }
    }
}
