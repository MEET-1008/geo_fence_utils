import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show CameraPosition, Cap, Circle, CircleId, GoogleMap, JointType, LatLng, MinMaxZoomPreference, MapType, Polygon, PolygonId, Polyline, PolylineId;
import '../../models/geo_point.dart';
import '../../extensions/geo_point_extensions.dart';
import '../geo_geofence_base.dart';
import '../geo_circle_widget.dart';
import '../geo_polygon_widget.dart';
import '../geo_polyline_widget.dart';
import '../builders/circle_overlay_builder.dart';
import '../builders/polygon_overlay_builder.dart';
import '../builders/polyline_overlay_builder.dart';

/// Google Maps implementation using google_maps_flutter package.
///
/// This implementation provides access to Google Maps with all its features.
/// Requires a valid Google Maps API key.
///
/// **Example:**
/// ```dart
/// GoogleMapImpl(
///   center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
///   zoom: 13.0,
///   googleMapsApiKey: 'YOUR_API_KEY',
///   geofences: [
///     GeoCircleWidget.withRadius(
///       center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
///       radius: 500,
///     ),
///   ],
/// )
/// ```
class GoogleMapImpl extends StatefulWidget {
  /// The center point of the map.
  final GeoPoint center;

  /// Initial zoom level.
  final double zoom;

  /// List of geofences to display.
  final List<GeoGeofenceBase> geofences;

  /// Google Maps API key.
  final String googleMapsApiKey;

  /// Callback when a geofence is tapped.
  final OnGeofenceTap? onGeofenceTap;

  /// Callback when the map is tapped.
  final OnMapTap? onMapTap;

  /// Callback when the map is long pressed.
  final OnMapLongPress? onMapLongPress;

  /// Whether to show zoom controls.
  final bool showZoomControls;

  /// Whether to show compass.
  final bool showCompass;

  /// Whether to show "my location" button.
  final bool showMyLocationButton;

  /// Minimum zoom level.
  final double minZoom;

  /// Maximum zoom level.
  final double maxZoom;

  /// Initial map rotation (in degrees).
  final double rotation;

  /// Whether the map can be rotated by user gestures.
  final bool enableRotation;

  /// Whether the map can be zoomed by user gestures.
  final bool enableZoom;

  const GoogleMapImpl({
    super.key,
    required this.center,
    required this.zoom,
    required this.geofences,
    required this.googleMapsApiKey,
    this.onGeofenceTap,
    this.onMapTap,
    this.onMapLongPress,
    this.showZoomControls = true,
    this.showCompass = true,
    this.showMyLocationButton = true,
    this.minZoom = 2.0,
    this.maxZoom = 18.0,
    this.rotation = 0.0,
    this.enableRotation = true,
    this.enableZoom = true,
  });

  @override
  State<GoogleMapImpl> createState() => _GoogleMapImplState();
}

class _GoogleMapImplState extends State<GoogleMapImpl> {
  final Set<Circle> _circles = {};
  final Set<Polygon> _polygons = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _buildOverlays();
  }

  @override
  void didUpdateWidget(GoogleMapImpl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.geofences != widget.geofences) {
      _buildOverlays();
    }
  }

  void _buildOverlays() {
    _circles.clear();
    _polygons.clear();
    _polylines.clear();

    for (final geofence in widget.geofences) {
      if (geofence is GeoCircleWidget) {
        _circles.add(
          CircleOverlayBuilder.buildGoogleMap(
            geofence,
            widget.onGeofenceTap,
          ),
        );
      } else if (geofence is GeoPolygonWidget) {
        _polygons.add(
          PolygonOverlayBuilder.buildGoogleMap(
            geofence,
            widget.onGeofenceTap,
          ),
        );
      } else if (geofence is GeoPolylineWidget) {
        _polylines.add(
          PolylineOverlayBuilder.buildGoogleMap(
            geofence,
            widget.onGeofenceTap,
          ),
        );
      }
    }
  }

  void _handleMapTap(LatLng latLng) {
    if (widget.onMapTap != null) {
      widget.onMapTap!(latLng.toGeoPoint());
    }
  }

  void _handleMapLongPress(LatLng latLng) {
    if (widget.onMapLongPress != null) {
      widget.onMapLongPress!(latLng.toGeoPoint());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.center.toGoogleLatLng(),
        zoom: widget.zoom,
        bearing: widget.rotation,
      ),
      circles: _circles,
      polygons: _polygons,
      polylines: _polylines,
      onTap: _handleMapTap,
      onLongPress: _handleMapLongPress,
      zoomControlsEnabled: widget.showZoomControls,
      compassEnabled: widget.showCompass,
      myLocationButtonEnabled: widget.showMyLocationButton,
      minMaxZoomPreference: MinMaxZoomPreference(widget.minZoom, widget.maxZoom),
      rotateGesturesEnabled: widget.enableRotation,
      zoomGesturesEnabled: widget.enableZoom,
      myLocationEnabled: false,
      mapType: MapType.normal,
      buildingsEnabled: true,
      trafficEnabled: false,
    );
  }
}
