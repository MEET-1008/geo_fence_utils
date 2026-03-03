/// Base exception class for all geofence-related errors.
///
/// This exception can be used as a catch-all for geofence-specific errors.
///
/// **Example:**
/// ```dart
/// try {
///   // geofence operation
/// } on GeoException catch (e) {
///   print('Geofence error: ${e.message}');
/// }
/// ```
class GeoException implements Exception {
  /// Human-readable error message
  final String message;

  /// Optional error code for programmatic handling
  final String? code;

  /// Optional underlying exception
  final Object? cause;

  const GeoException(
    this.message, {
    this.code,
    this.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('GeoException: $message');
    if (code != null) {
      buffer.write(' (code: $code)');
    }
    if (cause != null) {
      buffer.write('\nCaused by: $cause');
    }
    return buffer.toString();
  }
}

// ============================================================================
// RADIUS EXCEPTIONS
// ============================================================================

/// Exception thrown when a radius value is invalid.
///
/// A radius is considered invalid if:
/// - It is zero
/// - It is negative
/// - It exceeds maximum practical value
///
/// **Example:**
/// ```dart
/// try {
///   final circle = GeoCircle(center: point, radius: -100);
/// } on InvalidRadiusException catch (e) {
///   print('Invalid radius: ${e.message}');
/// }
/// ```
class InvalidRadiusException extends GeoException {
  /// The invalid radius value that caused this exception
  final double invalidValue;

  /// Minimum allowed radius value
  final double? minValue;

  /// Maximum allowed radius value
  final double? maxValue;

  const InvalidRadiusException(
    super.message, {
    required this.invalidValue,
    this.minValue,
    this.maxValue,
    super.code,
  });

  /// Creates an exception for negative radius.
  factory InvalidRadiusException.negative(double value) {
    return InvalidRadiusException(
      'Radius cannot be negative. Got: $value',
      invalidValue: value,
      minValue: 0,
    );
  }

  /// Creates an exception for zero radius.
  factory InvalidRadiusException.zero() {
    return InvalidRadiusException(
      'Radius cannot be zero',
      invalidValue: 0,
      minValue: 0,
      code: 'ZERO_RADIUS',
    );
  }

  /// Creates an exception for radius that's too small.
  factory InvalidRadiusException.tooSmall(double value, double min) {
    return InvalidRadiusException(
      'Radius must be at least $min meters. Got: $value',
      invalidValue: value,
      minValue: min,
      code: 'RADIUS_TOO_SMALL',
    );
  }

  /// Creates an exception for radius that's too large.
  factory InvalidRadiusException.tooLarge(double value, double max) {
    return InvalidRadiusException(
      'Radius cannot exceed $max meters. Got: $value',
      invalidValue: value,
      maxValue: max,
      code: 'RADIUS_TOO_LARGE',
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('InvalidRadiusException: $message');
    buffer.write(' (value: $invalidValue');
    if (code != null) buffer.write(', code: $code');
    return buffer.toString();
  }
}

// ============================================================================
// POLYGON EXCEPTIONS
// ============================================================================

/// Exception thrown when a polygon is invalid.
///
/// A polygon is considered invalid if:
/// - It has fewer than 3 vertices
/// - It has duplicate consecutive vertices
/// - It has self-intersecting edges
/// - Vertices contain invalid coordinates
///
/// **Example:**
/// ```dart
/// try {
///   GeoPolygonService.validatePolygon(polygon);
/// } on InvalidPolygonException catch (e) {
///   print('Invalid polygon: ${e.message}');
/// }
/// ```
class InvalidPolygonException extends GeoException {
  /// The number of vertices in the invalid polygon
  final int? vertexCount;

  /// Creates an exception for insufficient vertices.
  factory InvalidPolygonException.tooFewVertices(int count) {
    return InvalidPolygonException(
      'Polygon must have at least 3 vertices. Got: $count',
      vertexCount: count,
      code: 'TOO_FEW_VERTICES',
    );
  }

  /// Creates an exception for duplicate consecutive vertices.
  factory InvalidPolygonException.duplicateVertices() {
    return InvalidPolygonException(
      'Polygon cannot have duplicate consecutive vertices',
      code: 'DUPLICATE_VERTICES',
    );
  }

  /// Creates an exception for self-intersecting polygon.
  factory InvalidPolygonException.selfIntersecting() {
    return InvalidPolygonException(
      'Polygon has self-intersecting edges',
      code: 'SELF_INTERSECTING',
    );
  }

  /// Creates an exception for invalid polygon structure.
  factory InvalidPolygonException.invalidStructure([String? detail]) {
    final message = detail ?? 'Polygon structure is invalid';
    return InvalidPolygonException(
      message,
      code: 'INVALID_STRUCTURE',
    );
  }

  const InvalidPolygonException(
    super.message, {
    this.vertexCount,
    super.code,
  });

  @override
  String toString() {
    final buffer = StringBuffer('InvalidPolygonException: $message');
    if (vertexCount != null) {
      buffer.write(' (vertices: $vertexCount)');
    }
    if (code != null) buffer.write(', code: $code');
    return buffer.toString();
  }
}

// ============================================================================
// COORDINATE EXCEPTIONS
// ============================================================================

/// Exception thrown when geographical coordinates are invalid.
///
/// Coordinates are considered invalid if:
/// - Latitude is outside [-90, 90]
/// - Longitude is outside [-180, 180]
/// - Values are NaN or infinite
///
/// **Example:**
/// ```dart
/// try {
///   final point = GeoPoint(latitude: 100, longitude: 0);
/// } on InvalidCoordinateException catch (e) {
///   print('Invalid coordinate: ${e.message}');
/// }
/// ```
class InvalidCoordinateException extends GeoException {
  /// The invalid latitude value, if applicable
  final double? latitude;

  /// The invalid longitude value, if applicable
  final double? longitude;

  /// Creates an exception for invalid latitude.
  factory InvalidCoordinateException.invalidLatitude(double value) {
    return InvalidCoordinateException(
      'Latitude must be between -90 and 90 degrees. Got: $value',
      latitude: value,
      code: 'INVALID_LATITUDE',
    );
  }

  /// Creates an exception for invalid longitude.
  factory InvalidCoordinateException.invalidLongitude(double value) {
    return InvalidCoordinateException(
      'Longitude must be between -180 and 180 degrees. Got: $value',
      longitude: value,
      code: 'INVALID_LONGITUDE',
    );
  }

  /// Creates an exception for both invalid coordinates.
  factory InvalidCoordinateException.invalid({
    required double latitude,
    required double longitude,
  }) {
    return InvalidCoordinateException(
      'Invalid coordinates: latitude=$latitude, longitude=$longitude',
      latitude: latitude,
      longitude: longitude,
      code: 'INVALID_COORDINATES',
    );
  }

  /// Creates an exception for NaN or infinite values.
  factory InvalidCoordinateException.notFinite({
    double? latitude,
    double? longitude,
  }) {
    final latMsg = latitude != null && !latitude.isFinite
        ? 'latitude is not finite'
        : null;
    final lonMsg = longitude != null && !longitude.isFinite
        ? 'longitude is not finite'
        : null;

    final messages = [latMsg, lonMsg].whereType<String>().join(', ');

    return InvalidCoordinateException(
      'Coordinate values are not finite: $messages',
      latitude: latitude,
      longitude: longitude,
      code: 'NOT_FINITE',
    );
  }

  const InvalidCoordinateException(
    super.message, {
    this.latitude,
    this.longitude,
    super.code,
  });

  @override
  String toString() {
    final buffer = StringBuffer('InvalidCoordinateException: $message');
    if (latitude != null || longitude != null) {
      buffer.write(' (');
      if (latitude != null) buffer.write('lat: $latitude');
      if (longitude != null) {
        if (latitude != null) buffer.write(', ');
        buffer.write('lon: $longitude');
      }
      buffer.write(')');
    }
    if (code != null) buffer.write(', code: $code');
    return buffer.toString();
  }
}

// ============================================================================
// CALCULATION EXCEPTIONS
// ============================================================================

/// Exception thrown when a calculation fails or produces invalid results.
///
/// **Example:**
/// ```dart
/// try {
///   final distance = GeoDistanceService.calculateDistance(p1, p2);
/// } on GeoCalculationException catch (e) {
///   print('Calculation error: ${e.message}');
/// }
/// ```
class GeoCalculationException extends GeoException {
  /// The operation that failed
  final String operation;

  const GeoCalculationException(
    super.message, {
    required this.operation,
    super.code,
  });

  /// Creates an exception for distance calculation failure.
  factory GeoCalculationException.distanceCalculation(
      [String? detail]) {
    return GeoCalculationException(
      detail ?? 'Failed to calculate distance',
      operation: 'distance_calculation',
      code: 'DISTANCE_CALC_FAILED',
    );
  }

  /// Creates an exception for bearing calculation failure.
  factory GeoCalculationException.bearingCalculation(
      [String? detail]) {
    return GeoCalculationException(
      detail ?? 'Failed to calculate bearing',
      operation: 'bearing_calculation',
      code: 'BEARING_CALC_FAILED',
    );
  }

  /// Creates an exception for area calculation failure.
  factory GeoCalculationException.areaCalculation([String? detail]) {
    return GeoCalculationException(
      detail ?? 'Failed to calculate area',
      operation: 'area_calculation',
      code: 'AREA_CALC_FAILED',
    );
  }

  @override
  String toString() =>
      'GeoCalculationException: $message (operation: $operation)';
}
