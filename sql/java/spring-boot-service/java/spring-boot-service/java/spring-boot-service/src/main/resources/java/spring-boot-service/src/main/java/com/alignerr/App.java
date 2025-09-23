package com.alignerr;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@SpringBootApplication
@RestController
public class App {

  record ScoreRequest(String id, List<Double> features) {}
  record ScoreResponse(String id, double score, String riskBand) {}

  @GetMapping("/health")
  public String health() { return "ok"; }

  private static String band(double s) {
    if (s >= 1.5) return "LOW";
    if (s >= 0.5) return "MEDIUM";
    return "HIGH";
  }

  @PostMapping("/score")
  public ScoreResponse score(@RequestBody ScoreRequest req) {
    var f = req.features();
    if (f == null || f.size() < 3) throw new IllegalArgumentException("Need at least 3 features");
    double mean = 0.0; for (double v : f) mean += v; mean /= f.size();
    double var = 0.0; for (double v : f) { double d = v - mean; var += d*d; } var /= f.size();
    double stdev = Math.max(Math.sqrt(var), 1e-9);
    double s = Math.round((mean / stdev) * 10000.0) / 10000.0;
    return new ScoreResponse(req.id(), s, band(s));
  }

  public static void main(String[] args) {
    SpringApplication.run(App.class, args);
  }
}
