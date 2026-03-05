import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/geo_point.dart';
import '../../models/geo_circle.dart';
import '../../models/geo_polygon.dart';
import '../../services/geo_circle_service.dart';
import '../../services/geo_polygon_service.dart';
import '../../extensions/geo_point_extensions.dart';
import '../geo_geofence_base.dart';
import '../geo_circle_widget.dart';
import '../geo_polygon_widget.dart';
import '../geo_polyline_widget.dart';
import '../geo_marker_widget.dart';
import '../builders/circle_overlay_builder.dart';
import '../builders/polygon_overlay_builder.dart';
import '../builders/polyline_overlay_builder.dart';
import '../../markers/adapters/flutter_map_marker_adapter.dart';
import '../../markers/models/marker_config.dart';
import '../../markers/widgets/marker_info_window.dart';

// Callback type for marker tap
typedef OnMarkerTap = void Function(String markerId);

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

  /// List of markers to display.
  final List<GeoMarkerWidget> markers;

  /// Callback when a geofence is tapped.
  final OnGeofenceTap? onGeofenceTap;

  /// Callback when a marker is tapped.
  final OnMarkerTap? onMarkerTap;

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
    this.markers = const [],
    this.onGeofenceTap,
    this.onMarkerTap,
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
  String? _selectedMarkerId;
  GeoPoint? _selectedMarkerPosition;
  MarkerConfig? _selectedMarkerConfig;
  MapCamera? _currentCamera;

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
    final tappedPoint = latLng.toGeoPoint();

    // Clear info window if tapping elsewhere on the map
    // (but not on a marker - markers handle their own taps)
    if (_selectedMarkerId != null) {
      setState(() {
        _selectedMarkerId = null;
        _selectedMarkerPosition = null;
        _selectedMarkerConfig = null;
      });
    }

    // Check circles
    for (final geofence in widget.geofences) {
      if (geofence is! GeoCircleWidget) continue;
      if (geofence.isInteractive) {
        final circle = GeoCircle(
          center: geofence.center,
          radius: geofence.radius,
        );
        if (GeoCircleService.isInsideCircle(point: tappedPoint, circle: circle)) {
          if (widget.onGeofenceTap != null) {
            widget.onGeofenceTap!(geofence.id);
          }
          return;
        }
      }
    }

    // Check polygons
    for (final geofence in widget.geofences) {
      if (geofence is! GeoPolygonWidget) continue;
      if (geofence.isInteractive) {
        final polygon = GeoPolygon(points: geofence.points);
        if (GeoPolygonService.isInsidePolygon(point: tappedPoint, polygon: polygon)) {
          if (widget.onGeofenceTap != null) {
            widget.onGeofenceTap!(geofence.id);
          }
          return;
        }
      }
    }

    // Check polylines (with threshold distance)
    for (final geofence in widget.geofences) {
      if (geofence is! GeoPolylineWidget) continue;
      if (geofence.isInteractive) {
        if (_isPointNearPolyline(tappedPoint, geofence.points, geofence.width * 2)) {
          if (widget.onGeofenceTap != null) {
            widget.onGeofenceTap!(geofence.id);
          }
          return;
        }
      }
    }

    // If no geofence was tapped, call onMapTap
    if (widget.onMapTap != null) {
      widget.onMapTap!(tappedPoint);
    }
  }

  /// Handle marker tap directly
  void _handleMarkerTap(String markerId) {
    final marker = widget.markers.firstWhere(
      (m) => m.id == markerId,
      orElse: () => throw StateError('Marker not found: $markerId'),
    );

    setState(() {
      _selectedMarkerId = markerId;
      _selectedMarkerPosition = marker.position;
      _selectedMarkerConfig = marker.effectiveConfig;
    });

    if (widget.onMarkerTap != null) {
      widget.onMarkerTap!(markerId);
    }
  }

  bool _isPointNearPolyline(GeoPoint point, List<GeoPoint> polylinePoints, double threshold) {
    for (int i = 0; i < polylinePoints.length - 1; i++) {
      final start = polylinePoints[i];
      final end = polylinePoints[i + 1];
      if (_isPointNearLineSegment(point, start, end, threshold)) {
        return true;
      }
    }
    return false;
  }

  bool _isPointNearLineSegment(GeoPoint point, GeoPoint lineStart, GeoPoint lineEnd, double threshold) {
    final A = point.latitude - lineStart.latitude;
    final B = point.longitude - lineStart.longitude;
    final C = lineEnd.latitude - lineStart.latitude;
    final D = lineEnd.longitude - lineStart.longitude;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;
    var param = -1.0;
    if (lenSq != 0) param = dot / lenSq;

    double xx, yy;

    if (param < 0) {
      xx = lineStart.latitude;
      yy = lineStart.longitude;
    } else if (param > 1) {
      xx = lineEnd.latitude;
      yy = lineEnd.longitude;
    } else {
      xx = lineStart.latitude + param * C;
      yy = lineStart.longitude + param * D;
    }

    final dx = point.latitude - xx;
    final dy = point.longitude - yy;
    final distance = math.sqrt(dx * dx + dy * dy) * 111000; // Approximate to meters

    return distance < threshold;
  }

  void _handleMapLongPress(TapPosition tapPosition, LatLng latLng) {
    if (widget.onMapLongPress != null) {
      widget.onMapLongPress!(latLng.toGeoPoint());
    }
  }

  void _zoomIn() {
    final center = _currentCamera?.center ?? _mapController.camera.center;
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(widget.minZoom, widget.maxZoom);
      _mapController.move(center, _currentZoom);
    });
  }

  void _zoomOut() {
    final center = _currentCamera?.center ?? _mapController.camera.center;
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(widget.minZoom, widget.maxZoom);
      _mapController.move(center, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.center.toFlutterLatLng(),
              initialZoom: widget.zoom,
              minZoom: widget.minZoom,
              maxZoom: widget.maxZoom,
              initialRotation: widget.rotation,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: _handleMapTap,
              onLongPress: _handleMapLongPress,
              onMapEvent: (MapEvent event) {
                // Update camera tracking when map moves/zooms
                if (event is MapEventWithMove) {
                  setState(() {
                    _currentCamera = event.camera;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'geo_fence_utils',
                maxZoom: 18,
                subdomains: const ['a', 'b', 'c'],
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
              // Marker layer
              MarkerLayer(
                markers: _buildMarkerOverlays(),
              ),
            ],
          ),
        ),
        if (widget.showZoomControls)
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                _ZoomIconButton(
                  icon: Icons.add,
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: 8),
                _ZoomIconButton(
                  icon: Icons.remove,
                  onPressed: _zoomOut,
                ),
              ],
            ),
          ),
        // Info window overlay
        if (_selectedMarkerId != null &&
            _selectedMarkerPosition != null &&
            _selectedMarkerConfig != null)
          SizedBox.expand(
            child: _MarkerInfoWindowPositioner(
              markerPosition: _selectedMarkerPosition!,
              markerConfig: _selectedMarkerConfig!,
              mapController: _mapController,
              onClose: () {
                setState(() {
                  _selectedMarkerId = null;
                  _selectedMarkerPosition = null;
                  _selectedMarkerConfig = null;
                });
              },
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

  List<Marker> _buildMarkerOverlays() {
    final markers = <Marker>[];
    final adapter = FlutterMapMarkerAdapter();

    // Add regular markers
    for (final marker in widget.markers) {
      final config = marker.effectiveConfig;
      markers.add(adapter.createMapMarker(
        id: marker.id,
        position: marker.position,
        config: config,
        onTap: marker.isInteractive
            ? () => _handleMarkerTap(marker.id)
            : null,
      ));
    }

    // Add center markers from all geofences
    for (final geofence in widget.geofences) {
      if (geofence.centerMarker != null) {
        final centerMarkerId = '${geofence.id}_center_marker';
        final marker = GeoMarkerWidget(
          id: centerMarkerId,
          position: geofence.markerPosition,
          config: geofence.centerMarker!,
          isInteractive: geofence.isInteractive,
        );

        markers.add(adapter.createMapMarker(
          id: marker.id,
          position: marker.position,
          config: marker.effectiveConfig,
          onTap: geofence.isInteractive
              ? () => _handleGeofenceMarkerTap(geofence.id, centerMarkerId)
              : null,
        ));
      }

      // Add start and end markers for polylines
      if (geofence is GeoPolylineWidget) {
        if (geofence.startMarker != null && geofence.points.isNotEmpty) {
          final startMarkerId = '${geofence.id}_start_marker';
          final marker = GeoMarkerWidget(
            id: startMarkerId,
            position: geofence.points.first,
            config: geofence.startMarker!,
            isInteractive: geofence.isInteractive,
          );

          markers.add(adapter.createMapMarker(
            id: marker.id,
            position: marker.position,
            config: marker.effectiveConfig,
            onTap: geofence.isInteractive
                ? () => _handleGeofenceMarkerTap(geofence.id, startMarkerId)
                : null,
          ));
        }

        if (geofence.endMarker != null && geofence.points.length >= 2) {
          final endMarkerId = '${geofence.id}_end_marker';
          final marker = GeoMarkerWidget(
            id: endMarkerId,
            position: geofence.points.last,
            config: geofence.endMarker!,
            isInteractive: geofence.isInteractive,
          );

          markers.add(adapter.createMapMarker(
            id: marker.id,
            position: marker.position,
            config: marker.effectiveConfig,
            onTap: geofence.isInteractive
                ? () => _handleGeofenceMarkerTap(geofence.id, endMarkerId)
                : null,
          ));
        }
      }
    }

    return markers;
  }

  /// Handle marker tap associated with a geofence
  void _handleGeofenceMarkerTap(String geofenceId, String markerId) {
    setState(() {
      _selectedMarkerId = markerId;
      final geofence = widget.geofences.firstWhere(
        (g) => g.id == geofenceId,
        orElse: () => throw StateError('Geofence not found: $geofenceId'),
      );

      if (markerId == '${geofenceId}_center_marker') {
        _selectedMarkerPosition = geofence.markerPosition;
        _selectedMarkerConfig = geofence.centerMarker;
      } else if (geofence is GeoPolylineWidget) {
        if (markerId == '${geofenceId}_start_marker') {
          _selectedMarkerPosition = geofence.points.first;
          _selectedMarkerConfig = geofence.startMarker;
        } else if (markerId == '${geofenceId}_end_marker') {
          _selectedMarkerPosition = geofence.points.last;
          _selectedMarkerConfig = geofence.endMarker;
        }
      }
    });

    if (widget.onMarkerTap != null) {
      widget.onMarkerTap!(markerId);
    }
  }
}

/// Custom zoom button widget with icon.
class _ZoomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ZoomIconButton({
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
            color: Colors.black.withOpacity(0.2),
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
          child: Icon(
            icon,
            color: const Color(0xFF424242),
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Widget that positions the info window at the correct screen coordinates
class _MarkerInfoWindowPositioner extends StatelessWidget {
  final GeoPoint markerPosition;
  final MarkerConfig markerConfig;
  final MapController mapController;
  final VoidCallback onClose;

  const _MarkerInfoWindowPositioner({
    required this.markerPosition,
    required this.markerConfig,
    required this.mapController,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to get the screen constraints, then position
    // the info window at the correct location using a CustomSingleChildLayout
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get the current camera to convert lat/long to screen coordinates
        final camera = mapController.camera;
        final markerLatLng = LatLng(markerPosition.latitude, markerPosition.longitude);

        // Calculate screen position using the camera's projection
        final screenPoint = _project(camera, markerLatLng, constraints.biggest);

        // Use a Stack to properly position the info window
        return Stack(
          children: [
            Positioned(
              left: screenPoint.dx - 75, // Center horizontally (info window is ~150px wide)
              top: screenPoint.dy - 55, // Position above the marker
              child: MarkerInfoWindow(
                title: markerConfig.label ?? 'Marker',
                snippet: _getMarkerSnippet(),
                onClose: onClose,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Convert LatLng to screen coordinates
  Offset _project(MapCamera camera, LatLng point, Size screenSize) {
    // This is a simplified projection calculation
    // For accurate results, you would use the map's internal projection
    // flutter_map provides the camera's center and zoom level

    final center = camera.center;
    final zoom = camera.zoom;

    // Calculate the offset from center in pixels
    final latDiff = point.latitude - center.latitude;
    final lngDiff = point.longitude - center.longitude;

    // Approximate conversion to pixels (at zoom level 13, 1 degree ~ 100km)
    final pixelsPerDegree = (256 * math.pow(2, zoom)) / 360;
    final x = screenSize.width / 2 + lngDiff * pixelsPerDegree;
    final y = screenSize.height / 2 - latDiff * pixelsPerDegree;

    return Offset(x, y);
  }

  String _getMarkerSnippet() {
    return 'Lat: ${markerPosition.latitude.toStringAsFixed(4)}, '
           'Lng: ${markerPosition.longitude.toStringAsFixed(4)}';
  }
}

