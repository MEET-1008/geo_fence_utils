import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';
import '../models/geo_point.dart';
import 'geo_geofence_base.dart';

/// A marker widget for displaying points of interest on maps.
///
/// Markers are used to indicate specific locations on a map with optional
/// labels, colors, and custom styling.
///
/// **Example:**
/// ```dart
/// // Simple marker
/// GeoMarkerWidget(
///   id: 'my_location',
///   position: GeoPoint(latitude: 37.7749, longitude: -122.4194),
/// )
///
/// // Custom styled marker with label
/// GeoMarkerWidget(
///   id: 'store',
///   position: GeoPoint(latitude: 37.78, longitude: -122.41),
///   label: 'My Store',
///   color: Colors.green,
///   markerSize: 40,
/// )
///
/// // Using preset
/// GeoMarkerWidget.location(
///   id: 'current_location',
///   position: GeoPoint(latitude: 37.7749, longitude: -122.4194),
/// )
/// ```
class GeoMarkerWidget extends GeoGeofenceBase {
  /// The position of the marker on the map.
  final GeoPoint position;

  /// Optional label text to display on the marker.
  final String? label;

  /// Background color of the marker pin.
  final Color markerColor;

  /// Size of the marker in logical pixels.
  final double markerSize;

  /// Width of the marker border/stroke.
  final double strokeWidth;

  /// Color of the marker border.
  final Color strokeColor;

  /// Color of the label text.
  final Color labelColor;

  /// Font size of the label text.
  final double labelFontSize;

  /// Whether to show the label in an info window style (bubble).
  final bool showInfoWindow;

  /// Alpha (opacity) of the marker from 0.0 to 1.0.
  final double alpha;

  /// Optional asset path for a custom marker image.
  final String? assetPath;

  /// Creates a new [GeoMarkerWidget] with the given properties.
  const GeoMarkerWidget({
    required super.id,
    required this.position,
    this.label,
    this.markerColor = const Color(0xFF2196F3),
    this.markerSize = 32.0,
    this.strokeWidth = 2.0,
    this.strokeColor = Colors.white,
    this.labelColor = Colors.white,
    this.labelFontSize = 12.0,
    this.showInfoWindow = false,
    this.alpha = 1.0,
    this.assetPath,
    super.isInteractive = true,
    super.metadata,
  }) : super(color: markerColor);

  /// Creates a preset "location" marker with blue styling.
  factory GeoMarkerWidget.location({
    required String id,
    required GeoPoint position,
    String? label,
    double markerSize = 32.0,
    Map<String, dynamic> metadata = const {},
  }) {
    return GeoMarkerWidget(
      id: id,
      position: position,
      label: label,
      markerColor: const Color(0xFF2196F3),
      markerSize: markerSize,
      metadata: {'type': 'location', ...metadata},
    );
  }

  /// Creates a preset "store" marker with green styling.
  factory GeoMarkerWidget.store({
    required String id,
    required GeoPoint position,
    String? label,
    double markerSize = 36.0,
    Map<String, dynamic> metadata = const {},
  }) {
    return GeoMarkerWidget(
      id: id,
      position: position,
      label: label ?? 'Store',
      markerColor: const Color(0xFF4CAF50),
      markerSize: markerSize,
      metadata: {'type': 'store', ...metadata},
    );
  }

  /// Creates a preset "warning" marker with orange styling.
  factory GeoMarkerWidget.warning({
    required String id,
    required GeoPoint position,
    String? label,
    double markerSize = 32.0,
    Map<String, dynamic> metadata = const {},
  }) {
    return GeoMarkerWidget(
      id: id,
      position: position,
      label: label ?? 'Warning',
      markerColor: const Color(0xFFFF9800),
      markerSize: markerSize,
      metadata: {'type': 'warning', ...metadata},
    );
  }

  /// Creates a preset "danger" marker with red styling.
  factory GeoMarkerWidget.danger({
    required String id,
    required GeoPoint position,
    String? label,
    double markerSize = 36.0,
    Map<String, dynamic> metadata = const {},
  }) {
    return GeoMarkerWidget(
      id: id,
      position: position,
      label: label ?? 'Danger',
      markerColor: const Color(0xFFF44336),
      markerSize: markerSize,
      metadata: {'type': 'danger', ...metadata},
    );
  }

  /// Creates a preset "checkpoint" marker with purple styling.
  factory GeoMarkerWidget.checkpoint({
    required String id,
    required GeoPoint position,
    int? checkpointNumber,
    double markerSize = 32.0,
    Map<String, dynamic> metadata = const {},
  }) {
    return GeoMarkerWidget(
      id: id,
      position: position,
      label: checkpointNumber != null ? 'Checkpoint $checkpointNumber' : 'Checkpoint',
      markerColor: const Color(0xFF9C27B0),
      markerSize: markerSize,
      metadata: {'type': 'checkpoint', 'number': checkpointNumber, ...metadata},
    );
  }

  /// Creates a preset "poi" (Point of Interest) marker with amber styling.
  factory GeoMarkerWidget.poi({
    required String id,
    required GeoPoint position,
    String? label,
    double markerSize = 32.0,
    Map<String, dynamic> metadata = const {},
  }) {
    return GeoMarkerWidget(
      id: id,
      position: position,
      label: label ?? 'POI',
      markerColor: const Color(0xFFFFC107),
      markerSize: markerSize,
      metadata: {'type': 'poi', ...metadata},
    );
  }

  /// Creates a marker at the given position with minimal setup.
  factory GeoMarkerWidget.at({
    required GeoPoint position,
    String? id,
    Color color = const Color(0xFF2196F3),
  }) {
    return GeoMarkerWidget(
      id: id ?? 'marker_${position.latitude}_${position.longitude}',
      position: position,
      markerColor: color,
    );
  }

  @override
  void validate() {
    if (markerSize <= 0) {
      throw StateError('Marker size must be greater than zero');
    }
    if (strokeWidth < 0) {
      throw StateError('Stroke width must be non-negative');
    }
    if (alpha < 0 || alpha > 1) {
      throw StateError('Alpha must be between 0.0 and 1.0');
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'type': 'marker',
      'position': position.toMap(),
      'label': label,
      'markerColor': markerColor.value,
      'markerSize': markerSize,
      'strokeWidth': strokeWidth,
      'strokeColor': strokeColor.value,
      'labelColor': labelColor.value,
      'labelFontSize': labelFontSize,
      'showInfoWindow': showInfoWindow,
      'alpha': alpha,
      'assetPath': assetPath,
    };
  }

  @override
  String toString() =>
      'GeoMarkerWidget(id: $id, position: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}'
      '${label != null ? ', label: $label' : ''})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeoMarkerWidget &&
          id == other.id &&
          position == other.position &&
          label == other.label &&
          markerColor.value == other.markerColor.value &&
          markerSize == other.markerSize &&
          strokeWidth == other.strokeWidth &&
          strokeColor.value == other.strokeColor.value &&
          alpha == other.alpha;

  @override
  int get hashCode =>
      id.hashCode ^
      position.hashCode ^
      label.hashCode ^
      markerColor.value.hashCode ^
      markerSize.hashCode ^
      strokeWidth.hashCode ^
      strokeColor.value.hashCode ^
      alpha.hashCode;
}
