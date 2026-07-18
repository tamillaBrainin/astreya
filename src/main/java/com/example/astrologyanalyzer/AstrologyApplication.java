package com.example.astrologyanalyzer;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class AstrologyApplication {

    public static void main(String[] args) {
        SpringApplication.run(AstrologyApplication.class, args);
    }

    @GetMapping("/")
    public String home() {
        return "Astrology Analyzer is running!";
    }
}