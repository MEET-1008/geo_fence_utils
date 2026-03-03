import 'package:flutter/painting.dart';
import '../models/geo_point.dart';
import 'geo_geofence_base.dart';

/// Cap style for polyline ends.
enum PolylineCap {
  /// Flat cap with no projection.
  butt,

  /// Round cap that extends beyond the endpoint.
  round,

  /// Square cap that extends beyond the endpoint.
  square,
}

/// A polyline widget for displaying paths and routes on maps.
///
/// This widget represents a connected series of line segments with customizable
/// appearance including color, width, cap style, and dash patterns.
///
/// **Example:**
/// ```dart
/// final route = GeoPolylineWidget(
///   points: [
///     GeoPoint(latitude: 37.7749, longitude: -122.4194),
///     GeoPoint(latitude: 37.7849, longitude: -122.4094),
///     GeoPoint(latitude: 37.7949, longitude: -122.3994),
///   ],
/// );
///
/// // Using route preset
/// final path = GeoPolylineWidget.route(points: myPoints);
/// ```
class GeoPolylineWidget extends GeoGeofenceBase {
  /// The list of points defining the polyline.
  final List<GeoPoint> points;

  /// Width of the line in pixels.
  final double width;

  /// Style for the line endings.
  final PolylineCap capStyle;

  /// Whether the line follows the Earth's curvature (geodesic).
  final bool isGeodesic;

  /// Dash pattern for the line (null for solid line).
  /// Values represent lengths of dashes and gaps in pixels.
  final List<int>? dashPattern;

  /// Border/stroke color of the polyline.
  final Color strokeColor;

  /// Creates a new [GeoPolylineWidget] with the given properties.
  const GeoPolylineWidget({
    required super.id,
    required this.points,
    this.width = 4.0,
    this.capStyle = PolylineCap.round,
    this.isGeodesic = true,
    this.dashPattern,
    super.isInteractive,
    super.metadata,
    this.strokeColor = const Color(0xFF2196F3),
  }) : super(color: const Color(0xFF2196F3));

  /// Creates a preset "route" polyline with blue styling.
  factory GeoPolylineWidget.route({
    required List<GeoPoint> points,
    String? id,
    double width = 5.0,
  }) {
    return GeoPolylineWidget(
      id: id ?? 'route_${points.length}_points',
      points: points,
      width: width,
      strokeColor: const Color(0xFF2196F3), // Blue
      capStyle: PolylineCap.round,
      isGeodesic: true,
    );
  }

  /// Creates a preset "boundary" polyline with dashed styling.
  factory GeoPolylineWidget.boundary({
    required List<GeoPoint> points,
    String? id,
    double width = 2.0,
  }) {
    return GeoPolylineWidget(
      id: id ?? 'boundary_${points.length}_points',
      points: points,
      width: width,
      strokeColor: const Color(0xFF9E9E9E), // Gray
      capStyle: PolylineCap.round,
      isGeodesic: false,
      dashPattern: const [10, 10], // Dashed line
    );
  }

  /// Creates a preset "navigation path" polyline with green styling.
  factory GeoPolylineWidget.navigationPath({
    required List<GeoPoint> points,
    String? id,
    double width = 6.0,
  }) {
    return GeoPolylineWidget(
      id: id ?? 'nav_path_${points.length}_points',
      points: points,
      width: width,
      strokeColor: const Color(0xFF4CAF50), // Green
      capStyle: PolylineCap.round,
      isGeodesic: true,
    );
  }

  /// Creates a preset "corridor" polyline with orange styling.
  factory GeoPolylineWidget.corridor({
    required List<GeoPoint> points,
    String? id,
    double width = 4.0,
  }) {
    return GeoPolylineWidget(
      id: id ?? 'corridor_${points.length}_points',
      points: points,
      width: width,
      strokeColor: const Color(0xFFFF9800), // Orange
      capStyle: PolylineCap.round,
      isGeodesic: true,
    );
  }

  /// Creates a preset "flight path" polyline with dashed styling.
  factory GeoPolylineWidget.flightPath({
    required List<GeoPoint> points,
    String? id,
    double width = 3.0,
  }) {
    return GeoPolylineWidget(
      id: id ?? 'flight_path_${points.length}_points',
      points: points,
      width: width,
      strokeColor: const Color(0xFF9C27B0), // Purple
      capStyle: PolylineCap.round,
      isGeodesic: true,
      dashPattern: const [15, 10], // Long dashes
    );
  }

  @override
  void validate() {
    if (points.length < 2) {
      throw StateError('Polyline must have at least 2 points');
    }
    if (width <= 0) {
      throw StateError('Width must be greater than zero');
    }
    if (dashPattern != null && dashPattern!.isEmpty) {
      throw StateError('Dash pattern must not be empty');
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'type': 'polyline',
      'points': points.map((p) => p.toMap()).toList(),
      'width': width,
      'capStyle': capStyle.name,
      'isGeodesic': isGeodesic,
      'dashPattern': dashPattern,
      'strokeColor': strokeColor.value,
    };
  }

  /// Returns the number of points in this polyline.
  int get pointCount => points.length;

  /// Calculates the total length of this polyline in meters.
  ///
  /// This is an approximation using the Haversine formula for each segment.
  double get approximateLength {
    if (points.length < 2) return 0;

    double totalLength = 0;
    for (int i = 0; i < points.length - 1; i++) {
      totalLength += _haversineDistance(points[i], points[i + 1]);
    }
    return totalLength;
  }

  /// Calculates distance between two points using Haversine formula.
  double _haversineDistance(GeoPoint p1, GeoPoint p2) {
    const double earthRadius = 6371000; // Earth's radius in meters

    final lat1Rad = p1.latitude * (3.14159265359 / 180);
    final lat2Rad = p2.latitude * (3.14159265359 / 180);
    final deltaLat = (p2.latitude - p1.latitude) * (3.14159265359 / 180);
    final deltaLng = (p2.longitude - p1.longitude) * (3.14159265359 / 180);

    final a = (deltaLat / 2).abs().sin() *
            (deltaLat / 2).abs().sin() +
        lat1Rad.cos() *
            lat2Rad.cos() *
            (deltaLng / 2).abs().sin() *
            (deltaLng / 2).abs().sin();

    final c = 2 * a.sqrt().asin();

    return earthRadius * c;
  }

  @override
  String toString() =>
      'GeoPolylineWidget(id: $id, points: $pointCount, length: ${approximateLength.toStringAsFixed(0)}m)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoPolylineWidget &&
          id == other.id &&
          points.length == other.points.length &&
          _pointsEqual(points, other.points) &&
          width == other.width &&
          capStyle == other.capStyle &&
          isGeodesic == other.isGeodesic &&
          strokeColor.value == other.strokeColor.value;

  @override
  int get hashCode =>
      id.hashCode ^
      points.length.hashCode ^
      width.hashCode ^
      capStyle.hashCode ^
      isGeodesic.hashCode ^
      strokeColor.value.hashCode;

  bool _pointsEqual(List<GeoPoint> a, List<GeoPoint> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

extension on double {
  double sin() => _sin(this);
  double cos() => _cos(this);
  double sqrt() => _sqrt(this);
  double asin() => _asin(this);
  double abs() => this < 0 ? -this : this;
}

double _sin(double x) {
  // Taylor series approximation for sin
  double result = 0;
  double term = x;
  for (int i = 1; i <= 15; i += 2) {
    result += term;
    term *= -x * x / ((i + 1) * (i + 2));
  }
  return result;
}

double _cos(double x) {
  // Taylor series approximation for cos
  double result = 0;
  double term = 1;
  for (int i = 0; i <= 14; i += 2) {
    result += term;
    term *= -x * x / ((i + 1) * (i + 2));
  }
  return result;
}

double _sqrt(double x) {
  if (x < 0) throw ArgumentError('Cannot compute square root of negative number');
  if (x == 0) return 0;
  double guess = x;
  for (int i = 0; i < 20; i++) {
    guess = (guess + x / guess) / 2;
  }
  return guess;
}

double _asin(double x) {
  if (x < -1 || x > 1) throw ArgumentError('Input must be between -1 and 1');
  // Approximation using atan
  return atan(x / _sqrt(1 - x * x));
}

double atan(double x) {
  // Taylor series for atan
  if (x > 1) return 1.57079632679 - atan(1 / x);
  if (x < -1) return -1.57079632679 - atan(-1 / x);
  double result = 0;
  double term = x;
  double xSquared = x * x;
  for (int i = 1; i <= 15; i += 2) {
    result += term / i;
    term *= -xSquared;
  }
  return result;
}
