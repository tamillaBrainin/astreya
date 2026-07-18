package com.example.astrologyanalyzer.dto;

public class BirthDataRequest {
    private int year;
    private int month;
    private int day;
    private int hour;
    private int minute;
    private String city;
    private String language; // "Eng", "Rus", "Heb"
    private double utcOffset; // hours offset from UTC, e.g. +5 for Tashkent

    // Resolved from city by GeocodingService – not sent by the UI
    private double latitude;
    private double longitude;

    public BirthDataRequest() {}

    /** Convert hour + minute to decimal time (e.g. 14:30 → 14.5) */
    public double getDecimalTime() {
        return hour + (minute / 60.0);
    }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }
    public int getMonth() { return month; }
    public void setMonth(int month) { this.month = month; }
    public int getDay() { return day; }
    public void setDay(int day) { this.day = day; }
    public int getHour() { return hour; }
    public void setHour(int hour) { this.hour = hour; }
    public int getMinute() { return minute; }
    public void setMinute(int minute) { this.minute = minute; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }
    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }
    public String getLanguage() { return language; }
    public void setLanguage(String language) { this.language = language; }
    public double getUtcOffset() { return utcOffset; }
    public void setUtcOffset(double utcOffset) { this.utcOffset = utcOffset; }
}
