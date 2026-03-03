import 'dart:math';

import '../models/geo_circle.dart';
import '../models/geo_point.dart';
import 'geo_distance_service.dart';

/// Service for circle-based geofence operations.
///
/// This service provides methods for checking if points are within
/// circular geofences, calculating distances to boundaries, and
/// performing other circle-related operations.
///
/// **Example:**
/// ```dart
/// final circle = GeoCircle(
///   center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
///   radius: 500, // 500 meters
/// );
///
/// final point = GeoPoint(latitude: 37.7750, longitude: -122.4195);
///
/// final inside = GeoCircleService.isInsideCircle(
///   point: point,
///   circle: circle,
/// );
/// print('Point is inside: $inside');
/// ```
class GeoCircleService {
  // ========================================================================
  // BASIC CONTAINMENT CHECKS
  // ========================================================================

  /// Checks if a point is inside a circular geofence.
  ///
  /// A point is considered "inside" if it lies on or within the
  /// boundary of the circle.
  ///
  /// **Parameters:**
  /// - [point]: The point to check
  /// - [circle]: The circle geofence
  ///
  /// **Returns:** `true` if the point is inside or on the boundary
  ///
  /// **Example:**
  /// ```dart
  /// final inside = GeoCircleService.isInsideCircle(
  ///   point: myPoint,
  ///   circle: myCircle,
  /// );
  /// ```
  ///
  /// **Algorithm:**
  /// ```
  /// distance = haversine(point, circle.center)
  /// return distance <= circle.radius
  /// ```
  static bool isInsideCircle({
    required GeoPoint point,
    required GeoCircle circle,
  }) {
    final distance = GeoDistanceService.calculateDistance(
      point,
      circle.center,
    );

    return distance <= circle.radius;
  }

  /// Checks if a point is outside a circular geofence.
  ///
  /// **Parameters:**
  /// - [point]: The point to check
  /// - [circle]: The circle geofence
  ///
  /// **Returns:** `true` if the point is strictly outside the circle
  static bool isOutsideCircle({
    required GeoPoint point,
    required GeoCircle circle,
  }) {
    return !isInsideCircle(point: point, circle: circle);
  }

  /// Checks if a point is exactly on the circle boundary.
  ///
  /// Uses a tolerance value to account for floating-point precision.
  ///
  /// **Parameters:**
  /// - [point]: The point to check
  /// - [circle]: The circle geofence
  /// - [tolerance]: Distance tolerance in meters. Default: 0.1 meters
  ///
  /// **Returns:** `true` if the point is on the boundary (within tolerance)
  ///
  /// **Example:**
  /// ```dart
  /// final onBoundary = GeoCircleService.isOnBoundary(
  ///   point: point,
  ///   circle: circle,
  ///   tolerance: 1.0, // 1 meter tolerance
  /// );
  /// ```
  static bool isOnBoundary({
    required GeoPoint point,
    required GeoCircle circle,
    double tolerance = 0.1,
  }) {
    final distance = GeoDistanceService.calculateDistance(
      point,
      circle.center,
    );

    return (distance - circle.radius).abs() <= tolerance;
  }

  // ========================================================================
  // DISTANCE CALCULATIONS
  // ========================================================================

  /// Calculates the distance from a point to the circle boundary.
  ///
  /// **Parameters:**
  /// - [point]: The point to measure from
  /// - [circle]: The circle geofence
  ///
  /// **Returns:**
  /// - Positive value if point is outside (distance to nearest boundary)
  /// - Zero if point is on boundary
  /// - Negative value if point is inside (distance to boundary)
  ///
  /// **Example:**
  /// ```dart
  /// final distance = GeoCircleService.distanceToBoundary(
  ///   point: point,
  ///   circle: circle,
  /// );
  ///
  /// if (distance > 0) {
  ///   print('Point is $distance meters outside');
  /// } else if (distance < 0) {
  ///   print('Point is ${distance.abs()} meters inside');
  /// } else {
  ///   print('Point is on boundary');
  /// }
  /// ```
  static double distanceToBoundary({
    required GeoPoint point,
    required GeoCircle circle,
  }) {
    final distance = GeoDistanceService.calculateDistance(
      point,
      circle.center,
    );

    return distance - circle.radius;
  }

  /// Calculates the absolute distance from a point to the circle boundary.
  ///
  /// **Parameters:**
  /// - [point]: The point to measure from
  /// - [circle]: The circle geofence
  ///
  /// **Returns:** Always positive distance to the boundary
  static double absoluteDistanceToBoundary({
    required GeoPoint point,
    required GeoCircle circle,
  }) {
    return distanceToBoundary(point: point, circle: circle).abs();
  }

  // ========================================================================
  // BATCH OPERATIONS
  // ========================================================================

  /// Checks which points from a list are inside the circle.
  ///
  /// **Parameters:**
  /// - [points]: List of points to check
  /// - [circle]: The circle geofence
  ///
  /// **Returns:** List of points that are inside the circle
  ///
  /// **Example:**
  /// ```dart
  /// final allPoints = [point1, point2, point3, point4];
  /// final insidePoints = GeoCircleService.filterInside(
  ///   points: allPoints,
  ///   circle: circle,
  /// );
  /// print('${insidePoints.length} points inside');
  /// ```
  static List<GeoPoint> filterInside({
    required List<GeoPoint> points,
    required GeoCircle circle,
  }) {
    return points.where((point) => isInsideCircle(
      point: point,
      circle: circle,
    )).toList();
  }

  /// Checks which points from a list are outside the circle.
  ///
  /// **Parameters:**
  /// - [points]: List of points to check
  /// - [circle]: The circle geofence
  ///
  /// **Returns:** List of points that are outside the circle
  static List<GeoPoint> filterOutside({
    required List<GeoPoint> points,
    required GeoCircle circle,
  }) {
    return points.where((point) => isOutsideCircle(
      point: point,
      circle: circle,
    )).toList();
  }

  /// Counts how many points from a list are inside the circle.
  ///
  /// **Parameters:**
  /// - [points]: List of points to check
  /// - [circle]: The circle geofence
  ///
  /// **Returns:** Number of points inside the circle
  static int countInside({
    required List<GeoPoint> points,
    required GeoCircle circle,
  }) {
    return points.where((point) => isInsideCircle(
      point: point,
      circle: circle,
    )).length;
  }

  /// Counts how many points from a list are outside the circle.
  ///
  /// **Parameters:**
  /// - [points]: List of points to check
  /// - [circle]: The circle geofence
  ///
  /// **Returns:** Number of points outside the circle
  static int countOutside({
    required List<GeoPoint> points,
    required GeoCircle circle,
  }) {
    return points.length - countInside(points: points, circle: circle);
  }

  // ========================================================================
  // PERCENTAGE CALCULATIONS
  // ========================================================================

  /// Calculates the percentage of points inside the circle.
  ///
  /// **Parameters:**
  /// - [points]: List of points to check
  /// - [circle]: The circle geofence
  ///
  /// **Returns:** Percentage (0-100) of points inside
  ///
  /// **Example:**
  /// ```dart
  /// final percentage = GeoCircleService.percentageInside(
  ///   points: allPoints,
  ///   circle: circle,
  /// );
  /// print('$percentage% of points are inside');
  /// ```
  static double percentageInside({
    required List<GeoPoint> points,
    required GeoCircle circle,
  }) {
    if (points.isEmpty) return 0.0;

    final inside = countInside(points: points, circle: circle);
    return (inside / points.length) * 100;
  }

  // ========================================================================
  // BOUNDARY POINTS
  // ========================================================================

  /// Finds the point on the circle boundary in a given direction.
  ///
  /// **Parameters:**
  /// - [circle]: The circle geofence
  /// - [bearing]: Direction in degrees (0-360, clockwise from north)
  ///
  /// **Returns:** The `GeoPoint` on the boundary at the given bearing
  ///
  /// **Example:**
  /// ```dart
  /// final northPoint = GeoCircleService.findBoundaryPoint(
  ///   circle: circle,
  ///   bearing: 0, // North
  /// );
  ///
  /// final eastPoint = GeoCircleService.findBoundaryPoint(
  ///   circle: circle,
  ///   bearing: 90, // East
  /// );
  /// ```
  static GeoPoint findBoundaryPoint({
    required GeoCircle circle,
    required double bearing,
  }) {
    const double earthRadius = 6371000;

    double degreesToRadians(double degrees) {
      return degrees * pi / 180;
    }

    double radiansToDegrees(double radians) {
      return radians * 180 / pi;
    }

    final latRad = degreesToRadians(circle.center.latitude);
    final lonRad = degreesToRadians(circle.center.longitude);
    final bearingRad = degreesToRadians(bearing);
    final angularDistance = circle.radius / earthRadius;

    final lat2Rad = asin(
      sin(latRad) * cos(angularDistance) +
          cos(latRad) * sin(angularDistance) * cos(bearingRad),
    );

    final lon2Rad = lonRad +
        atan2(
          sin(bearingRad) * sin(angularDistance) * cos(latRad),
          cos(angularDistance) - sin(latRad) * lat2Rad,
        );

    return GeoPoint(
      latitude: radiansToDegrees(lat2Rad),
      longitude: radiansToDegrees(lon2Rad),
    );
  }

  /// Finds all points from a list that are on the boundary.
  ///
  /// **Parameters:**
  /// - [points]: List of points to check
  /// - [circle]: The circle geofence
  /// - [tolerance]: Distance tolerance in meters
  ///
  /// **Returns:** List of points on the boundary
  static List<GeoPoint> findBoundaryPoints({
    required List<GeoPoint> points,
    required GeoCircle circle,
    double tolerance = 0.1,
  }) {
    return points.where((point) => isOnBoundary(
      point: point,
      circle: circle,
      tolerance: tolerance,
    )).toList();
  }

  // ========================================================================
  // CIRCLE RELATIONSHIPS
  // ========================================================================

  /// Checks if two circles overlap.
  ///
  /// **Parameters:**
  /// - [circle1]: First circle
  /// - [circle2]: Second circle
  ///
  /// **Returns:** `true` if the circles overlap or touch
  ///
  /// **Algorithm:**
  /// Two circles overlap if the distance between centers
  /// is less than or equal to the sum of their radii.
  static bool circlesOverlap({
    required GeoCircle circle1,
    required GeoCircle circle2,
  }) {
    final distance = GeoDistanceService.calculateDistance(
      circle1.center,
      circle2.center,
    );

    return distance <= (circle1.radius + circle2.radius);
  }

  /// Checks if one circle contains another.
  ///
  /// **Parameters:**
  /// - [outer]: Potential outer circle
  /// - [inner]: Potential inner circle
  ///
  /// **Returns:** `true` if [inner] is completely inside [outer]
  static bool containsCircle({
    required GeoCircle outer,
    required GeoCircle inner,
  }) {
    final distance = GeoDistanceService.calculateDistance(
      outer.center,
      inner.center,
    );

    return (distance + inner.radius) <= outer.radius;
  }
}
