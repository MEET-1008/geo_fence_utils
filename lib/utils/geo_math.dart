import 'dart:math';

/// Mathematical utilities for geospatial calculations.
///
/// This class provides static methods for common geographical computations
/// including distance calculation, coordinate conversions, and bearing calculations.
///
/// All distances are in **meters** unless otherwise specified.
///
/// **Example:**
/// ```dart
/// final distance = GeoMath.haversineDistance(
///   37.7749, -122.4194, // San Francisco
///   40.7128, -74.0060,  // New York
/// );
/// print(distance); // ~4130000 meters
/// ```
class GeoMath {
  // ========================================================================
  // CONSTANTS
  // ========================================================================

  /// Earth's mean radius in meters.
  ///
  /// This is the radius used for the Haversine formula.
  /// For more accurate calculations, consider using:
  /// - 6378137 meters (equatorial radius)
  /// - 6356752 meters (polar radius)
  static const double earthRadius = 6371000;

  /// Earth's equatorial radius in meters.
  static const double earthRadiusEquatorial = 6378137;

  /// Earth's polar radius in meters.
  static const double earthRadiusPolar = 6356752;

  // ========================================================================
  // CONVERSION FUNCTIONS
  // ========================================================================

  /// Converts degrees to radians.
  ///
  /// **Formula:** radians = degrees × π / 180
  ///
  /// **Example:**
  /// ```dart
  /// final radians = GeoMath.degreesToRadians(180);
  /// print(radians); // 3.141592653589793
  /// ```
  static double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Converts radians to degrees.
  ///
  /// **Formula:** degrees = radians × 180 / π
  ///
  /// **Example:**
  /// ```dart
  /// final degrees = GeoMath.radiansToDegrees(pi);
  /// print(degrees); // 180.0
  /// ```
  static double radiansToDegrees(double radians) {
    return radians * 180 / pi;
  }

  /// Normalizes an angle to the range [0, 360) degrees.
  ///
  /// **Example:**
  /// ```dart
  /// print(GeoMath.normalizeDegrees(370)); // 10.0
  /// print(GeoMath.normalizeDegrees(-10)); // 350.0
  /// ```
  static double normalizeDegrees(double degrees) {
    degrees = degrees % 360;
    if (degrees < 0) degrees += 360;
    return degrees;
  }

  /// Normalizes a longitude to the range [-180, 180).
  ///
  /// **Example:**
  /// ```dart
  /// print(GeoMath.normalizeLongitude(190)); // -170.0
  /// print(GeoMath.normalizeLongitude(-190)); // 170.0
  /// ```
  static double normalizeLongitude(double longitude) {
    longitude = normalizeDegrees(longitude);
    if (longitude > 180) longitude -= 360;
    return longitude;
  }

  // ========================================================================
  // DISTANCE CALCULATIONS
  // ========================================================================

  /// Calculates the great-circle distance between two points using the
  /// Haversine formula.
  ///
  /// **Parameters:**
  /// - [lat1]: Latitude of point 1 in decimal degrees
  /// - [lon1]: Longitude of point 1 in decimal degrees
  /// - [lat2]: Latitude of point 2 in decimal degrees
  /// - [lon2]: Longitude of point 2 in decimal degrees
  ///
  /// **Returns:** Distance in meters
  ///
  /// **Example:**
  /// ```dart
  /// final distance = GeoMath.haversineDistance(
  ///   37.7749, -122.4194, // San Francisco
  ///   40.7128, -74.0060,  // New York
  /// );
  /// print(distance); // ~4,130,000 meters (4,130 km)
  /// ```
  ///
  /// **Accuracy:** ~0.5% (assuming spherical Earth)
  static double haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = degreesToRadians(lat2 - lat1);
    final dLon = degreesToRadians(lon2 - lon1);

    final lat1Rad = degreesToRadians(lat1);
    final lat2Rad = degreesToRadians(lat2);

    final a = pow(sin(dLat / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLon / 2), 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Calculates the distance between two points using a simplified
  /// planar approximation (Pythagorean theorem).
  ///
  /// **Note:** This is only accurate for short distances (< 10km).
  /// For longer distances, use [haversineDistance].
  ///
  /// **Parameters:**
  /// - [lat1]: Latitude of point 1 in decimal degrees
  /// - [lon1]: Longitude of point 1 in decimal degrees
  /// - [lat2]: Latitude of point 2 in decimal degrees
  /// - [lon2]: Longitude of point 2 in decimal degrees
  ///
  /// **Returns:** Approximate distance in meters
  static double planarDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Convert to meters (approximate)
    final latDiff = (lat2 - lat1) * 111320; // meters per degree latitude
    final lonDiff = (lon2 - lon1) *
        111320 *
        cos(degreesToRadians((lat1 + lat2) / 2)); // adjust for latitude

    return sqrt(latDiff * latDiff + lonDiff * lonDiff);
  }

  // ========================================================================
  // BEARING CALCULATIONS
  // ========================================================================

  /// Calculates the initial bearing (forward azimuth) from point 1 to point 2.
  ///
  /// The bearing is the angle measured clockwise from true north.
  ///
  /// **Parameters:**
  /// - [lat1]: Latitude of starting point in decimal degrees
  /// - [lon1]: Longitude of starting point in decimal degrees
  /// - [lat2]: Latitude of destination point in decimal degrees
  /// - [lon2]: Longitude of destination point in decimal degrees
  ///
  /// **Returns:** Initial bearing in degrees (0-360)
  ///
  /// **Example:**
  /// ```dart
  /// final bearing = GeoMath.calculateBearing(
  ///   37.7749, -122.4194, // San Francisco
  ///   40.7128, -74.0060,  // New York
  /// );
  /// print(bearing); // ~68 degrees (east-northeast)
  /// ```
  static double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final lat1Rad = degreesToRadians(lat1);
    final lat2Rad = degreesToRadians(lat2);
    final dLon = degreesToRadians(lon2 - lon1);

    final y = sin(dLon) * cos(lat2Rad);
    final x = cos(lat1Rad) * sin(lat2Rad) -
        sin(lat1Rad) * cos(lat2Rad) * cos(dLon);

    final bearing = radiansToDegrees(atan2(y, x));

    return normalizeDegrees(bearing);
  }

  /// Calculates the destination point given a starting point, bearing, and distance.
  ///
  /// **Parameters:**
  /// - [lat]: Starting latitude in decimal degrees
  /// - [lon]: Starting longitude in decimal degrees
  /// - [bearing]: Bearing in degrees (0-360, clockwise from north)
  /// - [distance]: Distance in meters
  ///
  /// **Returns:** A map containing 'latitude' and 'longitude' of the destination
  ///
  /// **Example:**
  /// ```dart
  /// final dest = GeoMath.calculateDestination(
  ///   37.7749, -122.4194, // San Francisco
  ///   45,                // northeast
  ///   1000,              // 1 km
  /// );
  /// print(dest); // {latitude: ..., longitude: ...}
  /// ```
  static Map<String, double> calculateDestination({
    required double lat,
    required double lon,
    required double bearing,
    required double distance,
  }) {
    final latRad = degreesToRadians(lat);
    final lonRad = degreesToRadians(lon);
    final bearingRad = degreesToRadians(bearing);

    final angularDistance = distance / earthRadius;

    final lat2Rad = asin(
      sin(latRad) * cos(angularDistance) +
          cos(latRad) * sin(angularDistance) * cos(bearingRad),
    );

    final lon2Rad = lonRad +
        atan2(
          sin(bearingRad) * sin(angularDistance) * cos(latRad),
          cos(angularDistance) - sin(latRad) * sin(lat2Rad),
        );

    return {
      'latitude': radiansToDegrees(lat2Rad),
      'longitude': radiansToDegrees(lon2Rad),
    };
  }

  // ========================================================================
  // MIDPOINT CALCULATIONS
  // ========================================================================

  /// Calculates the midpoint between two points on the Earth's surface.
  ///
  /// **Parameters:**
  /// - [lat1]: Latitude of point 1 in decimal degrees
  /// - [lon1]: Longitude of point 1 in decimal degrees
  /// - [lat2]: Latitude of point 2 in decimal degrees
  /// - [lon2]: Longitude of point 2 in decimal degrees
  ///
  /// **Returns:** A map containing 'latitude' and 'longitude' of the midpoint
  ///
  /// **Example:**
  /// ```dart
  /// final midpoint = GeoMath.calculateMidpoint(
  ///   37.7749, -122.4194, // San Francisco
  ///   40.7128, -74.0060,  // New York
  /// );
  /// ```
  static Map<String, double> calculateMidpoint(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final lat1Rad = degreesToRadians(lat1);
    final lon1Rad = degreesToRadians(lon1);
    final lat2Rad = degreesToRadians(lat2);
    final dLon = degreesToRadians(lon2 - lon1);

    final bx = cos(lat2Rad) * cos(dLon);
    final by = cos(lat2Rad) * sin(dLon);

    final latMidRad = atan2(
      sin(lat1Rad) + sin(lat2Rad),
      sqrt((cos(lat1Rad) + bx) * (cos(lat1Rad) + bx) + by * by),
    );

    final lonMidRad = lon1Rad + atan2(by, cos(lat1Rad) + bx);

    return {
      'latitude': radiansToDegrees(latMidRad),
      'longitude': radiansToDegrees(lonMidRad),
    };
  }
}
