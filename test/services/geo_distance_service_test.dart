import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fence_utils/models/geo_point.dart';
import 'package:geo_fence_utils/services/geo_distance_service.dart';

void main() {
  group('GeoDistanceService - Basic Distance', () {
    test('should calculate distance between two points', () {
      final sf = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final nyc = const GeoPoint(latitude: 40.7128, longitude: -74.0060);

      final distance = GeoDistanceService.calculateDistance(sf, nyc);

      expect(distance, greaterThan(4100000));
      expect(distance, lessThan(4200000));
    });

    test('should return 0 for identical points', () {
      final point = const GeoPoint(latitude: 37.7749, longitude: -122.4194);

      final distance = GeoDistanceService.calculateDistance(point, point);

      expect(distance, closeTo(0, 0.1));
    });

    test('should calculate distances to multiple points', () {
      final origin = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final destinations = [
        const GeoPoint(latitude: 37.78, longitude: -122.41), // ~1000m
        const GeoPoint(latitude: 40.71, longitude: -74.00),
      ];

      final distances = GeoDistanceService.calculateDistances(
        origin,
        destinations,
      );

      expect(distances, hasLength(2));
      expect(distances[0], lessThan(1500)); // nearby
      expect(distances[1], greaterThan(4000000)); // far
    });

    test('should return empty list for empty destinations', () {
      final origin = const GeoPoint(latitude: 37.7749, longitude: -122.4194);

      final distances = GeoDistanceService.calculateDistances(
        origin,
        [],
      );

      expect(distances, isEmpty);
    });
  });

  group('GeoDistanceService - Find Closest/Farthest', () {
    test('should find closest point', () {
      final origin = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final candidates = [
        const GeoPoint(latitude: 37.78, longitude: -122.41), // ~1000m
        const GeoPoint(latitude: 34.05, longitude: -118.24), // ~550km
        const GeoPoint(latitude: 40.71, longitude: -74.00), // ~4100km
      ];

      final closest = GeoDistanceService.findClosest(origin, candidates);

      expect(closest, isNotNull);
      expect(closest?.latitude, 37.78);
      expect(closest?.longitude, -122.41);
    });

    test('should return null for empty candidates', () {
      final origin = const GeoPoint(latitude: 37.7749, longitude: -122.4194);

      final closest = GeoDistanceService.findClosest(origin, []);

      expect(closest, isNull);
    });

    test('should find farthest point', () {
      final origin = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final candidates = [
        const GeoPoint(latitude: 37.78, longitude: -122.41), // ~700m
        const GeoPoint(latitude: 34.05, longitude: -118.24), // ~550km
        const GeoPoint(latitude: 40.71, longitude: -74.00), // ~4100km
      ];

      final farthest = GeoDistanceService.findFarthest(origin, candidates);

      expect(farthest, isNotNull);
      expect(farthest?.latitude, 40.71);
      expect(farthest?.longitude, -74.00);
    });
  });

  group('GeoDistanceService - Sort by Distance', () {
    test('should sort points by distance ascending', () {
      final origin = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final points = [
        const GeoPoint(latitude: 40.71, longitude: -74.00), // far
        const GeoPoint(latitude: 37.7758, longitude: -122.4184), // near
        const GeoPoint(latitude: 34.05, longitude: -118.24), // medium
      ];

      final sorted = GeoDistanceService.sortByDistance(origin, points);

      expect(sorted[0].latitude, 37.7758); // nearest
      expect(sorted[1].latitude, 34.05);
      expect(sorted[2].latitude, 40.71); // farthest
    });

    test('should sort points by distance descending', () {
      final origin = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final points = [
        const GeoPoint(latitude: 40.71, longitude: -74.00), // far
        const GeoPoint(latitude: 37.7758, longitude: -122.4184), // near
        const GeoPoint(latitude: 34.05, longitude: -118.24), // medium
      ];

      final sorted = GeoDistanceService.sortByDistance(
        origin,
        points,
        ascending: false,
      );

      expect(sorted[0].latitude, 40.71); // farthest
      expect(sorted[1].latitude, 34.05);
      expect(sorted[2].latitude, 37.7758); // nearest
    });
  });

  group('GeoDistanceService - Filter by Radius', () {
    test('should filter points within radius', () {
      final origin = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final points = [
        const GeoPoint(latitude: 37.78, longitude: -122.41), // ~1000m
        const GeoPoint(latitude: 40.71, longitude: -74.00), // far
      ];

      final nearby = GeoDistanceService.filterByRadius(
        origin,
        points,
        radius: 1500,
      );

      expect(nearby, hasLength(1));
      expect(nearby[0].latitude, 37.78);
    });

    test('should return empty list when no points within radius', () {
      final origin = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final points = [
        const GeoPoint(latitude: 40.71, longitude: -74.00),
      ];

      final nearby = GeoDistanceService.filterByRadius(
        origin,
        points,
        radius: 100,
      );

      expect(nearby, isEmpty);
    });

    test('should find nearby points with distances', () {
      final origin = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final points = [
        const GeoPoint(latitude: 37.78, longitude: -122.41), // ~1000m
        const GeoPoint(latitude: 37.7758, longitude: -122.4184), // ~130m
        const GeoPoint(latitude: 40.71, longitude: -74.00), // far
      ];

      final results = GeoDistanceService.findNearbyWithDistance(
        origin,
        points,
        radius: 1500,
      );

      expect(results, hasLength(2));
      // Results should be sorted by distance
      expect(
        (results[0]['distance'] as double) < (results[1]['distance'] as double),
        isTrue,
      );
      expect(results[0]['point'], isA<GeoPoint>());
      expect(results[0]['distance'], isA<double>());
    });
  });

  group('GeoDistanceService - Validation', () {
    test('should check if points are within distance', () {
      final p1 = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final p2 = const GeoPoint(latitude: 37.7758, longitude: -122.4184);

      final isNearby = GeoDistanceService.isWithinDistance(
        p1,
        p2,
        maxDistance: 200,
      );

      expect(isNearby, isTrue);
    });

    test('should return false when points exceed max distance', () {
      final p1 = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final p2 = const GeoPoint(latitude: 37.78, longitude: -122.41);

      final isNearby = GeoDistanceService.isWithinDistance(
        p1,
        p2,
        maxDistance: 100,
      );

      expect(isNearby, isFalse);
    });

    test('should check if point is near any reference point', () {
      final point = const GeoPoint(latitude: 37.775, longitude: -122.419);
      final referencePoints = [
        const GeoPoint(latitude: 37.7758, longitude: -122.4184), // near
        const GeoPoint(latitude: 40.71, longitude: -74.00), // far
      ];

      final isNear = GeoDistanceService.isNearAny(
        point,
        referencePoints,
        maxDistance: 200,
      );

      expect(isNear, isTrue);
    });

    test('should return false when point is far from all references', () {
      final point = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final referencePoints = [
        const GeoPoint(latitude: 40.71, longitude: -74.00),
      ];

      final isNear = GeoDistanceService.isNearAny(
        point,
        referencePoints,
        maxDistance: 1000,
      );

      expect(isNear, isFalse);
    });
  });

  group('GeoDistanceService - Planar Distance', () {
    test('should calculate planar distance for short distances', () {
      final p1 = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final p2 = const GeoPoint(latitude: 37.78, longitude: -122.41);

      final planar = GeoDistanceService.calculatePlanarDistance(p1, p2);
      final haversine = GeoDistanceService.calculateDistance(p1, p2);

      // Should be reasonably close for short distances
      expect((planar - haversine).abs(), lessThan(50));
    });
  });
}
