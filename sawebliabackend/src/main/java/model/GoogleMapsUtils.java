package model;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class GoogleMapsUtils {

    public static Coordinates extractCoordinatesFromGoogleMapsLink(String link) {
        Pattern pattern = Pattern.compile("([+-]?\\d*\\.\\d+)(?:,|\\s+)([+-]?\\d*\\.\\d+)");  //    "@([\\d.-]+),([\\d.-]+)"
        Matcher matcher = pattern.matcher(link);

        if (matcher.find()) {
            double latitude = Double.parseDouble(matcher.group(1));
            double longitude = Double.parseDouble(matcher.group(2));
            return new Coordinates(latitude, longitude);
        } else {
            return new Coordinates(0, 0);
        }
    }

    public static class Coordinates {
        private double latitude;
        private double longitude;

        public Coordinates(double latitude, double longitude) {
            this.latitude = latitude;
            this.longitude = longitude;
        }

        public double getLatitude() {
            return latitude;
        }

        public double getLongitude() {
            return longitude;
        }
    }
}

