/// Integration tests for geo_fence_utils package
///
/// These tests verify the complete functionality of the package
/// by combining multiple features together.
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fence_utils/geo_fence_utils.dart';

void main() {
  group('Geo Fence Utils - Integration Tests', () {
    test('should calculate distance and check circle containment', () {
      final sf = GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final nearby = GeoPoint(latitude: 37.7750, longitude: -122.4195);

      final distance = GeoDistanceService.calculateDistance(sf, nearby);

      expect(distance, greaterThan(0));
      expect(distance, lessThan(200));

      final circle = GeoCircle(center: sf, radius: 500);

      expect(GeoCircleService.isInsideCircle(point: nearby, circle: circle), isTrue);
    });

    test('should work with polygon and distance filtering', () {
      final polygon = GeoPolygon.rectangle(
        north: 37.78,
        south: 37.76,
        east: -122.40,
        west: -122.42,
      );

      final points = [
        GeoPoint(latitude: 37.775, longitude: -122.41),
        GeoPoint(latitude: 37.79, longitude: -122.41),
        GeoPoint(latitude: 37.75, longitude: -122.41),
      ];

      final inside = GeoPolygonService.filterInside(points: points, polygon: polygon);

      expect(inside, hasLength(1));
      expect(inside[0].latitude, 37.775);

      final nearby = GeoDistanceService.findNearbyWithDistance(
        points[0],
        points,
        radius: 5000,
      );

      expect(nearby.length, greaterThan(0));
    });

    test('should handle circle-polygon operations together', () {
      final circle = GeoCircle(
        center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
        radius: 500,
      );

      final polygon = GeoPolygon.rectangle(
        north: 37.78,
        south: 37.76,
        east: -122.40,
        west: -122.42,
      );

      final center = circle.center;

      final inPolygon = GeoPolygonService.isInsidePolygon(
        point: center,
        polygon: polygon,
      );

      final inCircle = GeoCircleService.isInsideCircle(
        point: center,
        circle: circle,
      );

      expect(inCircle, isTrue);
      expect(inPolygon, isTrue);
    });

    test('should work with multiple service calls in sequence', () {
      final origin = GeoPoint(latitude: 37.7749, longitude: -122.4194);

      final destinations = [
        GeoPoint(latitude: 37.7849, longitude: -122.4094),
        GeoPoint(latitude: 37.7649, longitude: -122.4294),
        GeoPoint(latitude: 40.7128, longitude: -74.0060), // NYC
      ];

      final sorted = GeoDistanceService.sortByDistance(
        origin,
        destinations,
      );

      expect(sorted.length, equals(3));
      expect(sorted[0].latitude, isNot(equals(40.7128))); // NYC should be last
      expect(sorted[2].latitude, equals(40.7128));

      final closest = sorted.first;
      final closestDistance = GeoDistanceService.calculateDistance(origin, closest);

      expect(closestDistance, lessThan(3000));
    });

    test('should handle batch operations efficiently', () {
      final circle = GeoCircle(
        center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
        radius: 1000,
      );

      final manyPoints = List.generate(
        100,
        (i) => GeoPoint(
          latitude: 37.7749 + (i * 0.001),
          longitude: -122.4194 + (i * 0.001),
        ),
      );

      final inside = GeoCircleService.filterInside(
        points: manyPoints,
        circle: circle,
      );

      expect(inside.length, greaterThan(0));
      expect(inside.length, lessThan(100));

      final count = GeoCircleService.countInside(
        points: manyPoints,
        circle: circle,
      );

      expect(count, equals(inside.length));
    });

    test('should handle boundary detection accurately', () {
      final polygon = GeoPolygon.rectangle(
        north: 37.78,
        south: 37.76,
        east: -122.40,
        west: -122.42,
      );

      final boundaryPoint = GeoPoint(latitude: 37.78, longitude: -122.41);

      expect(
        GeoPolygonService.isOnBoundary(
          point: boundaryPoint,
          polygon: polygon,
          tolerance: 0.0001,
        ),
        isTrue,
      );

      expect(
        GeoPolygonService.isInsidePolygon(
          point: boundaryPoint,
          polygon: polygon,
        ),
        isTrue,
      );
    });

    test('should validate polygon properties', () {
      final convex = GeoPolygon.rectangle(
        north: 37.78,
        south: 37.76,
        east: -122.40,
        west: -122.42,
      );

      expect(GeoPolygonService.isConvex(convex), isTrue);
      expect(GeoPolygonService.isValidPolygon(convex), isTrue);

      final bbox = GeoPolygonService.getBoundingBox(convex);

      expect(bbox['north'], 37.78);
      expect(bbox['south'], 37.76);
      expect(bbox['east'], -122.40);
      expect(bbox['west'], -122.42);

      final area = GeoPolygonService.calculateArea(convex);
      expect(area, greaterThan(0));

      final perimeter = GeoPolygonService.calculatePerimeter(convex);
      expect(perimeter, greaterThan(0));
    });

    test('should handle circle metrics and relationships', () {
      final circle1 = GeoCircle(
        center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
        radius: 500,
      );

      final circle2 = GeoCircle(
        center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
        radius: 300,
      );

      expect(circle1.area, greaterThan(circle2.area));
      expect(circle1.circumference, greaterThan(circle2.circumference));

      expect(GeoCircleService.containsCircle(inner: circle2, outer: circle1), isTrue);
      expect(GeoCircleService.containsCircle(inner: circle1, outer: circle2), isFalse);

      final overlapping = GeoCircle(
        center: GeoPoint(latitude: 37.7760, longitude: -122.4180),
        radius: 500,
      );

      expect(GeoCircleService.circlesOverlap(circle1: circle1, circle2: overlapping), isTrue);
    });

    test('should calculate distances between all points correctly', () {
      final points = [
        GeoPoint(latitude: 37.7749, longitude: -122.4194),
        GeoPoint(latitude: 37.7849, longitude: -122.4094),
        GeoPoint(latitude: 37.7649, longitude: -122.4094),
      ];

      final distances = GeoDistanceService.calculateDistances(points[0], points.sublist(1));

      expect(distances, hasLength(2));
      expect(distances[0], greaterThan(0));
      expect(distances[1], greaterThan(0));
    });

    test('should handle edge case - point at pole', () {
      final northPole = GeoPoint(latitude: 90.0, longitude: 0.0);
      final equator = GeoPoint(latitude: 0.0, longitude: 0.0);

      final distance = GeoDistanceService.calculateDistance(northPole, equator);

      expect(distance, greaterThan(10000000)); // > 10,000 km
      expect(distance, lessThan(11000000)); // < 11,000 km
    });

    test('should handle edge case - antipodal points', () {
      final point1 = GeoPoint(latitude: 0.0, longitude: 0.0);
      final point2 = GeoPoint(latitude: 0.0, longitude: 180.0);

      final distance = GeoDistanceService.calculateDistance(point1, point2);

      expect(distance, greaterThan(19900000)); // ~ half Earth circumference
      expect(distance, lessThan(20100000));
    });
  });

  group('Geo Fence Utils - Real World Scenarios', () {
    test('should detect delivery zone - San Francisco scenario', () {
      // San Francisco downtown delivery zone
      final deliveryZone = GeoPolygon.rectangle(
        north: 37.79,
        south: 37.77,
        east: -122.40,
        west: -122.42,
      );

      // Delivery locations
      final locations = [
        GeoPoint(latitude: 37.7849, longitude: -122.4094), // Inside
        GeoPoint(latitude: 37.7749, longitude: -122.4194), // Inside
        GeoPoint(latitude: 37.80, longitude: -122.45), // Outside - too far north
        GeoPoint(latitude: 37.76, longitude: -122.38), // Outside - too far east
      ];

      final deliverable = GeoPolygonService.filterInside(
        points: locations,
        polygon: deliveryZone,
      );

      expect(deliverable, hasLength(2));

      final count = GeoPolygonService.countInside(
        points: locations,
        polygon: deliveryZone,
      );
      final percentage = (count / locations.length) * 100;

      expect(percentage, closeTo(50.0, 0.1));
    });

    test('should detect store proximity - retail scenario', () {
      final store = GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final fiveMileRadius = GeoCircle(center: store, radius: 8047); // 5 miles in meters

      final customers = [
        GeoPoint(latitude: 37.7750, longitude: -122.4195), // Very close
        GeoPoint(latitude: 37.78, longitude: -122.41), // Close
        GeoPoint(latitude: 37.80, longitude: -122.40), // Far
      ];

      final nearby = GeoCircleService.filterInside(
        points: customers,
        circle: fiveMileRadius,
      );

      expect(nearby.length, greaterThan(0));

      final closest = GeoDistanceService.findClosest(
        store,
        customers,
      );

      expect(closest, isNotNull);
      final distance = GeoDistanceService.calculateDistance(store, closest!);
      expect(distance, lessThan(1000));
    });

    test('should handle geofencing - security scenario', () {
      final secureArea = GeoPolygon(points: [
        GeoPoint(latitude: 37.7749, longitude: -122.4194),
        GeoPoint(latitude: 37.7800, longitude: -122.4150),
        GeoPoint(latitude: 37.7820, longitude: -122.4080),
        GeoPoint(latitude: 37.7770, longitude: -122.4050),
        GeoPoint(latitude: 37.7720, longitude: -122.4100),
      ]);

      final checkpoints = [
        GeoPoint(latitude: 37.7760, longitude: -122.4120), // Inside
        GeoPoint(latitude: 37.7700, longitude: -122.4200), // Outside
      ];

      for (final checkpoint in checkpoints) {
        final inside = GeoPolygonService.isInsidePolygon(
          point: checkpoint,
          polygon: secureArea,
        );

        final onBoundary = GeoPolygonService.isOnBoundary(
          point: checkpoint,
          polygon: secureArea,
        );

        // Either inside or on boundary is valid access
        final hasAccess = inside || onBoundary;

        if (checkpoint.latitude == 37.7760) {
          expect(hasAccess, isTrue);
        } else {
          expect(hasAccess, isFalse);
        }
      }
    });
  });

  group('Geo Fence Utils - Performance Tests', () {
    test('should handle large polygon efficiently', () {
      final vertices = List.generate(
        50,
        (i) => GeoPoint(
          latitude: 37.77 + (i * 0.0001),
          longitude: -122.42 + (i * 0.0001),
        ),
      );

      final largePolygon = GeoPolygon(points: vertices);

      final testPoint = GeoPoint(latitude: 37.775, longitude: -122.415);

      final result = GeoPolygonService.isInsidePolygon(
        point: testPoint,
        polygon: largePolygon,
      );

      expect(result, isA<bool>());
    });

    test('should handle many points quickly', () {
      final polygon = GeoPolygon.rectangle(
        north: 37.78,
        south: 37.76,
        east: -122.40,
        west: -122.42,
      );

      final manyPoints = List.generate(
        500,
        (i) => GeoPoint(
          latitude: 37.76 + (i * 0.0001),
          longitude: -122.42 + (i * 0.0001),
        ),
      );

      final count = GeoPolygonService.countInside(
        points: manyPoints,
        polygon: polygon,
      );

      expect(count, isA<int>());
      expect(count, greaterThan(0));
    });
  });
}
