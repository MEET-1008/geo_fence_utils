import 'package:flutter/widgets.dart';
import '../models/geo_point.dart';
import 'geo_geofence_base.dart';
import 'geo_circle_widget.dart';
import 'geo_polygon_widget.dart';
import 'geo_polyline_widget.dart';
import 'map_provider.dart';
import 'implementations/flutter_map_impl.dart';
import 'implementations/google_map_impl.dart';

/// Main map widget for displaying geofences.
///
/// This widget provides a declarative way to display geofences on maps
/// without complex setup. It automatically delegates to the appropriate
/// map implementation based on the [provider] parameter.
///
/// **Example:**
/// ```dart
/// // Simple circle
/// GeoGeofenceMap(
///   center: GeoPoint(lat: 37.7749, lng: -122.4194),
///   geofences: [
///     GeoCircleWidget.withRadius(
///       center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
///       radius: 500,
///     ),
///   ],
/// )
///
/// // Multiple geofences with styling
/// GeoGeofenceMap(
///   center: GeoPoint(lat: 37.7749, lng: -122.4194),
///   geofences: [
///     GeoCircleWidget.dangerZone(
///       center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
///       radius: 1000,
///     ),
///     GeoCircleWidget.safeZone(
///       center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
///       radius: 500,
///     ),
///     GeoPolygonWidget.fromBounds(
///       north: 37.78,
///       south: 37.76,
///       east: -122.40,
///       west: -122.42,
///     ),
///   ],
///   provider: MapProvider.flutterMap,
///   showZoomControls: true,
///   showCompass: true,
/// )
/// ```
class GeoGeofenceMap extends StatelessWidget {
  /// The center point of the map.
  final GeoPoint center;

  /// Initial zoom level (typically 2.0 to 18.0).
  final double zoom;

  /// List of geofences to display on the map.
  final List<GeoGeofenceBase> geofences;

  /// Map provider to use for rendering.
  final MapProvider provider;

  /// Google Maps API key (required when using [MapProvider.googleMap]).
  final String? googleMapsApiKey;

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

  /// Initial map rotation (in degrees, clockwise from north).
  final double rotation;

  /// Whether the map can be rotated by user gestures.
  final bool enableRotation;

  /// Whether the map can be zoomed by user gestures.
  final bool enableZoom;

  /// Creates a new [GeoGeofenceMap] widget.
  const GeoGeofenceMap({
    super.key,
    required this.center,
    this.zoom = 13.0,
    this.geofences = const [],
    this.provider = MapProvider.auto,
    this.googleMapsApiKey,
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
  Widget build(BuildContext context) {
    // Validate provider and API key
    final effectiveProvider = _getEffectiveProvider();

    if (effectiveProvider == MapProvider.googleMap) {
      if (googleMapsApiKey == null || googleMapsApiKey!.isEmpty) {
        return const _ErrorWidget(
          message: 'Google Maps API key is required when using MapProvider.googleMap',
        );
      }
    }

    // Delegate to appropriate implementation
    switch (effectiveProvider) {
      case MapProvider.flutterMap:
        return FlutterMapImpl(
          center: center,
          zoom: zoom,
          geofences: geofences,
          onGeofenceTap: onGeofenceTap,
          onMapTap: onMapTap,
          onMapLongPress: onMapLongPress,
          showZoomControls: showZoomControls,
          showCompass: showCompass,
          showMyLocationButton: showMyLocationButton,
          minZoom: minZoom,
          maxZoom: maxZoom,
          rotation: rotation,
          enableRotation: enableRotation,
          enableZoom: enableZoom,
        );

      case MapProvider.googleMap:
        return GoogleMapImpl(
          center: center,
          zoom: zoom,
          geofences: geofences,
          googleMapsApiKey: googleMapsApiKey!,
          onGeofenceTap: onGeofenceTap,
          onMapTap: onMapTap,
          onMapLongPress: onMapLongPress,
          showZoomControls: showZoomControls,
          showCompass: showCompass,
          showMyLocationButton: showMyLocationButton,
          minZoom: minZoom,
          maxZoom: maxZoom,
          rotation: rotation,
          enableRotation: enableRotation,
          enableZoom: enableZoom,
        );

      case MapProvider.auto:
        // Auto mode - choose flutter_map if no API key
        if (googleMapsApiKey == null || googleMapsApiKey!.isEmpty) {
          return FlutterMapImpl(
            center: center,
            zoom: zoom,
            geofences: geofences,
            onGeofenceTap: onGeofenceTap,
            onMapTap: onMapTap,
            onMapLongPress: onMapLongPress,
            showZoomControls: showZoomControls,
            showCompass: showCompass,
            showMyLocationButton: showMyLocationButton,
            minZoom: minZoom,
            maxZoom: maxZoom,
            rotation: rotation,
            enableRotation: enableRotation,
            enableZoom: enableZoom,
          );
        }
        return GoogleMapImpl(
          center: center,
          zoom: zoom,
          geofences: geofences,
          googleMapsApiKey: googleMapsApiKey!,
          onGeofenceTap: onGeofenceTap,
          onMapTap: onMapTap,
          onMapLongPress: onMapLongPress,
          showZoomControls: showZoomControls,
          showCompass: showCompass,
          showMyLocationButton: showMyLocationButton,
          minZoom: minZoom,
          maxZoom: maxZoom,
          rotation: rotation,
          enableRotation: enableRotation,
          enableZoom: enableZoom,
        );
    }
  }

  /// Returns the effective map provider to use.
  MapProvider _getEffectiveProvider() {
    if (provider == MapProvider.auto) {
      return (googleMapsApiKey != null && googleMapsApiKey!.isNotEmpty)
          ? MapProvider.googleMap
          : MapProvider.flutterMap;
    }
    return provider;
  }
}

/// Error widget for displaying configuration issues.
class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFEBEE),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '⚠️ Map Configuration Error',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD32F2F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFD32F2F),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
