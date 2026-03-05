import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import '../../extensions/geo_point_extensions.dart';
import '../geo_polyline_widget.dart';
import '../geo_geofence_base.dart';

/// Builder for creating polyline overlays on different map implementations.
///
/// This class provides static methods to build polyline overlays for both
/// flutter_map and google_maps_flutter packages.
class PolylineOverlayBuilder {
  PolylineOverlayBuilder._();

  /// Builds a polyline overlay for flutter_map.
  ///
  /// [polyline] - The polyline widget to render
  /// [onTap] - Optional callback when the polyline is tapped
  ///
  /// **Example:**
  /// ```dart
  /// final polyline = GeoPolylineWidget.route(points: myPoints);
  /// final overlay = PolylineOverlayBuilder.buildFlutterMap(polyline, (id) {
  ///   print('Tapped polyline: $id');
  /// });
  /// ```
  static Polyline<String> buildFlutterMap(
    GeoPolylineWidget polyline,
    OnGeofenceTap? onTap,
  ) {
    return Polyline<String>(
      points: polyline.points.toFlutterLatLngList(),
      strokeWidth: polyline.width,
      color: Color.fromRGBO(
        (polyline.strokeColor.value >> 16) & 0xFF,
        (polyline.strokeColor.value >> 8) & 0xFF,
        polyline.strokeColor.value & 0xFF,
        ((polyline.strokeColor.value >> 24) & 0xFF) / 255.0,
      ),
      borderStrokeWidth: 0,
      borderColor: const Color(0x00000000),
      strokeCap: _flutterCapFromEnum(polyline.capStyle),
      pattern: _buildDashPatternForFlutterMap(polyline.dashPattern) ?? const StrokePattern.solid(),
    );
  }

  /// Builds a polyline overlay for google_maps_flutter.
  ///
  /// [polyline] - The polyline widget to render
  /// [onTap] - Optional callback when the polyline is tapped
  ///
  /// **Example:**
  /// ```dart
  /// final polyline = GeoPolylineWidget.route(points: myPoints);
  /// final overlay = PolylineOverlayBuilder.buildGoogleMap(polyline, (id) {
  ///   print('Tapped polyline: $id');
  /// });
  /// ```
  static google.Polyline buildGoogleMap(
    GeoPolylineWidget polyline,
    OnGeofenceTap? onTap,
  ) {
    return google.Polyline(
      polylineId: google.PolylineId(polyline.id),
      points: polyline.points.toGoogleLatLngList(),
      width: polyline.width.toInt(),
      color: Color.fromARGB(
        (polyline.strokeColor.value >> 24) & 0xFF,
        (polyline.strokeColor.value >> 16) & 0xFF,
        (polyline.strokeColor.value >> 8) & 0xFF,
        polyline.strokeColor.value & 0xFF,
      ),
      consumeTapEvents: polyline.isInteractive,
      onTap: onTap != null ? () => onTap(polyline.id) : null,
      visible: true,
      geodesic: polyline.isGeodesic,
      startCap: _googleCapFromEnum(polyline.capStyle),
      endCap: _googleCapFromEnum(polyline.capStyle),
      jointType: google.JointType.round,
      patterns: _buildDashPattern(polyline.dashPattern),
    );
  }

  /// Builds multiple polyline overlays for flutter_map.
  static List<Polyline<String>> buildFlutterMapList(
    List<GeoPolylineWidget> polylines,
    OnGeofenceTap? onTap,
  ) {
    return polylines.map((polyline) => buildFlutterMap(polyline, onTap)).toList();
  }

  /// Builds multiple polyline overlays for google_maps_flutter.
  static Set<google.Polyline> buildGoogleMapSet(
    List<GeoPolylineWidget> polylines,
    OnGeofenceTap? onTap,
  ) {
    return polylines.map((polyline) => buildGoogleMap(polyline, onTap)).toSet();
  }

  /// Converts PolylineCap enum to flutter_map StrokeCap.
  static StrokeCap _flutterCapFromEnum(PolylineCap cap) {
    switch (cap) {
      case PolylineCap.butt:
        return StrokeCap.butt;
      case PolylineCap.round:
        return StrokeCap.round;
      case PolylineCap.square:
        return StrokeCap.square;
    }
  }

  /// Converts PolylineCap enum to google_maps_flutter Cap.
  static google.Cap _googleCapFromEnum(PolylineCap cap) {
    switch (cap) {
      case PolylineCap.butt:
        return google.Cap.buttCap;
      case PolylineCap.round:
        return google.Cap.roundCap;
      case PolylineCap.square:
        return google.Cap.squareCap;
    }
  }

  /// Builds dash pattern for google_maps_flutter.
  static List<google.PatternItem> _buildDashPattern(List<int>? pattern) {
    if (pattern == null || pattern.isEmpty) return [];

    return pattern.map((item) {
      if (item > 0) {
        return google.PatternItem.dash(item.toDouble());
      } else {
        return google.PatternItem.gap(item.abs().toDouble());
      }
    }).toList();
  }

  /// Builds dash pattern for flutter_map.
  static StrokePattern? _buildDashPatternForFlutterMap(List<int>? pattern) {
    if (pattern == null || pattern.isEmpty) return null;

    // Convert simple dash pattern to StrokePattern
    return StrokePattern.dashed(
      segments: pattern.map((i) => i.toDouble()).toList(),
    );
  }
}
