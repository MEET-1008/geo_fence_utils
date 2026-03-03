import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import '../../extensions/geo_point_extensions.dart';
import '../geo_polygon_widget.dart';
import '../geo_geofence_base.dart';

/// Builder for creating polygon overlays on different map implementations.
///
/// This class provides static methods to build polygon overlays for both
/// flutter_map and google_maps_flutter packages.
class PolygonOverlayBuilder {
  PolygonOverlayBuilder._();

  /// Builds a polygon overlay for flutter_map.
  ///
  /// [polygon] - The polygon widget to render
  /// [onTap] - Optional callback when the polygon is tapped
  ///
  /// **Example:**
  /// ```dart
  /// final polygon = GeoPolygonWidget.fromBounds(
  ///   north: 37.78,
  ///   south: 37.76,
  ///   east: -122.40,
  ///   west: -122.42,
  /// );
  /// final overlay = PolygonOverlayBuilder.buildFlutterMap(polygon, (id) {
  ///   print('Tapped polygon: $id');
  /// });
  /// ```
  static Polygon<String> buildFlutterMap(
    GeoPolygonWidget polygon,
    OnGeofenceTap? onTap,
  ) {
    return Polygon<String>(
      points: polygon.points.toFlutterLatLngList(),
      color: Color.fromRGBO(
        (polygon.color.value >> 16) & 0xFF,
        (polygon.color.value >> 8) & 0xFF,
        polygon.color.value & 0xFF,
        ((polygon.color.value >> 24) & 0xFF) / 255.0,
      ),
      borderColor: Color.fromRGBO(
        (polygon.borderColor.value >> 16) & 0xFF,
        (polygon.borderColor.value >> 8) & 0xFF,
        polygon.borderColor.value & 0xFF,
        ((polygon.borderColor.value >> 24) & 0xFF) / 255.0,
      ),
      borderStrokeWidth: polygon.strokeWidth,
      isFilled: true,
    );
  }

  /// Builds a polygon overlay for google_maps_flutter.
  ///
  /// [polygon] - The polygon widget to render
  /// [onTap] - Optional callback when the polygon is tapped
  ///
  /// **Example:**
  /// ```dart
  /// final polygon = GeoPolygonWidget.fromBounds(
  ///   north: 37.78,
  ///   south: 37.76,
  ///   east: -122.40,
  ///   west: -122.42,
  /// );
  /// final overlay = PolygonOverlayBuilder.buildGoogleMap(polygon, (id) {
  ///   print('Tapped polygon: $id');
  /// });
  /// ```
  static google.Polygon buildGoogleMap(
    GeoPolygonWidget polygon,
    OnGeofenceTap? onTap,
  ) {
    return google.Polygon(
      polygonId: google.PolygonId(polygon.id),
      points: polygon.points.toGoogleLatLngList(),
      fillColor: Color.fromARGB(
        (polygon.color.value >> 24) & 0xFF,
        (polygon.color.value >> 16) & 0xFF,
        (polygon.color.value >> 8) & 0xFF,
        polygon.color.value & 0xFF,
      ),
      strokeColor: Color.fromARGB(
        (polygon.borderColor.value >> 24) & 0xFF,
        (polygon.borderColor.value >> 16) & 0xFF,
        (polygon.borderColor.value >> 8) & 0xFF,
        polygon.borderColor.value & 0xFF,
      ),
      strokeWidth: polygon.strokeWidth.toInt(),
      consumeTapEvents: polygon.isInteractive,
      onTap: onTap != null ? () => onTap(polygon.id) : null,
      visible: true,
      geodesic: false,
    );
  }

  /// Builds multiple polygon overlays for flutter_map.
  static List<Polygon<String>> buildFlutterMapList(
    List<GeoPolygonWidget> polygons,
    OnGeofenceTap? onTap,
  ) {
    return polygons.map((polygon) => buildFlutterMap(polygon, onTap)).toList();
  }

  /// Builds multiple polygon overlays for google_maps_flutter.
  static Set<google.Polygon> buildGoogleMapSet(
    List<GeoPolygonWidget> polygons,
    OnGeofenceTap? onTap,
  ) {
    return polygons.map((polygon) => buildGoogleMap(polygon, onTap)).toSet();
  }
}
