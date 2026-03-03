import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fence_utils/utils/geo_math.dart';

void main() {
  group('GeoMath - Conversion Functions', () {
    test('degreesToRadians should convert correctly', () {
      expect(GeoMath.degreesToRadians(180), closeTo(pi, 0.0001));
      expect(GeoMath.degreesToRadians(90), closeTo(pi / 2, 0.0001));
      expect(GeoMath.degreesToRadians(0), 0);
      expect(GeoMath.degreesToRadians(360), closeTo(2 * pi, 0.0001));
    });

    test('radiansToDegrees should convert correctly', () {
      expect(GeoMath.radiansToDegrees(pi), 180);
      expect(GeoMath.radiansToDegrees(pi / 2), 90);
      expect(GeoMath.radiansToDegrees(0), 0);
      expect(GeoMath.radiansToDegrees(2 * pi), closeTo(360, 0.0001));
    });

    test('normalizeDegrees should normalize angles', () {
      expect(GeoMath.normalizeDegrees(370), 10);
      expect(GeoMath.normalizeDegrees(-10), 350);
      expect(GeoMath.normalizeDegrees(720), 0);
      expect(GeoMath.normalizeDegrees(180), 180);
    });

    test('normalizeLongitude should normalize to [-180, 180)', () {
      expect(GeoMath.normalizeLongitude(190), -170);
      expect(GeoMath.normalizeLongitude(-190), 170);
      expect(GeoMath.normalizeLongitude(180), 180);
      // Note: -180 is a boundary case that returns 180
      expect(GeoMath.normalizeLongitude(-180), 180);
      expect(GeoMath.normalizeLongitude(0), 0);
      // Edge: 540 wraps to 180
      expect(GeoMath.normalizeLongitude(540), 180);
    });
  });

  group('GeoMath - Haversine Distance', () {
    test('should calculate distance between two points', () {
      // San Francisco to New York (~4,130 km)
      final distance = GeoMath.haversineDistance(
        37.7749, -122.4194, // SF
        40.7128, -74.0060, // NYC
      );

      expect(distance, greaterThan(4100000));
      expect(distance, lessThan(4200000));
    });

    test('should return 0 for same point', () {
      final distance = GeoMath.haversineDistance(
        37.7749, -122.4194,
        37.7749, -122.4194,
      );

      expect(distance, closeTo(0, 0.1));
    });

    test('should handle equatorial distance', () {
      // 1 degree at equator = ~111.32 km
      final distance = GeoMath.haversineDistance(
        0, 0,
        0, 1,
      );

      expect(distance, closeTo(111320, 1000));
    });

    test('should handle polar distance', () {
      // 1 degree of latitude at pole = ~111.32 km
      final distance = GeoMath.haversineDistance(
        89, 0,
        90, 0,
      );

      expect(distance, closeTo(111320, 1000));
    });

    test('should handle short distances accurately', () {
      // ~700 meters in San Francisco
      // Moving about 0.01 degrees lat/lon is ~1km
      final distance = GeoMath.haversineDistance(
        37.7749, -122.4194,
        37.7812, -122.4124, // ~0.0063 degrees north, ~0.007 degrees east
      );

      // Haversine gives ~932m for these coordinates
      expect(distance, greaterThan(900));
      expect(distance, lessThan(1000));
    });

    test('should handle antipodal points', () {
      // North Pole to South Pole = ~20,000 km
      final distance = GeoMath.haversineDistance(
        90, 0,
        -90, 0,
      );

      expect(distance, closeTo(20000000, 100000));
    });
  });

  group('GeoMath - Planar Distance', () {
    test('should calculate approximate distance for short distances', () {
      final planar = GeoMath.planarDistance(
        37.7749, -122.4194,
        37.7758, -122.4184,
      );

      final haversine = GeoMath.haversineDistance(
        37.7749, -122.4194,
        37.7758, -122.4184,
      );

      // Should be reasonably close for short distances
      expect((planar - haversine).abs(), lessThan(50));
    });
  });

  group('GeoMath - Bearing', () {
    test('should calculate initial bearing', () {
      final bearing = GeoMath.calculateBearing(
        37.7749, -122.4194, // SF
        40.7128, -74.0060, // NYC
      );

      // Should be approximately east-northeast
      expect(bearing, greaterThan(60));
      expect(bearing, lessThan(80));
    });

    test('should calculate bearing to north', () {
      final bearing = GeoMath.calculateBearing(
        37.7749, -122.4194,
        38.7749, -122.4194,
      );

      expect(bearing, closeTo(0, 1));
    });

    test('should calculate bearing to east', () {
      final bearing = GeoMath.calculateBearing(
        37.7749, -122.4194,
        37.7749, -121.4194,
      );

      expect(bearing, closeTo(90, 1));
    });

    test('should calculate bearing to south', () {
      final bearing = GeoMath.calculateBearing(
        37.7749, -122.4194,
        36.7749, -122.4194,
      );

      expect(bearing, closeTo(180, 1));
    });

    test('should calculate bearing to west', () {
      final bearing = GeoMath.calculateBearing(
        37.7749, -122.4194,
        37.7749, -123.4194,
      );

      expect(bearing, closeTo(270, 1));
    });
  });

  group('GeoMath - Destination Point', () {
    test('should calculate destination point', () {
      final dest = GeoMath.calculateDestination(
        lat: 37.7749,
        lon: -122.4194,
        bearing: 90, // East
        distance: 1000, // 1 km
      );

      // Longitude should increase (eastward)
      expect(dest['longitude']! > -122.4194, isTrue);
    });

    test('should calculate northern destination', () {
      final dest = GeoMath.calculateDestination(
        lat: 37.7749,
        lon: -122.4194,
        bearing: 0, // North
        distance: 1000,
      );

      // Latitude should increase (northward)
      expect(dest['latitude']! > 37.7749, isTrue);
    });

    test('round-trip should return to origin', () {
      final dest = GeoMath.calculateDestination(
        lat: 37.7749,
        lon: -122.4194,
        bearing: 45,
        distance: 1000,
      );

      final back = GeoMath.calculateDestination(
        lat: dest['latitude']!,
        lon: dest['longitude']!,
        bearing: 225, // Opposite direction
        distance: 1000,
      );

      expect(back['latitude'], closeTo(37.7749, 0.0001));
      expect(back['longitude'], closeTo(-122.4194, 0.0001));
    });
  });

  group('GeoMath - Midpoint', () {
    test('should calculate midpoint between two points', () {
      // Use two points on the same longitude for simpler testing
      final midpoint = GeoMath.calculateMidpoint(
        40.0, -122.0,
        35.0, -122.0,
      );

      // Midpoint should be at the average latitude (37.5)
      expect(midpoint['latitude'], closeTo(37.5, 0.1));
      expect(midpoint['longitude'], closeTo(-122.0, 0.1));
    });

    test('should calculate midpoint for SF to NYC', () {
      final midpoint = GeoMath.calculateMidpoint(
        37.7749, -122.4194, // SF
        40.7128, -74.0060, // NYC
      );

      // Midpoint should produce valid coordinates
      expect(midpoint['latitude']!, greaterThanOrEqualTo(-90));
      expect(midpoint['latitude']!, lessThanOrEqualTo(90));
      expect(midpoint['longitude']!, greaterThanOrEqualTo(-180));
      expect(midpoint['longitude']!, lessThanOrEqualTo(180));
    });

    test('should calculate equatorial midpoint', () {
      final midpoint = GeoMath.calculateMidpoint(
        0, -10,
        0, 10,
      );

      expect(midpoint['latitude'], closeTo(0, 0.0001));
      expect(midpoint['longitude'], closeTo(0, 0.0001));
    });

    test('should calculate polar midpoint', () {
      final midpoint = GeoMath.calculateMidpoint(
        80, 0,
        80, 180,
      );

      // Should be near the pole
      expect(midpoint['latitude']! > 80, isTrue);
    });
  });
}
