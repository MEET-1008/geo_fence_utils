import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../geo_widget/map_provider.dart';
import '../models/marker_config.dart';
import '../adapters/base_marker_adapter.dart';
import '../adapters/flutter_map_marker_adapter.dart';
import '../adapters/google_map_marker_adapter.dart';
import '../cache/marker_cache_manager.dart';

/// Factory for creating markers with the appropriate adapter
class MarkerFactory {
  static final _flutterAdapter = FlutterMapMarkerAdapter();
  static final _googleAdapter = GoogleMapMarkerAdapter();

  /// Get the appropriate adapter for the map provider
  static BaseMarkerAdapter getAdapter(MapProvider provider) {
    switch (provider) {
      case MapProvider.flutterMap:
        return _flutterAdapter;
      case MapProvider.googleMap:
        return _googleAdapter;
      case MapProvider.auto:
        return _flutterAdapter; // Default to FlutterMap
    }
  }

  /// Create a marker widget with the given configuration
  static Widget createWidget(
    MarkerConfig config, {
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return _flutterAdapter.buildMarker(
      config,
      onTap: onTap,
      isSelected: isSelected,
    );
  }

  /// Create a marker with label
  static Widget createWidgetWithLabel(
    MarkerConfig config, {
    VoidCallback? onTap,
    Offset labelOffset = const Offset(0, 8),
  }) {
    return _flutterAdapter.buildMarkerWithLabel(
      config,
      onTap: onTap,
      labelOffset: labelOffset,
    );
  }

  /// Create a BitmapDescriptor for Google Maps
  static Future<BitmapDescriptor> createBitmapDescriptor(
    MarkerConfig config,
  ) async {
    return _googleAdapter.buildBitmapDescriptor(config);
  }

  /// Batch create multiple bitmap descriptors
  static Future<List<BitmapDescriptor>> createBitmapDescriptors(
    List<MarkerConfig> configs,
  ) async {
    final futures = configs.map((config) => createBitmapDescriptor(config));
    return Future.wait(futures);
  }

  /// Preload marker bitmaps for better performance
  static Future<void> preloadMarkers(List<MarkerConfig> configs) async {
    await createBitmapDescriptors(configs);
  }

  /// Clear all cached markers
  static void clearCache() {
    MarkerCacheManager.clear();
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return MarkerCacheManager.getStats();
  }
}
