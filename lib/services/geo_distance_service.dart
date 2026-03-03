import '../models/geo_point.dart';
import '../utils/geo_math.dart';

/// Service for calculating distances between geographical points.
///
/// This service provides a high-level API for distance calculations,
/// abstracting away the mathematical complexity of the underlying algorithms.
///
/// **Example:**
/// ```dart
/// final sf = GeoPoint(latitude: 37.7749, longitude: -122.4194);
/// final nyc = GeoPoint(latitude: 40.7128, longitude: -74.0060);
///
/// final distance = GeoDistanceService.calculateDistance(sf, nyc);
/// print('Distance: ${distance}m');
/// ```
class GeoDistanceService {
  // ========================================================================
  // DISTANCE CALCULATIONS
  // ========================================================================

  /// Calculates the great-circle distance between two points.
  ///
  /// Uses the Haversine formula for accuracy (~0.5%).
  ///
  /// **Parameters:**
  /// - [point1]: First geographical point
  /// - [point2]: Second geographical point
  ///
  /// **Returns:** Distance in meters
  ///
  /// **Example:**
  /// ```dart
  /// final p1 = GeoPoint(latitude: 37.7749, longitude: -122.4194);
  /// final p2 = GeoPoint(latitude: 40.7128, longitude: -74.0060);
  ///
  /// final distance = GeoDistanceService.calculateDistance(p1, p2);
  /// print('Distance: ${distance / 1000} km');
  /// ```
  ///
  /// **Time Complexity:** O(1)
  /// **Space Complexity:** O(1)
  static double calculateDistance(
    GeoPoint point1,
    GeoPoint point2,
  ) {
    return GeoMath.haversineDistance(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Calculates distances from one point to multiple points.
  ///
  /// **Parameters:**
  /// - [origin]: The origin point
  /// - [destinations]: List of destination points
  ///
  /// **Returns:** List of distances in meters (same order as destinations)
  ///
  /// **Example:**
  /// ```dart
  /// final origin = GeoPoint(latitude: 37.7749, longitude: -122.4194);
  /// final destinations = [
  ///   GeoPoint(latitude: 40.7128, longitude: -74.0060),
  ///   GeoPoint(latitude: 34.0522, longitude: -118.2437),
  /// ];
  ///
  /// final distances = GeoDistanceService.calculateDistances(
  ///   origin,
  ///   destinations,
  /// );
  /// print(distances); // [4130000, 550000]
  /// ```
  static List<double> calculateDistances(
    GeoPoint origin,
    List<GeoPoint> destinations,
  ) {
    return destinations
        .map((dest) => calculateDistance(origin, dest))
        .toList();
  }

  /// Calculates the distance using a simplified planar approximation.
  ///
  /// **Note:** Only accurate for short distances (< 10km).
  /// Use [calculateDistance] for accurate results at any distance.
  ///
  /// **Parameters:**
  /// - [point1]: First geographical point
  /// - [point2]: Second geographical point
  ///
  /// **Returns:** Approximate distance in meters
  static double calculatePlanarDistance(
    GeoPoint point1,
    GeoPoint point2,
  ) {
    return GeoMath.planarDistance(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  // ========================================================================
  // DISTANCE COMPARISON
  // ========================================================================

  /// Finds the closest point from a list of candidates.
  ///
  /// **Parameters:**
  /// - [origin]: The reference point
  /// - [candidates]: List of candidate points
  ///
  /// **Returns:** The closest point, or `null` if candidates is empty
  ///
  /// **Example:**
  /// ```dart
  /// final origin = GeoPoint(latitude: 37.7749, longitude: -122.4194);
  /// final candidates = [
  ///   GeoPoint(latitude: 37.78, longitude: -122.41),
  ///   GeoPoint(latitude: 40.71, longitude: -74.00),
  /// ];
  ///
  /// final closest = GeoDistanceService.findClosest(origin, candidates);
  /// print('Closest: $closest');
  /// ```
  static GeoPoint? findClosest(
    GeoPoint origin,
    List<GeoPoint> candidates,
  ) {
    if (candidates.isEmpty) return null;

    GeoPoint? closest;
    double minDistance = double.infinity;

    for (final candidate in candidates) {
      final distance = calculateDistance(origin, candidate);
      if (distance < minDistance) {
        minDistance = distance;
        closest = candidate;
      }
    }

    return closest;
  }

  /// Finds the farthest point from a list of candidates.
  ///
  /// **Parameters:**
  /// - [origin]: The reference point
  /// - [candidates]: List of candidate points
  ///
  /// **Returns:** The farthest point, or `null` if candidates is empty
  static GeoPoint? findFarthest(
    GeoPoint origin,
    List<GeoPoint> candidates,
  ) {
    if (candidates.isEmpty) return null;

    GeoPoint? farthest;
    double maxDistance = 0;

    for (final candidate in candidates) {
      final distance = calculateDistance(origin, candidate);
      if (distance > maxDistance) {
        maxDistance = distance;
        farthest = candidate;
      }
    }

    return farthest;
  }

  /// Sorts a list of points by distance from the origin.
  ///
  /// **Parameters:**
  /// - [origin]: The reference point
  /// - [points]: List of points to sort
  /// - [ascending]: If true, sort ascending (closest first). Default: true
  ///
  /// **Returns:** A new list of points sorted by distance
  ///
  /// **Example:**
  /// ```dart
  /// final origin = GeoPoint(latitude: 37.7749, longitude: -122.4194);
  /// final points = [
  ///   GeoPoint(latitude: 37.78, longitude: -122.41),
  ///   GeoPoint(latitude: 40.71, longitude: -74.00),
  /// ];
  ///
  /// final sorted = GeoDistanceService.sortByDistance(origin, points);
  /// ```
  static List<GeoPoint> sortByDistance(
    GeoPoint origin,
    List<GeoPoint> points, {
    bool ascending = true,
  }) {
    final sorted = List<GeoPoint>.from(points);

    sorted.sort((a, b) {
      final distA = calculateDistance(origin, a);
      final distB = calculateDistance(origin, b);
      return ascending
          ? distA.compareTo(distB)
          : distB.compareTo(distA);
    });

    return sorted;
  }

  // ========================================================================
  // DISTANCE FILTERING
  // ========================================================================

  /// Filters points that are within a specified radius.
  ///
  /// **Parameters:**
  /// - [origin]: The center point
  /// - [points]: List of points to filter
  /// - [radius]: Maximum distance in meters
  ///
  /// **Returns:** List of points within the radius
  ///
  /// **Example:**
  /// ```dart
  /// final origin = GeoPoint(latitude: 37.7749, longitude: -122.4194);
  /// final points = [...];
  ///
  /// final nearby = GeoDistanceService.filterByRadius(
  ///   origin,
  ///   points,
  ///   radius: 1000, // 1 km
  /// );
  /// ```
  static List<GeoPoint> filterByRadius(
    GeoPoint origin,
    List<GeoPoint> points, {
    required double radius,
  }) {
    return points.where((point) {
      final distance = calculateDistance(origin, point);
      return distance <= radius;
    }).toList();
  }

  /// Finds all points within a radius and returns them with distances.
  ///
  /// **Parameters:**
  /// - [origin]: The center point
  /// - [points]: List of points to check
  /// - [radius]: Maximum distance in meters
  ///
  /// **Returns:** List of maps containing 'point' and 'distance'
  ///
  /// **Example:**
  /// ```dart
  /// final results = GeoDistanceService.findNearbyWithDistance(
  ///   origin,
  ///   points,
  ///   radius: 5000,
  /// );
  /// for (final result in results) {
  ///   print('${result['point']}: ${result['distance']}m');
  /// }
  /// ```
  static List<Map<String, dynamic>> findNearbyWithDistance(
    GeoPoint origin,
    List<GeoPoint> points, {
    required double radius,
  }) {
    final results = <Map<String, dynamic>>[];

    for (final point in points) {
      final distance = calculateDistance(origin, point);
      if (distance <= radius) {
        results.add({
          'point': point,
          'distance': distance,
        });
      }
    }

    // Sort by distance
    results.sort((a, b) =>
        (a['distance'] as double).compareTo(b['distance'] as double));

    return results;
  }

  // ========================================================================
  // DISTANCE VALIDATION
  // ========================================================================

  /// Checks if two points are within a specified distance of each other.
  ///
  /// **Parameters:**
  /// - [point1]: First point
  /// - [point2]: Second point
  /// - [maxDistance]: Maximum allowed distance in meters
  ///
  /// **Returns:** `true` if the distance is less than or equal to [maxDistance]
  ///
  /// **Example:**
  /// ```dart
  /// final isNearby = GeoDistanceService.isWithinDistance(
  ///   point1,
  ///   point2,
  ///   maxDistance: 1000,
  /// );
  /// ```
  static bool isWithinDistance(
    GeoPoint point1,
    GeoPoint point2, {
    required double maxDistance,
  }) {
    return calculateDistance(point1, point2) <= maxDistance;
  }

  /// Checks if a point is within a specified distance of any point in a list.
  ///
  /// **Parameters:**
  /// - [point]: The point to check
  /// - [referencePoints]: List of reference points
  /// - [maxDistance]: Maximum allowed distance in meters
  ///
  /// **Returns:** `true` if [point] is within [maxDistance] of any reference point
  static bool isNearAny(
    GeoPoint point,
    List<GeoPoint> referencePoints, {
    required double maxDistance,
  }) {
    return referencePoints.any((ref) =>
        calculateDistance(point, ref) <= maxDistance);
  }
}
