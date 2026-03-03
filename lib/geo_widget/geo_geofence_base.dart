import '../models/geo_point.dart';
import 'package:flutter/painting.dart';

/// Callback type for when a geofence is tapped.
typedef OnGeofenceTap = void Function(String geofenceId);

/// Callback type for when the map is tapped.
typedef OnMapTap = void Function(GeoPoint location);

/// Callback type for when the map is long pressed.
typedef OnMapLongPress = void Function(GeoPoint location);

/// Abstract base class for all map geofence widgets.
///
/// This class provides common properties and methods for all geofence types
/// (circles, polygons, polylines) that can be displayed on maps.
///
/// **Example:**
/// ```dart
/// class MyGeofence extends GeoGeofenceBase {
///   MyGeofence() : super(id: 'my_geofence');
///
///   @override
///   void validate() {
///     // Custom validation logic
///   }
/// }
/// ```
abstract class GeoGeofenceBase {
  /// Unique identifier for this geofence.
  final String id;

  /// Fill color for the geofence area.
  final Color color;

  /// Whether this geofence can be interacted with (tapped).
  final bool isInteractive;

  /// Additional metadata associated with this geofence.
  final Map<String, dynamic> metadata;

  /// Creates a new [GeoGeofenceBase] with the given properties.
  const GeoGeofenceBase({
    required this.id,
    this.color = const Color(0x4D2196F3),
    this.isInteractive = true,
    this.metadata = const {},
  });

  /// Validates this geofence's configuration.
  ///
  /// Throws [StateError] if the configuration is invalid.
  /// Subclasses must implement this method.
  void validate();

  /// Converts this geofence to a map representation.
  ///
  /// Subclasses should override this method to include their specific properties.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'color': color.value,
      'isInteractive': isInteractive,
      'metadata': metadata,
    };
  }
}
