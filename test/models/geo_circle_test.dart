import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fence_utils/models/geo_circle.dart';
import 'package:geo_fence_utils/models/geo_point.dart';

void main() {
  group('GeoCircle', () {
    late GeoPoint center;

    setUp(() {
      center = const GeoPoint(
        latitude: 37.7749,
        longitude: -122.4194,
      );
    });

    group('Construction', () {
      test('should create circle with valid parameters', () {
        final circle = GeoCircle(
          center: center,
          radius: 500,
        );

        expect(circle.center, center);
        expect(circle.radius, 500);
      });

      test('should throw on zero radius', () {
        expect(
          () => GeoCircle(center: center, radius: 0),
          throwsAssertionError,
        );
      });

      test('should throw on negative radius', () {
        expect(
          () => GeoCircle(center: center, radius: -100),
          throwsAssertionError,
        );
      });
    });

    group('Calculated Properties', () {
      test('should calculate area correctly', () {
        final circle = GeoCircle(center: center, radius: 100);

        // Area = π × r² = π × 10000 ≈ 31415.93
        expect(circle.area, closeTo(31415.93, 0.1));
      });

      test('should calculate circumference correctly', () {
        final circle = GeoCircle(center: center, radius: 100);

        // Circumference = 2 × π × r = 2 × π × 100 ≈ 628.32
        expect(circle.circumference, closeTo(628.32, 0.1));
      });
    });

    group('Serialization', () {
      test('should convert to map', () {
        final circle = GeoCircle(center: center, radius: 500);

        final map = circle.toMap();

        expect(map['center'], isA<Map<String, double>>());
        expect(map['radius'], 500);
      });

      test('should create from map', () {
        final map = {
          'center': {'latitude': 37.7749, 'longitude': -122.4194},
          'radius': 500.0,
        };

        final circle = GeoCircle.fromMap(map);

        expect(circle.center.latitude, 37.7749);
        expect(circle.radius, 500);
      });
    });

    group('Equality', () {
      test('equal circles should be equal', () {
        final circle1 = GeoCircle(center: center, radius: 500);
        final circle2 = GeoCircle(center: center, radius: 500);

        expect(circle1, circle2);
      });

      test('circles with different centers should not be equal', () {
        final circle1 = GeoCircle(center: center, radius: 500);
        final circle2 = GeoCircle(
          center: const GeoPoint(latitude: 37.78, longitude: -122.41),
          radius: 500,
        );

        expect(circle1, isNot(circle2));
      });

      test('circles with different radii should not be equal', () {
        final circle1 = GeoCircle(center: center, radius: 500);
        final circle2 = GeoCircle(center: center, radius: 600);

        expect(circle1, isNot(circle2));
      });
    });
  });
}
