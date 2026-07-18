package com.example.astrologyanalyzer.dto;

public class PlanetPosition {
    private String name;
    private String sign;
    private double degrees;
    private double longitude;
    private int house;
    private boolean retrograde;

    public PlanetPosition() {}

    public PlanetPosition(String name, String sign, double degrees, double longitude, int house, boolean retrograde) {
        this.name = name;
        this.sign = sign;
        this.degrees = degrees;
        this.longitude = longitude;
        this.house = house;
        this.retrograde = retrograde;
    }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getSign() { return sign; }
    public void setSign(String sign) { this.sign = sign; }
    public double getDegrees() { return degrees; }
    public void setDegrees(double degrees) { this.degrees = degrees; }
    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }
    public int getHouse() { return house; }
    public void setHouse(int house) { this.house = house; }
    public boolean isRetrograde() { return retrograde; }
    public void setRetrograde(boolean retrograde) { this.retrograde = retrograde; }
}
