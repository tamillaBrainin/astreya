package com.example.astrologyanalyzer;

public class Planet {

    String sign;
    double degrees;

    public Planet(String sign, double planetLongitude) {
        this.sign = sign;
        this.degrees = planetLongitude;
    }

    public String getSign() {
        return sign;
    }

    public void setSign(String sign) {
        this.sign = sign;
    }

    public double getDegrees() {
        return degrees;
    }

    public void setDegrees(double degrees) {
        this.degrees = degrees;
    }

    @Override
    public String toString() {
        return "Planet [sign=" + sign + ", degrees=" + degrees + "]";
    }
}
