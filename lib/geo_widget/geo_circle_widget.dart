import 'package:flutter/painting.dart';
import '../models/geo_point.dart';
import 'geo_geofence_base.dart';

/// A circular geofence widget for display on maps.
///
/// This widget represents a circular geofence area with customizable
/// appearance including radius, color, stroke width, and border color.
///
/// **Example:**
/// ```dart
/// final circle = GeoCircleWidget(
///   center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
///   radius: 500,
/// );
///
/// // Using preset
/// final dangerZone = GeoCircleWidget.dangerZone(
///   center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
///   radius: 1000,
/// );
/// ```
class GeoCircleWidget extends GeoGeofenceBase {
  /// The center point of the circle.
  final GeoPoint center;

  /// The radius of the circle in meters.
  final double radius;

  /// Width of the stroke/border in pixels.
  final double strokeWidth;

  /// Color of the stroke/border.
  final Color borderColor;

  /// Creates a new [GeoCircleWidget] with the given properties.
  const GeoCircleWidget({
    required super.id,
    required this.center,
    required this.radius,
    super.color,
    this.strokeWidth = 2.0,
    this.borderColor = const Color(0xFF2196F3),
    super.isInteractive,
    super.metadata,
  });

  /// Creates a [GeoCircleWidget] with a minimal set of required parameters.
  factory GeoCircleWidget.withRadius({
    required GeoPoint center,
    required double radius,
    String? id,
  }) {
    return GeoCircleWidget(
      id: id ?? 'circle_${center.latitude}_${center.longitude}_$radius',
      center: center,
      radius: radius,
    );
  }

  /// Creates a preset "danger zone" circle with red styling.
  factory GeoCircleWidget.dangerZone({
    required GeoPoint center,
    required double radius,
    String? id,
    double strokeWidth = 3.0,
  }) {
    return GeoCircleWidget(
      id: id ?? 'danger_${center.latitude}_${center.longitude}_$radius',
      center: center,
      radius: radius,
      color: const Color(0x33F44336), // Red with 20% opacity
      borderColor: const Color(0xFFF44336), // Solid red
      strokeWidth: strokeWidth,
    );
  }

  /// Creates a preset "safe zone" circle with green styling.
  factory GeoCircleWidget.safeZone({
    required GeoPoint center,
    required double radius,
    String? id,
    double strokeWidth = 2.0,
  }) {
    return GeoCircleWidget(
      id: id ?? 'safe_${center.latitude}_${center.longitude}_$radius',
      center: center,
      radius: radius,
      color: const Color(0x334CAF50), // Green with 20% opacity
      borderColor: const Color(0xFF4CAF50), // Solid green
      strokeWidth: strokeWidth,
    );
  }

  /// Creates a preset "warning zone" circle with orange styling.
  factory GeoCircleWidget.warningZone({
    required GeoPoint center,
    required double radius,
    String? id,
    double strokeWidth = 2.5,
  }) {
    return GeoCircleWidget(
      id: id ?? 'warning_${center.latitude}_${center.longitude}_$radius',
      center: center,
      radius: radius,
      color: const Color(0x33FF9800), // Orange with 20% opacity
      borderColor: const Color(0xFFFF9800), // Solid orange
      strokeWidth: strokeWidth,
    );
  }

  /// Creates a preset "no fly zone" circle with red and hatched pattern.
  factory GeoCircleWidget.noFlyZone({
    required GeoPoint center,
    required double radius,
    String? id,
    double strokeWidth = 4.0,
  }) {
    return GeoCircleWidget(
      id: id ?? 'nofly_${center.latitude}_${center.longitude}_$radius',
      center: center,
      radius: radius,
      color: const Color(0x4DFF0000), // Red with 30% opacity
      borderColor: const Color(0xFFFF0000), // Solid red
      strokeWidth: strokeWidth,
    );
  }

  @override
  void validate() {
    if (radius <= 0) {
      throw StateError('Radius must be greater than zero');
    }
    if (strokeWidth < 0) {
      throw StateError('Stroke width must be non-negative');
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'type': 'circle',
      'center': center.toMap(),
      'radius': radius,
      'strokeWidth': strokeWidth,
      'borderColor': borderColor.value,
    };
  }

  @override
  String toString() =>
      'GeoCircleWidget(id: $id, center: $center, radius: ${radius.toInt()}m)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoCircleWidget &&
          id == other.id &&
          center == other.center &&
          radius == other.radius &&
          color.value == other.color.value &&
          strokeWidth == other.strokeWidth &&
          borderColor.value == other.borderColor.value;

  @override
  int get hashCode =>
      id.hashCode ^
      center.hashCode ^
      radius.hashCode ^
      color.value.hashCode ^
      strokeWidth.hashCode ^
      borderColor.value.hashCode;
}
