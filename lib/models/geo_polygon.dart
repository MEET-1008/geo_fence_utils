import 'geo_point.dart';

/// Represents a polygonal geofence area.
///
/// A [GeoPolygon] is defined by a list of [GeoPoint] vertices connected
/// in order to form a closed shape.
///
/// **Example:**
/// ```dart
/// final polygon = GeoPolygon(points: [
///   GeoPoint(latitude: 37.7749, longitude: -122.4194),
///   GeoPoint(latitude: 37.7849, longitude: -122.4094),
///   GeoPoint(latitude: 37.7649, longitude: -122.4094),
/// ]);
/// ```
class GeoPolygon {
  /// The list of vertices defining the polygon.
  ///
  /// Must contain at least 3 points to form a valid polygon.
  final List<GeoPoint> points;

  /// Creates a new [GeoPolygon] with the given [points].
  ///
  /// Throws [AssertionError] if fewer than 3 points are provided.
  ///
  /// **Example:**
  /// ```dart
  /// final polygon = GeoPolygon(points: [
  ///   GeoPoint(latitude: 37.7749, longitude: -122.4194),
  ///   GeoPoint(latitude: 37.7849, longitude: -122.4094),
  ///   GeoPoint(latitude: 37.7649, longitude: -122.4094),
  /// ]);
  /// ```
  const GeoPolygon({
    required this.points,
  }) : assert(points.length >= 3,
            'Polygon must have at least 3 points');

  /// Creates a [GeoPolygon] from a list of coordinate maps.
  ///
  /// **Example:**
  /// ```dart
  /// final maps = [
  ///   {'latitude': 37.7749, 'longitude': -122.4194},
  ///   {'latitude': 37.7849, 'longitude': -122.4094},
  ///   {'latitude': 37.7649, 'longitude': -122.4094},
  /// ];
  /// final polygon = GeoPolygon.fromMaps(maps);
  /// ```
  factory GeoPolygon.fromMaps(List<Map<String, double>> maps) {
    return GeoPolygon(
      points: maps.map((map) => GeoPoint.fromMap(map)).toList(),
    );
  }

  /// Creates a rectangular polygon from bounding coordinates.
  ///
  /// [north] - Northern latitude boundary
  /// [south] - Southern latitude boundary
  /// [east] - Eastern longitude boundary
  /// [west] - Western longitude boundary
  ///
  /// **Example:**
  /// ```dart
  /// final rect = GeoPolygon.rectangle(
  ///   north: 37.78,
  ///   south: 37.76,
  ///   east: -122.40,
  ///   west: -122.42,
  /// );
  /// ```
  factory GeoPolygon.rectangle({
    required double north,
    required double south,
    required double east,
    required double west,
  }) {
    return GeoPolygon(
      points: [
        GeoPoint(latitude: north, longitude: west),
        GeoPoint(latitude: north, longitude: east),
        GeoPoint(latitude: south, longitude: east),
        GeoPoint(latitude: south, longitude: west),
      ],
    );
  }

  /// Returns the number of vertices in this polygon.
  int get vertexCount => points.length;

  /// Checks if this polygon is convex.
  ///
  /// A polygon is convex if all interior angles are less than 180 degrees.
  /// This is a simplified check using cross products.
  ///
  /// **Note:** This is a basic implementation and may not handle
  /// all edge cases (collinear points, etc.).
  bool get isConvex {
    if (points.length < 3) return false;

    bool hasPositive = false;
    bool hasNegative = false;

    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length];
      final p3 = points[(i + 2) % points.length];

      final crossProduct =
          (p2.longitude - p1.longitude) * (p3.latitude - p2.latitude) -
              (p2.latitude - p1.latitude) * (p3.longitude - p2.longitude);

      if (crossProduct > 0) hasPositive = true;
      if (crossProduct < 0) hasNegative = true;

      if (hasPositive && hasNegative) return false;
    }

    return true;
  }

  /// Returns the centroid (geometric center) of this polygon.
  ///
  /// Uses the arithmetic mean of all vertex coordinates.
  ///
  /// **Example:**
  /// ```dart
  /// final polygon = GeoPolygon(points: [...]);
  /// final center = polygon.centroid;
  /// ```
  GeoPoint get centroid {
    if (points.isEmpty) {
      throw StateError('Cannot compute centroid of empty polygon');
    }

    double totalLat = 0;
    double totalLng = 0;

    for (final point in points) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }

    return GeoPoint(
      latitude: totalLat / points.length,
      longitude: totalLng / points.length,
    );
  }

  /// Converts this [GeoPolygon] to a list of maps.
  ///
  /// **Example:**
  /// ```dart
  /// final polygon = GeoPolygon(points: [...]);
  /// final maps = polygon.toMaps();
  /// ```
  List<Map<String, double>> toMaps() {
    return points.map((point) => point.toMap()).toList();
  }

  /// Returns a string representation of this polygon.
  @override
  String toString() => 'GeoPolygon(vertices: $vertexCount)';

  /// Compares this [GeoPolygon] with [other] for equality.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoPolygon &&
          points.length == other.points.length &&
          _listEquals(points, other.points);

  /// Returns a hash code for this [GeoPolygon].
  @override
  int get hashCode => points.hashCode;

  /// Helper method to compare two lists of GeoPoints.
  bool _listEquals(List<GeoPoint> a, List<GeoPoint> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
