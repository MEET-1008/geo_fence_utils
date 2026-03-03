import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fence_utils/models/geo_point.dart';

void main() {
  group('GeoPoint', () {
    group('Construction', () {
      test('should create point with valid coordinates', () {
        const point = GeoPoint(
          latitude: 37.7749,
          longitude: -122.4194,
        );

        expect(point.latitude, 37.7749);
        expect(point.longitude, -122.4194);
      });

      test('should accept minimum latitude', () {
        const point = GeoPoint(
          latitude: -90,
          longitude: 0,
        );
        expect(point.latitude, -90);
      });

      test('should accept maximum latitude', () {
        const point = GeoPoint(
          latitude: 90,
          longitude: 0,
        );
        expect(point.latitude, 90);
      });

      test('should accept minimum longitude', () {
        const point = GeoPoint(
          latitude: 0,
          longitude: -180,
        );
        expect(point.longitude, -180);
      });

      test('should accept maximum longitude', () {
        const point = GeoPoint(
          latitude: 0,
          longitude: 180,
        );
        expect(point.longitude, 180);
      });

      test('should throw on latitude > 90', () {
        expect(
          () => GeoPoint(latitude: 91, longitude: 0),
          throwsAssertionError,
        );
      });

      test('should throw on latitude < -90', () {
        expect(
          () => GeoPoint(latitude: -91, longitude: 0),
          throwsAssertionError,
        );
      });

      test('should throw on longitude > 180', () {
        expect(
          () => GeoPoint(latitude: 0, longitude: 181),
          throwsAssertionError,
        );
      });

      test('should throw on longitude < -180', () {
        expect(
          () => GeoPoint(latitude: 0, longitude: -181),
          throwsAssertionError,
        );
      });
    });

    group('Serialization', () {
      test('should convert to map', () {
        const point = GeoPoint(
          latitude: 37.7749,
          longitude: -122.4194,
        );

        final map = point.toMap();

        expect(map, {
          'latitude': 37.7749,
          'longitude': -122.4194,
        });
      });

      test('should create from map', () {
        final map = {
          'latitude': 37.7749,
          'longitude': -122.4194,
        };

        final point = GeoPoint.fromMap(map);

        expect(point.latitude, 37.7749);
        expect(point.longitude, -122.4194);
      });

      test('toMap and fromMap should be symmetric', () {
        const original = GeoPoint(
          latitude: 37.7749,
          longitude: -122.4194,
        );

        final map = original.toMap();
        final restored = GeoPoint.fromMap(map);

        expect(restored, original);
      });
    });

    group('Equality', () {
      test('equal points should be equal', () {
        const point1 = GeoPoint(
          latitude: 37.7749,
          longitude: -122.4194,
        );
        const point2 = GeoPoint(
          latitude: 37.7749,
          longitude: -122.4194,
        );

        expect(point1, point2);
        expect(point1.hashCode, point2.hashCode);
      });

      test('points with different latitude should not be equal', () {
        const point1 = GeoPoint(
          latitude: 37.7749,
          longitude: -122.4194,
        );
        const point2 = GeoPoint(
          latitude: 37.7750,
          longitude: -122.4194,
        );

        expect(point1, isNot(point2));
      });

      test('points with different longitude should not be equal', () {
        const point1 = GeoPoint(
          latitude: 37.7749,
          longitude: -122.4194,
        );
        const point2 = GeoPoint(
          latitude: 37.7749,
          longitude: -122.4195,
        );

        expect(point1, isNot(point2));
      });
    });

    group('String Representation', () {
      test('toString should contain coordinates', () {
        const point = GeoPoint(
          latitude: 37.7749,
          longitude: -122.4194,
        );

        final str = point.toString();

        expect(str, contains('37.7749'));
        expect(str, contains('-122.4194'));
        expect(str, contains('GeoPoint'));
      });
    });
  });
}
