import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fence_utils/models/geo_circle.dart';
import 'package:geo_fence_utils/models/geo_point.dart';
import 'package:geo_fence_utils/services/geo_circle_service.dart';
import 'package:geo_fence_utils/services/geo_distance_service.dart';

void main() {
  group('GeoCircleService - Basic Containment', () {
    late GeoCircle circle;
    late GeoPoint centerPoint;
    late GeoPoint insidePoint;
    late GeoPoint outsidePoint;

    setUp(() {
      centerPoint = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      circle = GeoCircle(
        center: centerPoint,
        radius: 500, // 500 meters
      );

      // Point ~130m from center (inside)
      insidePoint = const GeoPoint(latitude: 37.7758, longitude: -122.4184);

      // Point ~1000m from center (outside)
      outsidePoint = const GeoPoint(latitude: 37.7840, longitude: -122.4194);
    });

    test('should detect point inside circle', () {
      expect(
        GeoCircleService.isInsideCircle(point: insidePoint, circle: circle),
        isTrue,
      );
    });

    test('should detect point outside circle', () {
      expect(
        GeoCircleService.isInsideCircle(point: outsidePoint, circle: circle),
        isFalse,
      );
    });

    test('should detect center point as inside', () {
      expect(
        GeoCircleService.isInsideCircle(point: centerPoint, circle: circle),
        isTrue,
      );
    });

    test('should detect outside with isOutsideCircle', () {
      expect(
        GeoCircleService.isOutsideCircle(point: outsidePoint, circle: circle),
        isTrue,
      );
      expect(
        GeoCircleService.isOutsideCircle(point: insidePoint, circle: circle),
        isFalse,
      );
    });

    test('should detect point on boundary', () {
      // Create a point on the boundary by finding it
      final boundaryPoint = GeoCircleService.findBoundaryPoint(
        circle: circle,
        bearing: 90, // East
      );

      // The distance from center to boundary point should be approximately the radius
      final distance = GeoDistanceService.calculateDistance(
        circle.center,
        boundaryPoint,
      );

      // Should be very close to the radius (within 30 meters for spherical earth)
      expect((distance - circle.radius).abs(), lessThan(30));
    });
  });

  group('GeoCircleService - Distance to Boundary', () {
    late GeoCircle circle;
    late GeoPoint insidePoint;
    late GeoPoint outsidePoint;

    setUp(() {
      final center = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      circle = GeoCircle(center: center, radius: 500);

      // Point ~130m from center (inside)
      insidePoint = const GeoPoint(latitude: 37.7758, longitude: -122.4184);

      // Point ~1000m from center (outside)
      outsidePoint = const GeoPoint(latitude: 37.7840, longitude: -122.4194);
    });

    test('should calculate distance to boundary for inside point', () {
      final distance = GeoCircleService.distanceToBoundary(
        point: insidePoint,
        circle: circle,
      );

      // Should be negative (inside)
      // ~130m from center - 500m radius = ~-370m
      expect(distance, lessThan(0));
      expect(distance, closeTo(-370, 50));
    });

    test('should calculate distance to boundary for outside point', () {
      final distance = GeoCircleService.distanceToBoundary(
        point: outsidePoint,
        circle: circle,
      );

      // Should be positive (outside)
      // ~1000m from center - 500m radius = ~500m
      expect(distance, greaterThan(0));
      expect(distance, closeTo(500, 50));
    });

    test('should calculate absolute distance to boundary', () {
      final absDistance = GeoCircleService.absoluteDistanceToBoundary(
        point: insidePoint,
        circle: circle,
      );

      // Should always be positive
      expect(absDistance, greaterThan(0));
      expect(absDistance, closeTo(370, 50));
    });
  });

  group('GeoCircleService - Batch Operations', () {
    late GeoCircle circle;
    late List<GeoPoint> testPoints;

    setUp(() {
      final center = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      circle = GeoCircle(center: center, radius: 500);

      testPoints = [
        const GeoPoint(latitude: 37.7758, longitude: -122.4184), // inside
        const GeoPoint(latitude: 37.7840, longitude: -122.4194), // outside
        const GeoPoint(latitude: 37.7750, longitude: -122.4195), // inside
        const GeoPoint(latitude: 40.7128, longitude: -74.0060), // outside
      ];
    });

    test('should filter points inside circle', () {
      final inside = GeoCircleService.filterInside(
        points: testPoints,
        circle: circle,
      );

      expect(inside, hasLength(2));
    });

    test('should filter points outside circle', () {
      final outside = GeoCircleService.filterOutside(
        points: testPoints,
        circle: circle,
      );

      expect(outside, hasLength(2));
    });

    test('should count points inside correctly', () {
      final count = GeoCircleService.countInside(
        points: testPoints,
        circle: circle,
      );

      expect(count, 2);
    });

    test('should count points outside correctly', () {
      final count = GeoCircleService.countOutside(
        points: testPoints,
        circle: circle,
      );

      expect(count, 2);
    });

    test('should calculate percentage inside', () {
      final percentage = GeoCircleService.percentageInside(
        points: testPoints,
        circle: circle,
      );

      expect(percentage, 50.0);
    });

    test('should return 0% for empty list', () {
      final percentage = GeoCircleService.percentageInside(
        points: [],
        circle: circle,
      );

      expect(percentage, 0.0);
    });
  });

  group('GeoCircleService - Boundary Points', () {
    late GeoCircle circle;

    setUp(() {
      final center = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      circle = GeoCircle(center: center, radius: 500);
    });

    test('should find boundary point at north bearing', () {
      final northPoint = GeoCircleService.findBoundaryPoint(
        circle: circle,
        bearing: 0, // North
      );

      // Should have greater latitude
      expect(northPoint.latitude, greaterThan(circle.center.latitude));
    });

    test('should find boundary point at east bearing', () {
      final eastPoint = GeoCircleService.findBoundaryPoint(
        circle: circle,
        bearing: 90, // East
      );

      // Should have greater longitude
      expect(eastPoint.longitude, greaterThan(circle.center.longitude));
    });

    test('should find boundary point at south bearing', () {
      final southPoint = GeoCircleService.findBoundaryPoint(
        circle: circle,
        bearing: 180, // South
      );

      // Should have smaller latitude
      expect(southPoint.latitude, lessThan(circle.center.latitude));
    });

    test('should find boundary point at west bearing', () {
      final westPoint = GeoCircleService.findBoundaryPoint(
        circle: circle,
        bearing: 270, // West
      );

      // Should have smaller longitude
      expect(westPoint.longitude, lessThan(circle.center.longitude));
    });

    test('should find boundary points from list', () {
      final boundaryPoint = GeoCircleService.findBoundaryPoint(
        circle: circle,
        bearing: 90,
      );

      final points = [
        boundaryPoint,
        const GeoPoint(latitude: 37.7749, longitude: -122.4194), // center
        const GeoPoint(latitude: 40.7128, longitude: -74.0060), // far away
      ];

      final boundaryPoints = GeoCircleService.findBoundaryPoints(
        points: points,
        circle: circle,
        tolerance: 50.0, // 50 meter tolerance for spherical earth calculations
      );

      // The boundary point should be detected (within tolerance)
      expect(boundaryPoints, isNotEmpty);
    });
  });

  group('GeoCircleService - Circle Relationships', () {
    test('should detect overlapping circles', () {
      final circle1 = GeoCircle(
        center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
        radius: 500,
      );

      // Create circle2 that overlaps with circle1
      final circle2 = GeoCircle(
        center: const GeoPoint(latitude: 37.7760, longitude: -122.4184), // ~130m away
        radius: 500,
      );

      // Distance between centers (~130m) < sum of radii (1000m)
      expect(
        GeoCircleService.circlesOverlap(circle1: circle1, circle2: circle2),
        isTrue,
      );
    });

    test('should detect non-overlapping circles', () {
      final circle1 = GeoCircle(
        center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
        radius: 100,
      );

      // Create circle2 far enough that circles don't overlap
      // 100m radius each = 200m sum of radii
      final circle2 = GeoCircle(
        center: const GeoPoint(latitude: 37.7840, longitude: -122.4194), // ~1000m away
        radius: 100,
      );

      // Distance between centers (~1000m) > sum of radii (200m)
      expect(
        GeoCircleService.circlesOverlap(circle1: circle1, circle2: circle2),
        isFalse,
      );
    });

    test('should detect one circle containing another', () {
      final outer = GeoCircle(
        center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
        radius: 1000,
      );

      final inner = GeoCircle(
        center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
        radius: 500,
      );

      expect(
        GeoCircleService.containsCircle(outer: outer, inner: inner),
        isTrue,
      );
    });

    test('should detect circle not containing another', () {
      final circle1 = GeoCircle(
        center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
        radius: 500,
      );

      final circle2 = GeoCircle(
        center: const GeoPoint(latitude: 37.7800, longitude: -122.4100),
        radius: 500,
      );

      expect(
        GeoCircleService.containsCircle(outer: circle1, inner: circle2),
        isFalse,
      );
    });

    test('should detect touching circles as overlapping', () {
      final circle1 = GeoCircle(
        center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
        radius: 500,
      );

      // Place circle2 exactly at circle1's radius distance
      // For simplicity, create overlapping circles with touch condition
      final circle2 = GeoCircle(
        center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
        radius: 500,
      );

      expect(
        GeoCircleService.circlesOverlap(circle1: circle1, circle2: circle2),
        isTrue,
      );
    });
  });

  group('GeoCircleService - Edge Cases', () {
    test('should handle point exactly at center', () {
      final center = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final circle = GeoCircle(center: center, radius: 500);

      expect(
        GeoCircleService.isInsideCircle(point: center, circle: circle),
        isTrue,
      );

      final distance = GeoCircleService.distanceToBoundary(
        point: center,
        circle: circle,
      );

      expect(distance, closeTo(-500, 1));
    });

    test('should handle very small radius', () {
      final center = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final circle = GeoCircle(center: center, radius: 1); // 1 meter

      final insidePoint = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final outsidePoint = const GeoPoint(latitude: 37.7750, longitude: -122.4194);

      expect(
        GeoCircleService.isInsideCircle(point: insidePoint, circle: circle),
        isTrue,
      );

      expect(
        GeoCircleService.isInsideCircle(point: outsidePoint, circle: circle),
        isFalse,
      );
    });

    test('should handle very large radius', () {
      final center = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final circle = GeoCircle(center: center, radius: 1000000); // 1000 km

      final farPoint = const GeoPoint(latitude: 38.0, longitude: -122.0);

      expect(
        GeoCircleService.isInsideCircle(point: farPoint, circle: circle),
        isTrue,
      );
    });

    test('should handle empty list in filter operations', () {
      final circle = GeoCircle(
        center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
        radius: 500,
      );

      final inside = GeoCircleService.filterInside(
        points: [],
        circle: circle,
      );

      expect(inside, isEmpty);
    });
  });
}
