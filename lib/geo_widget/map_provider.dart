/// Map provider options for displaying geofences.
///
/// Determines which map SDK will be used to render the map and geofences.
enum MapProvider {
  /// Use flutter_map package (OpenStreetMap).
  ///
  /// This is free and doesn't require an API key.
  /// Uses OpenStreetMap tiles.
  flutterMap,

  /// Use google_maps_flutter package.
  ///
  /// Requires a Google Maps API key.
  /// Provides more features and better styling options.
  googleMap,

  /// Automatically choose based on availability.
  ///
  /// Will use flutter_map if no API key is provided,
  /// otherwise will use google_maps_flutter.
  auto,
}

/// Extension methods for [MapProvider].
extension MapProviderExtension on MapProvider {
  /// Returns the display name for this map provider.
  String get displayName {
    switch (this) {
      case MapProvider.flutterMap:
        return 'OpenStreetMap (flutter_map)';
      case MapProvider.googleMap:
        return 'Google Maps';
      case MapProvider.auto:
        return 'Auto';
    }
  }

  /// Whether this map provider requires an API key.
  bool get requiresApiKey {
    switch (this) {
      case MapProvider.flutterMap:
        return false;
      case MapProvider.googleMap:
        return true;
      case MapProvider.auto:
        return false;
    }
  }

  /// Whether this provider is free to use (no API costs).
  bool get isFree {
    switch (this) {
      case MapProvider.flutterMap:
        return true;
      case MapProvider.googleMap:
        return false;
      case MapProvider.auto:
        return true;
    }
  }

  /// Returns a description of this provider's requirements.
  String get description {
    switch (this) {
      case MapProvider.flutterMap:
        return 'Free OpenStreetMap tiles, no API key required';
      case MapProvider.googleMap:
        return 'Requires Google Maps API key, usage may incur costs';
      case MapProvider.auto:
        return 'Automatically selects best available option';
    }
  }
}
