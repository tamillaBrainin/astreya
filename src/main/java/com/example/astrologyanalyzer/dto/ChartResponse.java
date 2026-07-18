package com.example.astrologyanalyzer.dto;

import java.util.List;

public class ChartResponse {
    private List<PlanetPosition> planets;
    private List<HouseInfo> houses;
    private double ascendant;
    private String ascendantSign;
    private double mc;
    private String mcSign;
    private ParsFortunaInfo parsFortuna;
    private List<String> patterns; // Yod, T-Sq
    private List<AspectInfo> aspects;
    private String interpretation; // Claude AI interpretation
    private java.util.Map<String, String> planetaryInterpretations; // per-planet phrases
    private java.util.Map<String, String> patternInterpretations; // per-pattern Claude description
    private java.util.Map<String, String> aspectInterpretations;  // per-aspect Claude description

    public ChartResponse() {}

    public List<PlanetPosition> getPlanets() { return planets; }
    public void setPlanets(List<PlanetPosition> planets) { this.planets = planets; }
    public List<HouseInfo> getHouses() { return houses; }
    public void setHouses(List<HouseInfo> houses) { this.houses = houses; }
    public double getAscendant() { return ascendant; }
    public void setAscendant(double ascendant) { this.ascendant = ascendant; }
    public String getAscendantSign() { return ascendantSign; }
    public void setAscendantSign(String ascendantSign) { this.ascendantSign = ascendantSign; }
    public double getMc() { return mc; }
    public void setMc(double mc) { this.mc = mc; }
    public String getMcSign() { return mcSign; }
    public void setMcSign(String mcSign) { this.mcSign = mcSign; }
    public ParsFortunaInfo getParsFortuna() { return parsFortuna; }
    public void setParsFortuna(ParsFortunaInfo parsFortuna) { this.parsFortuna = parsFortuna; }
    public List<String> getPatterns() { return patterns; }
    public void setPatterns(List<String> patterns) { this.patterns = patterns; }
    public List<AspectInfo> getAspects() { return aspects; }
    public void setAspects(List<AspectInfo> aspects) { this.aspects = aspects; }
    public String getInterpretation() { return interpretation; }
    public void setInterpretation(String interpretation) { this.interpretation = interpretation; }

    public java.util.Map<String, String> getPlanetaryInterpretations() { return planetaryInterpretations; }
    public void setPlanetaryInterpretations(java.util.Map<String, String> m) { this.planetaryInterpretations = m; }
    public java.util.Map<String, String> getPatternInterpretations() { return patternInterpretations; }
    public void setPatternInterpretations(java.util.Map<String, String> m) { this.patternInterpretations = m; }
    public java.util.Map<String, String> getAspectInterpretations() { return aspectInterpretations; }
    public void setAspectInterpretations(java.util.Map<String, String> m) { this.aspectInterpretations = m; }

    public static class AspectInfo {
        private String planet1;
        private String planet2;
        private String aspect;
        private double orb;

        public AspectInfo() {}
        public AspectInfo(String planet1, String planet2, String aspect, double orb) {
            this.planet1 = planet1; this.planet2 = planet2;
            this.aspect = aspect;  this.orb = orb;
        }
        public String getPlanet1() { return planet1; }
        public void setPlanet1(String p) { this.planet1 = p; }
        public String getPlanet2() { return planet2; }
        public void setPlanet2(String p) { this.planet2 = p; }
        public String getAspect() { return aspect; }
        public void setAspect(String a) { this.aspect = a; }
        public double getOrb() { return orb; }
        public void setOrb(double o) { this.orb = o; }
    }

    public static class HouseInfo {
        private int number;
        private String sign;
        private double cusp;

        public HouseInfo() {}
        public HouseInfo(int number, String sign, double cusp) {
            this.number = number;
            this.sign = sign;
            this.cusp = cusp;
        }

        public int getNumber() { return number; }
        public void setNumber(int number) { this.number = number; }
        public String getSign() { return sign; }
        public void setSign(String sign) { this.sign = sign; }
        public double getCusp() { return cusp; }
        public void setCusp(double cusp) { this.cusp = cusp; }
    }

    public static class ParsFortunaInfo {
        private double longitude;
        private String sign;
        private int house;

        public ParsFortunaInfo() {}
        public ParsFortunaInfo(double longitude, String sign, int house) {
            this.longitude = longitude;
            this.sign = sign;
            this.house = house;
        }

        public double getLongitude() { return longitude; }
        public void setLongitude(double longitude) { this.longitude = longitude; }
        public String getSign() { return sign; }
        public void setSign(String sign) { this.sign = sign; }
        public int getHouse() { return house; }
        public void setHouse(int house) { this.house = house; }
    }
}
