import 'geo_point.dart';

/// Represents a circular geofence area.
///
/// A [GeoCircle] is defined by a [center] point and a [radius] in meters.
/// It can be used to check if a point lies within the circular boundary.
///
/// **Example:**
/// ```dart
/// final circle = GeoCircle(
///   center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
///   radius: 500, // 500 meters
/// );
/// ```
class GeoCircle {
  /// The center point of the circle.
  final GeoPoint center;

  /// The radius of the circle in meters.
  ///
  /// Must be a positive value greater than zero.
  final double radius;

  /// Creates a new [GeoCircle] with the given [center] and [radius].
  ///
  /// Throws [AssertionError] if radius is not positive.
  ///
  /// **Example:**
  /// ```dart
  /// final circle = GeoCircle(
  ///   center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  ///   radius: 1000, // 1 kilometer
  /// );
  /// ```
  const GeoCircle({
    required this.center,
    required this.radius,
  }) : assert(radius > 0, 'Radius must be greater than zero');

  /// Creates a [GeoCircle] from a map containing center and radius data.
  ///
  /// The map must contain:
  /// - 'center': A Map with 'latitude' and 'longitude'
  /// - 'radius': A positive number
  ///
  /// **Example:**
  /// ```dart
  /// final map = {
  ///   'center': {'latitude': 37.7749, 'longitude': -122.4194},
  ///   'radius': 500.0,
  /// };
  /// final circle = GeoCircle.fromMap(map);
  /// ```
  factory GeoCircle.fromMap(Map<String, dynamic> map) {
    return GeoCircle(
      center: GeoPoint.fromMap(map['center'] as Map<String, double>),
      radius: map['radius'] as double,
    );
  }

  /// Converts this [GeoCircle] to a map.
  ///
  /// **Example:**
  /// ```dart
  /// final circle = GeoCircle(
  ///   center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  ///   radius: 500,
  /// );
  /// final map = circle.toMap();
  /// ```
  Map<String, dynamic> toMap() {
    return {
      'center': center.toMap(),
      'radius': radius,
    };
  }

  /// Returns the area of this circle in square meters.
  ///
  /// Uses the formula: A = π × r²
  ///
  /// **Example:**
  /// ```dart
  /// final circle = GeoCircle(
  ///   center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  ///   radius: 100,
  /// );
  /// print(circle.area); // 31415.92653589793
  /// ```
  double get area => 3.14159265359 * radius * radius;

  /// Returns the circumference of this circle in meters.
  ///
  /// Uses the formula: C = 2 × π × r
  ///
  /// **Example:**
  /// ```dart
  /// final circle = GeoCircle(
  ///   center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  ///   radius: 100,
  /// );
  /// print(circle.circumference); // 628.3185307179587
  /// ```
  double get circumference => 2 * 3.14159265359 * radius;

  /// Returns a string representation of this circle.
  @override
  String toString() => 'GeoCircle(center: $center, radius: ${radius}m)';

  /// Compares this [GeoCircle] with [other] for equality.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoCircle &&
          center == other.center &&
          radius == other.radius;

  /// Returns a hash code for this [GeoCircle].
  @override
  int get hashCode => center.hashCode ^ radius.hashCode;
}
