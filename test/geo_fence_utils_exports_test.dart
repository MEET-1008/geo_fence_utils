import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fence_utils/geo_fence_utils.dart';

void main() {
  group('Package Exports', () {
    test('should export GeoPoint', () {
      final point = GeoPoint(
        latitude: 37.7749,
        longitude: -122.4194,
      );
      expect(point, isA<GeoPoint>());
    });

    test('should export GeoCircle', () {
      final circle = GeoCircle(
        center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
        radius: 500,
      );
      expect(circle, isA<GeoCircle>());
    });

    test('should export GeoPolygon', () {
      final polygon = GeoPolygon(
        points: [
          GeoPoint(latitude: 37.7749, longitude: -122.4194),
          GeoPoint(latitude: 37.7849, longitude: -122.4094),
          GeoPoint(latitude: 37.7649, longitude: -122.4094),
        ],
      );
      expect(polygon, isA<GeoPolygon>());
    });

    test('should export GeoDistanceService', () {
      expect(
        GeoDistanceService.calculateDistance,
        isA<Function>(),
      );
    });

    test('should export GeoCircleService', () {
      expect(
        GeoCircleService.isInsideCircle,
        isA<Function>(),
      );
    });

    test('should export GeoPolygonService', () {
      expect(
        GeoPolygonService.isInsidePolygon,
        isA<Function>(),
      );
    });

    test('should export exceptions', () {
      expect(InvalidRadiusException, isA<Type>());
      expect(InvalidPolygonException, isA<Type>());
      expect(InvalidCoordinateException, isA<Type>());
      expect(GeoCalculationException, isA<Type>());
    });

    test('all exports should work together', () {
      // Test that all exports are accessible and work together
      final circle = GeoCircle(
        center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
        radius: 500,
      );

      final point = GeoPoint(latitude: 37.7750, longitude: -122.4195);

      final inside = GeoCircleService.isInsideCircle(
        point: point,
        circle: circle,
      );

      expect(inside, isTrue);
    });
  });
}
