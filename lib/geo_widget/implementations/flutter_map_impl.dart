import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/geo_point.dart';
import '../../models/geo_circle.dart';
import '../../models/geo_polygon.dart';
import '../../services/geo_distance_service.dart';
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

    // Check markers first (they have priority)
    const markerTapThreshold = 0.001; // Approx 100m threshold for marker tap
    for (final marker in widget.markers) {
      if (marker.isInteractive) {
        final distance = GeoDistanceService.calculateDistance(
          tappedPoint,
          marker.position,
        );
        if (distance < markerTapThreshold) {
          if (widget.onMarkerTap != null) {
            widget.onMarkerTap!(marker.id);
          }
          return;
        }
      }
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

    // If no geofence or marker was tapped, call onMapTap
    if (widget.onMapTap != null) {
      widget.onMapTap!(tappedPoint);
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
    for (final marker in widget.markers) {
      markers.add(_buildMarker(marker));
    }
    return markers;
  }

  Marker _buildMarker(GeoMarkerWidget marker) {
    // Build marker widget with pin shape
    return Marker(
      point: marker.position.toFlutterLatLng(),
      width: marker.markerSize + 20, // Extra space for label
      height: marker.markerSize + 20,
      child: GestureDetector(
        onTap: marker.isInteractive && widget.onMarkerTap != null
            ? () => widget.onMarkerTap!(marker.id)
            : null,
        child: Opacity(
          opacity: marker.alpha,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label (if present)
              if (marker.label != null && marker.label!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: marker.showInfoWindow
                        ? Colors.white
                        : marker.markerColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: marker.strokeColor, width: 1),
                  ),
                  child: Text(
                    marker.label!,
                    style: TextStyle(
                      color: marker.showInfoWindow ? Colors.black : marker.labelColor,
                      fontSize: marker.labelFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              // Marker pin
              CustomPaint(
                size: Size(marker.markerSize, marker.markerSize),
                painter: _MarkerPainter(
                  color: marker.markerColor,
                  strokeColor: marker.strokeColor,
                  strokeWidth: marker.strokeWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

/// Custom painter for drawing map markers.
class _MarkerPainter extends CustomPainter {
  final Color color;
  final Color strokeColor;
  final double strokeWidth;

  const _MarkerPainter({
    required this.color,
    required this.strokeColor,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw pin shape (teardrop)
    final path = ui.Path();

    // Outer circle of the pin
    path.addOval(Rect.fromCircle(
      center: Offset(center.dx, center.dy - radius * 0.2),
      radius: radius * 0.5,
    ));

    // Pointy bottom
    path.moveTo(center.dx - radius * 0.5, center.dy - radius * 0.2);
    path.lineTo(center.dx, size.height);
    path.lineTo(center.dx + radius * 0.5, center.dy - radius * 0.2);
    path.close();

    // Fill with marker color
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Draw white center circle
    final innerCirclePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.2),
      radius * 0.2,
      innerCirclePaint,
    );

    // Draw border
    final borderPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _MarkerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
