import 'package:flutter/painting.dart';
import '../models/geo_point.dart';
import 'geo_geofence_base.dart';

/// A polygonal geofence widget for display on maps.
///
/// This widget represents a polygon geofence area with customizable
/// appearance including vertices, color, stroke width, and border color.
///
/// **Example:**
/// ```dart
/// final polygon = GeoPolygonWidget(
///   points: [
///     GeoPoint(latitude: 37.7749, longitude: -122.4194),
///     GeoPoint(latitude: 37.7849, longitude: -122.4094),
///     GeoPoint(latitude: 37.7649, longitude: -122.4094),
///   ],
/// );
///
/// // Using bounds factory
/// final rect = GeoPolygonWidget.fromBounds(
///   north: 37.78,
///   south: 37.76,
///   east: -122.40,
///   west: -122.42,
/// );
/// ```
class GeoPolygonWidget extends GeoGeofenceBase {
  /// The list of vertices defining the polygon.
  final List<GeoPoint> points;

  /// Width of the stroke/border in pixels.
  final double strokeWidth;

  /// Color of the stroke/border.
  final Color borderColor;

  /// Creates a new [GeoPolygonWidget] with the given properties.
  const GeoPolygonWidget({
    required super.id,
    required this.points,
    super.color,
    this.strokeWidth = 2.0,
    this.borderColor = const Color(0xFF2196F3),
    super.isInteractive,
    super.metadata,
  });

  /// Creates a rectangular polygon from bounding coordinates.
  factory GeoPolygonWidget.fromBounds({
    required double north,
    required double south,
    required double east,
    required double west,
    String? id,
  }) {
    return GeoPolygonWidget(
      id: id ?? 'polygon_bounds_${north}_${south}_${east}_${west}',
      points: [
        GeoPoint(latitude: north, longitude: west),
        GeoPoint(latitude: north, longitude: east),
        GeoPoint(latitude: south, longitude: east),
        GeoPoint(latitude: south, longitude: west),
      ],
    );
  }

  /// Creates a polygon from a list of coordinate pairs.
  factory GeoPolygonWidget.fromCoordinates({
    required List<List<double>> coordinates,
    String? id,
  }) {
    final points = coordinates
        .map((coord) => GeoPoint(latitude: coord[0], longitude: coord[1]))
        .toList();

    return GeoPolygonWidget(
      id: id ?? 'polygon_coords_${points.length}',
      points: points,
    );
  }

  /// Creates a preset "restricted area" polygon with red styling.
  factory GeoPolygonWidget.restrictedArea({
    required List<GeoPoint> points,
    String? id,
    double strokeWidth = 3.0,
  }) {
    return GeoPolygonWidget(
      id: id ?? 'restricted_${points.length}_vertices',
      points: points,
      color: const Color(0x4D000000), // Black with 30% opacity
      borderColor: const Color(0xFFFF0000), // Red border
      strokeWidth: strokeWidth,
    );
  }

  /// Creates a preset "perimeter" polygon with blue styling.
  factory GeoPolygonWidget.perimeter({
    required List<GeoPoint> points,
    String? id,
    double strokeWidth = 2.5,
  }) {
    return GeoPolygonWidget(
      id: id ?? 'perimeter_${points.length}_vertices',
      points: points,
      color: const Color(0x1A2196F3), // Blue with 10% opacity
      borderColor: const Color(0xFF2196F3), // Solid blue
      strokeWidth: strokeWidth,
    );
  }

  /// Creates a preset "secure zone" polygon with green styling.
  factory GeoPolygonWidget.secureZone({
    required List<GeoPoint> points,
    String? id,
    double strokeWidth = 3.0,
  }) {
    return GeoPolygonWidget(
      id: id ?? 'secure_${points.length}_vertices',
      points: points,
      color: const Color(0x334CAF50), // Green with 20% opacity
      borderColor: const Color(0xFF4CAF50), // Solid green
      strokeWidth: strokeWidth,
    );
  }

  @override
  void validate() {
    if (points.length < 3) {
      throw StateError('Polygon must have at least 3 points');
    }
    if (strokeWidth < 0) {
      throw StateError('Stroke width must be non-negative');
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'type': 'polygon',
      'points': points.map((p) => p.toMap()).toList(),
      'strokeWidth': strokeWidth,
      'borderColor': borderColor.value,
    };
  }

  /// Returns the number of vertices in this polygon.
  int get vertexCount => points.length;

  /// Returns the centroid (geometric center) of this polygon.
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

  @override
  String toString() =>
      'GeoPolygonWidget(id: $id, vertices: $vertexCount)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoPolygonWidget &&
          id == other.id &&
          points.length == other.points.length &&
          _pointsEqual(points, other.points) &&
          color.value == other.color.value &&
          strokeWidth == other.strokeWidth &&
          borderColor.value == other.borderColor.value;

  @override
  int get hashCode =>
      id.hashCode ^
      points.length.hashCode ^
      color.value.hashCode ^
      strokeWidth.hashCode ^
      borderColor.value.hashCode;

  bool _pointsEqual(List<GeoPoint> a, List<GeoPoint> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
