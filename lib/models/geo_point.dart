/// Represents a geographical point on Earth using latitude and longitude.
///
/// The [GeoPoint] class is immutable and represents a specific location
/// using the WGS 84 coordinate system (used by GPS).
///
/// **Example:**
/// ```dart
/// final point = GeoPoint(
///   latitude: 37.7749,
///   longitude: -122.4194,
/// );
/// ```
///
/// **Constraints:**
/// - Latitude must be between -90 and 90 degrees
/// - Longitude must be between -180 and 180 degrees
class GeoPoint {
  /// Latitude in decimal degrees.
  ///
  /// Valid range: -90.0 to +90.0
  /// - Positive values: Northern Hemisphere
  /// - Negative values: Southern Hemisphere
  /// - 0: Equator
  final double latitude;

  /// Longitude in decimal degrees.
  ///
  /// Valid range: -180.0 to +180.0
  /// - Positive values: Eastern Hemisphere
  /// - Negative values: Western Hemisphere
  /// - 0: Prime Meridian
  final double longitude;

  /// Creates a new [GeoPoint] with the given [latitude] and [longitude].
  ///
  /// Throws [AssertionError] if coordinates are out of valid range.
  ///
  /// **Example:**
  /// ```dart
  /// final sf = GeoPoint(
  ///   latitude: 37.7749,
  ///   longitude: -122.4194,
  /// );
  /// ```
  const GeoPoint({
    required this.latitude,
    required this.longitude,
  })  : assert(latitude >= -90 && latitude <= 90,
            'Latitude must be between -90 and 90'),
        assert(longitude >= -180 && longitude <= 180,
            'Longitude must be between -180 and 180');

  /// Creates a [GeoPoint] from a map containing 'latitude' and 'longitude' keys.
  ///
  /// **Example:**
  /// ```dart
  /// final map = {'latitude': 37.7749, 'longitude': -122.4194};
  /// final point = GeoPoint.fromMap(map);
  /// ```
  factory GeoPoint.fromMap(Map<String, double> map) {
    return GeoPoint(
      latitude: map['latitude']!,
      longitude: map['longitude']!,
    );
  }

  /// Converts this [GeoPoint] to a map.
  ///
  /// **Example:**
  /// ```dart
  /// final point = GeoPoint(latitude: 37.7749, longitude: -122.4194);
  /// final map = point.toMap();
  /// print(map); // {latitude: 37.7749, longitude: -122.4194}
  /// ```
  Map<String, double> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Returns a string representation of this point.
  ///
  /// **Example:**
  /// ```dart
  /// final point = GeoPoint(latitude: 37.7749, longitude: -122.4194);
  /// print(point); // GeoPoint(37.7749, -122.4194)
  /// ```
  @override
  String toString() => 'GeoPoint($latitude, $longitude)';

  /// Compares this [GeoPoint] with [other] for equality.
  ///
  /// Two points are equal if their latitudes and longitudes are exactly equal.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoPoint &&
          latitude == other.latitude &&
          longitude == other.longitude;

  /// Returns a hash code for this [GeoPoint].
  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
