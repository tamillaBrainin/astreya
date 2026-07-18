package com.example.astrologyanalyzer;

import java.util.HashMap;

public class Data {

    private Integer number;
    private HashMap<Integer, Planet> planetMap;
    private double julianDay;

    public Data(Integer number, HashMap<Integer, Planet> planetMap, double julianDay) {
        this.number = number;
        this.planetMap = planetMap;
        this.julianDay = julianDay;
    }

    public Data() {
    }

    public Integer getNumber() {
        return number;
    }

    public void setNumber(Integer number) {
        this.number = number;
    }

    public HashMap<Integer, Planet> getPlanetMap() {
        return planetMap;
    }

    public void setPlanetMap(HashMap<Integer, Planet> planetMap) {
        this.planetMap = planetMap;
    }

    public double getJulianDay() {
        return julianDay;
    }

    public void setJulianDay(double julianDay) {
        this.julianDay = julianDay;
    }
}
