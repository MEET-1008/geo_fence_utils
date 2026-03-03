import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/geo_point.dart';
import '../../extensions/geo_point_extensions.dart';
import '../geo_geofence_base.dart';
import '../geo_circle_widget.dart';
import '../geo_polygon_widget.dart';
import '../geo_polyline_widget.dart';
import '../builders/circle_overlay_builder.dart';
import '../builders/polygon_overlay_builder.dart';
import '../builders/polyline_overlay_builder.dart';

/// Flutter Map implementation using flutter_map package (OpenStreetMap).
///
/// This is a free implementation that doesn't require an API key.
/// It uses OpenStreetMap tiles for rendering.
///
/// **Example:**
/// ```dart
/// FlutterMapImpl(
///   center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
///   zoom: 13.0,
///   geofences: [
///     GeoCircleWidget.withRadius(
///       center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
///       radius: 500,
///     ),
///   ],
/// )
/// ```
class FlutterMapImpl extends StatefulWidget {
  /// The center point of the map.
  final GeoPoint center;

  /// Initial zoom level.
  final double zoom;

  /// List of geofences to display.
  final List<GeoGeofenceBase> geofences;

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

  const FlutterMapImpl({
    super.key,
    required this.center,
    required this.zoom,
    required this.geofences,
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
  State<FlutterMapImpl> createState() => _FlutterMapImplState();
}

class _FlutterMapImplState extends State<FlutterMapImpl> {
  late MapController _mapController;
  double _currentZoom = 13.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentZoom = widget.zoom;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _handleMapTap(TapPosition tapPosition, LatLng latLng) {
    if (widget.onMapTap != null) {
      widget.onMapTap!(latLng.toGeoPoint());
    }
  }

  void _handleMapLongPress(TapPosition tapPosition, LatLng latLng) {
    if (widget.onMapLongPress != null) {
      widget.onMapLongPress!(latLng.toGeoPoint());
    }
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(widget.minZoom, widget.maxZoom);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(widget.minZoom, widget.maxZoom);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.center.toFlutterLatLng(),
            initialZoom: widget.zoom,
            minZoom: widget.minZoom,
            maxZoom: widget.maxZoom,
            initialRotation: widget.rotation,
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
            onTap: _handleMapTap,
            onLongPress: _handleMapLongPress,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'geo_fence_utils',
            ),
            PolygonLayer(
              polygons: _buildPolygonOverlays(),
            ),
            PolylineLayer(
              polylines: _buildPolylineOverlays(),
            ),
            CircleLayer(
              circles: _buildCircleOverlays(),
            ),
          ],
        ),
        if (widget.showZoomControls)
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                _ZoomButton(
                  icon: '+',
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: 8),
                _ZoomButton(
                  icon: '-',
                  onPressed: _zoomOut,
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<CircleMarker> _buildCircleOverlays() {
    final circles = <CircleMarker>[];
    for (final geofence in widget.geofences) {
      if (geofence is GeoCircleWidget) {
        circles.add(
          CircleOverlayBuilder.buildFlutterMap(
            geofence,
            widget.onGeofenceTap,
          ),
        );
      }
    }
    return circles;
  }

  List<Polygon<String>> _buildPolygonOverlays() {
    final polygons = <Polygon<String>>[];
    for (final geofence in widget.geofences) {
      if (geofence is GeoPolygonWidget) {
        polygons.add(
          PolygonOverlayBuilder.buildFlutterMap(
            geofence,
            widget.onGeofenceTap,
          ),
        );
      }
    }
    return polygons;
  }

  List<Polyline<String>> _buildPolylineOverlays() {
    final polylines = <Polyline<String>>[];
    for (final geofence in widget.geofences) {
      if (geofence is GeoPolylineWidget) {
        polylines.add(
          PolylineOverlayBuilder.buildFlutterMap(
            geofence,
            widget.onGeofenceTap,
          ),
        );
      }
    }
    return polylines;
  }
}

/// Custom zoom button widget.
class _ZoomButton extends StatelessWidget {
  final String icon;
  final VoidCallback onPressed;

  const _ZoomButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
