import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart' show CircleMarker;
import 'package:google_maps_flutter/google_maps_flutter.dart' show Circle, CircleId;
import '../../extensions/geo_point_extensions.dart';
import '../geo_circle_widget.dart';
import '../geo_geofence_base.dart';

/// Builder for creating circle overlays on different map implementations.
///
/// This class provides static methods to build circle overlays for both
/// flutter_map and google_maps_flutter packages.
class CircleOverlayBuilder {
  CircleOverlayBuilder._();

  /// Builds a circle overlay for flutter_map.
  ///
  /// [circle] - The circle widget to render
  /// [onTap] - Optional callback when the circle is tapped
  ///
  /// **Example:**
  /// ```dart
  /// final circle = GeoCircleWidget.withRadius(
  ///   center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  ///   radius: 500,
  /// );
  /// final overlay = CircleOverlayBuilder.buildFlutterMap(circle, (id) {
  ///   print('Tapped circle: $id');
  /// });
  /// ```
  static CircleMarker buildFlutterMap(
    GeoCircleWidget circle,
    OnGeofenceTap? onTap,
  ) {
    return CircleMarker(
      point: circle.center.toFlutterLatLng(),
      radius: circle.radius,
      useRadiusInMeter: true,
      color: Color.fromRGBO(
        (circle.color.value >> 16) & 0xFF,
        (circle.color.value >> 8) & 0xFF,
        circle.color.value & 0xFF,
        ((circle.color.value >> 24) & 0xFF) / 255.0,
      ),
      borderColor: Color.fromRGBO(
        (circle.borderColor.value >> 16) & 0xFF,
        (circle.borderColor.value >> 8) & 0xFF,
        circle.borderColor.value & 0xFF,
        ((circle.borderColor.value >> 24) & 0xFF) / 255.0,
      ),
      borderStrokeWidth: circle.strokeWidth,
    );
  }

  /// Builds a circle overlay for google_maps_flutter.
  ///
  /// [circle] - The circle widget to render
  /// [onTap] - Optional callback when the circle is tapped
  ///
  /// **Example:**
  /// ```dart
  /// final circle = GeoCircleWidget.withRadius(
  ///   center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  ///   radius: 500,
  /// );
  /// final overlay = CircleOverlayBuilder.buildGoogleMap(circle, (id) {
  ///   print('Tapped circle: $id');
  /// });
  /// ```
  static Circle buildGoogleMap(
    GeoCircleWidget circle,
    OnGeofenceTap? onTap,
  ) {
    return Circle(
      circleId: CircleId(circle.id),
      center: circle.center.toGoogleLatLng(),
      radius: circle.radius,
      fillColor: Color.fromARGB(
        (circle.color.value >> 24) & 0xFF,
        (circle.color.value >> 16) & 0xFF,
        (circle.color.value >> 8) & 0xFF,
        circle.color.value & 0xFF,
      ),
      strokeColor: Color.fromARGB(
        (circle.borderColor.value >> 24) & 0xFF,
        (circle.borderColor.value >> 16) & 0xFF,
        (circle.borderColor.value >> 8) & 0xFF,
        circle.borderColor.value & 0xFF,
      ),
      strokeWidth: circle.strokeWidth.toInt(),
      consumeTapEvents: circle.isInteractive,
      onTap: onTap != null ? () => onTap(circle.id) : null,
      visible: true,
    );
  }

  /// Builds multiple circle overlays for flutter_map.
  static List<CircleMarker> buildFlutterMapList(
    List<GeoCircleWidget> circles,
    OnGeofenceTap? onTap,
  ) {
    return circles.map((circle) => buildFlutterMap(circle, onTap)).toList();
  }

  /// Builds multiple circle overlays for google_maps_flutter.
  static Set<Circle> buildGoogleMapSet(
    List<GeoCircleWidget> circles,
    OnGeofenceTap? onTap,
  ) {
    return circles.map((circle) => buildGoogleMap(circle, onTap)).toSet();
  }
}
