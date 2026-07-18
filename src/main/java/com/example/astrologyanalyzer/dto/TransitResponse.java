package com.example.astrologyanalyzer.dto;

import java.util.List;

public class TransitResponse {
    private String date;
    private List<TransitItem> transits;
    private String interpretation;

    public TransitResponse() {}

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
    public List<TransitItem> getTransits() { return transits; }
    public void setTransits(List<TransitItem> transits) { this.transits = transits; }
    public String getInterpretation() { return interpretation; }
    public void setInterpretation(String interpretation) { this.interpretation = interpretation; }

    public static class TransitItem {
        private String transitPlanet;
        private String transitSign;
        private int transitHouse;
        private String natalPlanet;
        private String aspect;
        private double orb;

        public TransitItem() {}

        public TransitItem(String transitPlanet, String transitSign, int transitHouse,
                           String natalPlanet, String aspect, double orb) {
            this.transitPlanet = transitPlanet;
            this.transitSign = transitSign;
            this.transitHouse = transitHouse;
            this.natalPlanet = natalPlanet;
            this.aspect = aspect;
            this.orb = orb;
        }

        public String getTransitPlanet() { return transitPlanet; }
        public void setTransitPlanet(String transitPlanet) { this.transitPlanet = transitPlanet; }
        public String getTransitSign() { return transitSign; }
        public void setTransitSign(String transitSign) { this.transitSign = transitSign; }
        public int getTransitHouse() { return transitHouse; }
        public void setTransitHouse(int transitHouse) { this.transitHouse = transitHouse; }
        public String getNatalPlanet() { return natalPlanet; }
        public void setNatalPlanet(String natalPlanet) { this.natalPlanet = natalPlanet; }
        public String getAspect() { return aspect; }
        public void setAspect(String aspect) { this.aspect = aspect; }
        public double getOrb() { return orb; }
        public void setOrb(double orb) { this.orb = orb; }
    }
}
