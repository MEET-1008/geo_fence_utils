import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fence_utils/models/geo_point.dart';
import 'package:geo_fence_utils/models/geo_polygon.dart';

void main() {
  group('GeoPolygon', () {
    group('Construction', () {
      test('should create polygon with 3+ points', () {
        final polygon = GeoPolygon(
          points: [
            const GeoPoint(latitude: 37.77, longitude: -122.42),
            const GeoPoint(latitude: 37.78, longitude: -122.41),
            const GeoPoint(latitude: 37.76, longitude: -122.41),
          ],
        );

        expect(polygon.points, hasLength(3));
      });

      test('should throw with less than 3 points', () {
        expect(
          () => GeoPolygon(
            points: [
              const GeoPoint(latitude: 37.77, longitude: -122.42),
              const GeoPoint(latitude: 37.78, longitude: -122.41),
            ],
          ),
          throwsAssertionError,
        );
      });

      test('should accept exactly 3 points', () {
        expect(
          () => GeoPolygon(
            points: [
              const GeoPoint(latitude: 37.77, longitude: -122.42),
              const GeoPoint(latitude: 37.78, longitude: -122.41),
              const GeoPoint(latitude: 37.76, longitude: -122.41),
            ],
          ),
          returnsNormally,
        );
      });
    });

    group('Factory Constructors', () {
      test('should create polygon from maps', () {
        final maps = [
          {'latitude': 37.77, 'longitude': -122.42},
          {'latitude': 37.78, 'longitude': -122.41},
          {'latitude': 37.76, 'longitude': -122.41},
        ];

        final polygon = GeoPolygon.fromMaps(maps);

        expect(polygon.points, hasLength(3));
      });

      test('should create rectangle polygon', () {
        final rect = GeoPolygon.rectangle(
          north: 37.78,
          south: 37.76,
          east: -122.40,
          west: -122.42,
        );

        expect(rect.points, hasLength(4));

        // Check corners
        expect(rect.points[0].latitude, 37.78); // NW
        expect(rect.points[0].longitude, -122.42);
        expect(rect.points[1].latitude, 37.78); // NE
        expect(rect.points[1].longitude, -122.40);
        expect(rect.points[2].latitude, 37.76); // SE
        expect(rect.points[2].longitude, -122.40);
        expect(rect.points[3].latitude, 37.76); // SW
        expect(rect.points[3].longitude, -122.42);
      });
    });

    group('Properties', () {
      test('should return vertex count', () {
        final triangle = GeoPolygon(
          points: List.generate(
            3,
            (i) => GeoPoint(latitude: 37.77 + i * 0.01, longitude: -122.42),
          ),
        );

        expect(triangle.vertexCount, 3);
      });

      test('should detect convex polygon', () {
        final convex = GeoPolygon.rectangle(
          north: 37.78,
          south: 37.76,
          east: -122.40,
          west: -122.42,
        );

        expect(convex.isConvex, isTrue);
      });

      test('should calculate centroid', () {
        final polygon = GeoPolygon(
          points: [
            const GeoPoint(latitude: 37.77, longitude: -122.42),
            const GeoPoint(latitude: 37.78, longitude: -122.41),
            const GeoPoint(latitude: 37.76, longitude: -122.41),
          ],
        );

        final centroid = polygon.centroid;

        // Centroid should be within bounds
        expect(centroid.latitude, greaterThan(37.76));
        expect(centroid.latitude, lessThan(37.78));
      });
    });

    group('Serialization', () {
      test('should convert to maps', () {
        final polygon = GeoPolygon(
          points: [
            const GeoPoint(latitude: 37.77, longitude: -122.42),
            const GeoPoint(latitude: 37.78, longitude: -122.41),
            const GeoPoint(latitude: 37.76, longitude: -122.41),
          ],
        );

        final maps = polygon.toMaps();

        expect(maps, hasLength(3));
        expect(maps[0]['latitude'], 37.77);
      });
    });
  });
}
