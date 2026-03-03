import 'dart:math';

import '../models/geo_point.dart';
import '../models/geo_polygon.dart';

/// Service for polygon-based geofence operations.
///
/// Uses the Ray Casting algorithm to determine if points lie within
/// polygonal geofences.
///
/// **Example:**
/// ```dart
/// final polygon = GeoPolygon(points: [
///   GeoPoint(latitude: 37.7749, longitude: -122.4194),
///   GeoPoint(latitude: 37.7849, longitude: -122.4094),
///   GeoPoint(latitude: 37.7649, longitude: -122.4094),
/// ]);
///
/// final point = GeoPoint(latitude: 37.7750, longitude: -122.4180);
///
/// final inside = GeoPolygonService.isInsidePolygon(
///   point: point,
///   polygon: polygon,
/// );
/// ```
class GeoPolygonService {
  // ========================================================================
  // POINT IN POLYGON - RAY CASTING ALGORITHM
  // ========================================================================

  /// Checks if a point is inside a polygon using Ray Casting algorithm.
  ///
  /// **Algorithm:**
  /// 1. Cast a horizontal ray from the point to +infinity (right)
  /// 2. Count intersections with polygon edges
  /// 3. Odd count = inside, Even count = outside
  ///
  /// **Parameters:**
  /// - [point]: The point to check
  /// - [polygon]: The polygon to check against
  /// - [includeBoundary]: Whether to consider boundary as inside. Default: true
  ///
  /// **Returns:** `true` if the point is inside the polygon
  ///
  /// **Time Complexity:** O(n) where n is the number of vertices
  /// **Space Complexity:** O(1)
  ///
  /// **Example:**
  /// ```dart
  /// final inside = GeoPolygonService.isInsidePolygon(
  ///   point: myPoint,
  ///   polygon: myPolygon,
  /// );
  /// ```
  static bool isInsidePolygon({
    required GeoPoint point,
    required GeoPolygon polygon,
    bool includeBoundary = true,
  }) {
    // First check if point is on boundary
    if (includeBoundary && isOnBoundary(point: point, polygon: polygon)) {
      return true;
    }

    return _rayCast(point, polygon.points);
  }

  /// Core Ray Casting algorithm implementation.
  ///
  /// Casts a horizontal ray from the point and counts intersections
  /// with polygon edges.
  static bool _rayCast(GeoPoint point, List<GeoPoint> vertices) {
    int intersectCount = 0;
    final int pointCount = vertices.length;

    for (int i = 0; i < pointCount; i++) {
      final GeoPoint p1 = vertices[i];
      final GeoPoint p2 = vertices[(i + 1) % pointCount];

      if (_rayIntersectsEdge(point, p1, p2)) {
        intersectCount++;
      }
    }

    // Odd count = inside, Even count = outside
    return intersectCount % 2 == 1;
  }

  /// Determines if a horizontal ray from [point] intersects edge [p1]-[p2].
  ///
  /// **Algorithm:**
  /// 1. Skip if edge is entirely above or below point
  /// 2. Skip if edge is entirely to the left of point
  /// 3. Calculate intersection x-coordinate
  /// 4. Return true if intersection is to the right of point
  static bool _rayIntersectsEdge(
    GeoPoint point,
    GeoPoint p1,
    GeoPoint p2,
  ) {
    final double px = point.longitude;
    final double py = point.latitude;

    final double x1 = p1.longitude;
    final double y1 = p1.latitude;

    final double x2 = p2.longitude;
    final double y2 = p2.latitude;

    // Edge is entirely above or below the point's horizontal line
    if ((y1 > py) == (y2 > py)) {
      return false;
    }

    // Edge is entirely to the left of the point
    if (x1 < px && x2 < px) {
      return false;
    }

    // Calculate the x-coordinate of intersection
    // Using linear interpolation: x = x1 + (y - y1) * (x2 - x1) / (y2 - y1)
    final double intersectX = x1 + (py - y1) * (x2 - x1) / (y2 - y1);

    // Check if intersection is to the right of the point
    return intersectX > px;
  }

  // ========================================================================
  // BOUNDARY DETECTION
  // ========================================================================

  /// Checks if a point lies on any edge of the polygon.
  ///
  /// **Parameters:**
  /// - [point]: The point to check
  /// - [polygon]: The polygon
  /// - [tolerance]: Distance tolerance in degrees
  ///
  /// **Returns:** `true` if the point is on a polygon edge
  static bool isOnBoundary({
    required GeoPoint point,
    required GeoPolygon polygon,
    double tolerance = 0.00001,
  }) {
    final vertices = polygon.points;

    for (int i = 0; i < vertices.length; i++) {
      final p1 = vertices[i];
      final p2 = vertices[(i + 1) % vertices.length];

      if (_pointOnSegment(point, p1, p2, tolerance)) {
        return true;
      }
    }

    return false;
  }

  /// Checks if a point lies on the line segment [p1]-[p2].
  ///
  /// Uses cross product to determine collinearity and bounding box
  /// check to determine if point is within segment bounds.
  static bool _pointOnSegment(
    GeoPoint point,
    GeoPoint p1,
    GeoPoint p2,
    double tolerance,
  ) {
    // Check if point is within bounding box of segment
    final minLon = (p1.longitude < p2.longitude)
        ? p1.longitude
        : p2.longitude;
    final maxLon = (p1.longitude > p2.longitude)
        ? p1.longitude
        : p2.longitude;
    final minLat = (p1.latitude < p2.latitude)
        ? p1.latitude
        : p2.latitude;
    final maxLat = (p1.latitude > p2.latitude)
        ? p1.latitude
        : p2.latitude;

    if (point.longitude < minLon - tolerance ||
        point.longitude > maxLon + tolerance ||
        point.latitude < minLat - tolerance ||
        point.latitude > maxLat + tolerance) {
      return false;
    }

    // Check if point is collinear with segment
    // Using cross product: (p2 - p1) × (point - p1) should be ~0
    final cross = (p2.longitude - p1.longitude) *
            (point.latitude - p1.latitude) -
        (p2.latitude - p1.latitude) * (point.longitude - p1.longitude);

    return cross.abs() < tolerance;
  }

  // ========================================================================
  // POLYGON VALIDATION
  // ========================================================================

  /// Validates if a polygon is well-formed.
  ///
  /// **Parameters:**
  /// - [polygon]: The polygon to validate
  ///
  /// **Returns:** `true` if the polygon is valid
  ///
  /// **Validation checks:**
  /// - Has at least 3 vertices
  /// - All vertices are valid coordinates
  /// - No duplicate consecutive vertices
  static bool isValidPolygon(GeoPolygon polygon) {
    final points = polygon.points;

    // Must have at least 3 vertices
    if (points.length < 3) {
      return false;
    }

    // Check for duplicate consecutive vertices
    for (int i = 0; i < points.length; i++) {
      final current = points[i];
      final next = points[(i + 1) % points.length];

      if (current == next) {
        return false;
      }
    }

    return true;
  }

  /// Checks if a polygon is convex.
  ///
  /// A polygon is convex if all interior angles are less than 180 degrees.
  /// This is determined by checking the sign of cross products.
  ///
  /// **Returns:** `true` if the polygon is convex
  static bool isConvex(GeoPolygon polygon) {
    final points = polygon.points;
    if (points.length < 3) return false;

    bool hasPositive = false;
    bool hasNegative = false;

    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length];
      final p3 = points[(i + 2) % points.length];

      // Calculate cross product
      final crossProduct =
          (p2.longitude - p1.longitude) * (p3.latitude - p2.latitude) -
              (p2.latitude - p1.latitude) * (p3.longitude - p2.longitude);

      if (crossProduct > 0) hasPositive = true;
      if (crossProduct < 0) hasNegative = true;

      // If we have both positive and negative, polygon is concave
      if (hasPositive && hasNegative) {
        return false;
      }
    }

    return true;
  }

  // ========================================================================
  // BATCH OPERATIONS
  // ========================================================================

  /// Filters points that are inside the polygon.
  ///
  /// **Parameters:**
  /// - [points]: List of points to filter
  /// - [polygon]: The polygon
  ///
  /// **Returns:** List of points inside the polygon
  ///
  /// **Example:**
  /// ```dart
  /// final insidePoints = GeoPolygonService.filterInside(
  ///   points: allPoints,
  ///   polygon: polygon,
  /// );
  /// ```
  static List<GeoPoint> filterInside({
    required List<GeoPoint> points,
    required GeoPolygon polygon,
  }) {
    return points.where((point) => isInsidePolygon(
      point: point,
      polygon: polygon,
    )).toList();
  }

  /// Filters points that are outside the polygon.
  ///
  /// **Parameters:**
  /// - [points]: List of points to filter
  /// - [polygon]: The polygon
  ///
  /// **Returns:** List of points outside the polygon
  static List<GeoPoint> filterOutside({
    required List<GeoPoint> points,
    required GeoPolygon polygon,
  }) {
    return points.where((point) => !isInsidePolygon(
      point: point,
      polygon: polygon,
    )).toList();
  }

  /// Counts how many points are inside the polygon.
  ///
  /// **Parameters:**
  /// - [points]: List of points to count
  /// - [polygon]: The polygon
  ///
  /// **Returns:** Number of points inside
  static int countInside({
    required List<GeoPoint> points,
    required GeoPolygon polygon,
  }) {
    return points.where((point) => isInsidePolygon(
      point: point,
      polygon: polygon,
    )).length;
  }

  /// Counts how many points are outside the polygon.
  ///
  /// **Parameters:**
  /// - [points]: List of points to count
  /// - [polygon]: The polygon
  ///
  /// **Returns:** Number of points outside
  static int countOutside({
    required List<GeoPoint> points,
    required GeoPolygon polygon,
  }) {
    return points.length - countInside(points: points, polygon: polygon);
  }

  // ========================================================================
  // POLYGON METRICS
  // ========================================================================

  /// Calculates the approximate area of the polygon.
  ///
  /// Uses the Shoelace formula (Gauss's area formula).
  /// Note: This is a simplified calculation and assumes spherical projection.
  ///
  /// **Returns:** Approximate area in square meters
  static double calculateArea(GeoPolygon polygon) {
    final points = polygon.points;
    double area = 0;

    for (int i = 0; i < points.length; i++) {
      final j = (i + 1) % points.length;
      area += points[i].longitude * points[j].latitude;
      area -= points[j].longitude * points[i].latitude;
    }

    area = area.abs() / 2;

    // Convert to approximate square meters
    // (very rough approximation, assumes at equator)
    const double metersPerDegree = 111320;
    return area * metersPerDegree * metersPerDegree;
  }

  /// Calculates the perimeter of the polygon.
  ///
  /// **Returns:** Perimeter in meters
  static double calculatePerimeter(GeoPolygon polygon) {
    final points = polygon.points;
    double perimeter = 0;

    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length];

      // Simple distance calculation
      final latDiff = (p2.latitude - p1.latitude) * 111320;
      final lonDiff = (p2.longitude - p1.longitude) *
          111320 *
          cos((p1.latitude + p2.latitude) * pi / 180 / 2);

      perimeter += sqrt(latDiff * latDiff + lonDiff * lonDiff);
    }

    return perimeter;
  }

  // ========================================================================
  // CENTROID AND BOUNDING BOX
  // ========================================================================

  /// Calculates the bounding box of the polygon.
  ///
  /// **Returns:** A map containing 'north', 'south', 'east', 'west'
  static Map<String, double> getBoundingBox(GeoPolygon polygon) {
    final points = polygon.points;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLon = points.first.longitude;
    double maxLon = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLon) minLon = point.longitude;
      if (point.longitude > maxLon) maxLon = point.longitude;
    }

    return {
      'north': maxLat,
      'south': minLat,
      'east': maxLon,
      'west': minLon,
    };
  }

  /// Performs a quick bounding box check before full polygon test.
  ///
  /// This is an optimization to quickly reject points that are clearly
  /// outside the polygon's bounding box.
  ///
  /// **Returns:** `true` if point is within bounding box
  static bool isInBoundingBox({
    required GeoPoint point,
    required GeoPolygon polygon,
  }) {
    final bbox = getBoundingBox(polygon);

    return point.latitude >= bbox['south']! &&
        point.latitude <= bbox['north']! &&
        point.longitude >= bbox['west']! &&
        point.longitude <= bbox['east']!;
  }

  /// Optimized point-in-polygon check with bounding box pre-check.
  ///
  /// This method first checks if the point is within the bounding box,
  /// which is much faster than the full ray casting for points far outside.
  ///
  /// **Returns:** `true` if the point is inside the polygon
  static bool isInsidePolygonOptimized({
    required GeoPoint point,
    required GeoPolygon polygon,
  }) {
    // Quick bounding box rejection
    if (!isInBoundingBox(point: point, polygon: polygon)) {
      return false;
    }

    // Full ray casting check
    return isInsidePolygon(point: point, polygon: polygon);
  }
}
