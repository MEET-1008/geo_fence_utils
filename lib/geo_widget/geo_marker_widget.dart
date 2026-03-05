import 'package:flutter/material.dart';
import '../models/geo_point.dart';
import '../markers/models/marker_config.dart';
import '../markers/models/marker_type.dart';
import 'geo_geofence_base.dart';

/// Enhanced marker widget with configurable styles
///
/// Supports PNG and SVG marker types for maximum flexibility.
///
/// **Example:**
/// ```dart
/// // SVG Marker
/// GeoMarkerWidget.svgPath(
///   id: 'marker1',
///   position: GeoPoint(latitude: 37.7749, longitude: -122.4194),
///   svgPath: 'M25,2 L32,18 L49,18 L35,29 L40,46 L25,36 L10,46 L15,29 L1,18 L18,18 Z',
///   color: Colors.amber,
///   label: 'Star Marker',
/// )
///
/// // PNG Marker (add asset to pubspec.yaml first)
/// GeoMarkerWidget.pngAsset(
///   id: 'marker2',
///   position: GeoPoint(latitude: 37.78, longitude: -122.41),
///   pngAssetPath: 'assets/markers/pin.png',
///   label: 'Custom Pin',
/// )
///
/// // Using custom configuration
/// GeoMarkerWidget.withConfig(
///   id: 'marker3',
///   position: GeoPoint(latitude: 37.76, longitude: -122.42),
///   config: MarkerConfig(
///     type: MarkerType.svgCustom,
///     color: Colors.purple,
///     size: 48.0,
///     svgPath: 'M16,2 L8,10 L2,10 L8,16 L8,28 L12,28 L12,18 L16,18 L16,28 L20,28 L20,16 L26,10 L20,10 Z',
///     label: 'Custom SVG',
///   ),
/// )
/// ```
class GeoMarkerWidget extends GeoGeofenceBase {
  /// The position of the marker on the map
  final GeoPoint position;

  /// NEW: Marker configuration with full customization
  final MarkerConfig? config;

  // Legacy properties (for backward compatibility)
  /// Optional label text to display on the marker
  final String? label;

  /// Background color of the marker pin
  final Color markerColor;

  /// Size of the marker in logical pixels
  final double markerSize;

  /// Width of the marker border/stroke
  final double strokeWidth;

  /// Color of the marker border
  final Color strokeColor;

  /// Color of the label text
  final Color labelColor;

  /// Font size of the label text
  final double labelFontSize;

  /// Whether to show the label in an info window style (bubble)
  final bool showInfoWindow;

  /// Alpha (opacity) of the marker from 0.0 to 1.0
  final double alpha;

  /// Optional asset path for a custom PNG marker image
  final String? assetPath;

  /// Creates a new [GeoMarkerWidget] with the given properties
  const GeoMarkerWidget({
    required super.id,
    required this.position,
    this.config,
    this.label,
    this.markerColor = const Color(0xFF2196F3),
    this.markerSize = 30.0,
    this.strokeWidth = 2.0,
    this.strokeColor = Colors.white,
    this.labelColor = Colors.white,
    this.labelFontSize = 12.0,
    this.showInfoWindow = false,
    this.alpha = 1.0,
    this.assetPath,
    super.isInteractive = true,
    super.metadata,
  })  : super(color: markerColor);

  /// Creates a marker with full configuration
  factory GeoMarkerWidget.withConfig({
    required String id,
    required GeoPoint position,
    required MarkerConfig config,
    bool isInteractive = true,
    Map<String, dynamic> metadata = const {},
  }) {
    return GeoMarkerWidget(
      id: id,
      position: position,
      config: config,
      markerColor: config.color,
      markerSize: config.size,
      label: config.label,
      strokeColor: config.borderColor,
      strokeWidth: config.borderWidth,
      labelColor: config.labelColor,
      labelFontSize: config.labelFontSize,
      alpha: config.opacity,
      metadata: {...metadata, 'markerType': config.type.name},
      isInteractive: isInteractive,
    );
  }

  /// Creates a marker at the given position with minimal setup
  factory GeoMarkerWidget.at({
    required GeoPoint position,
    String? id,
    Color color = const Color(0xFF2196F3),
  }) {
    return GeoMarkerWidget(
      id: id ?? 'marker_${position.latitude}_${position.longitude}',
      position: position,
      markerColor: color,
      markerSize: 30.0,
    );
  }

  /// Creates a custom SVG path marker
  factory GeoMarkerWidget.svgPath({
    required String id,
    required GeoPoint position,
    required String svgPath,
    Color color = const Color(0xFF2196F3),
    double markerSize = 30.0,
    String? label,
    double anchorX = 0.5,
    double anchorY = 0.5,
    Map<String, dynamic> metadata = const {},
  }) {
    return GeoMarkerWidget.withConfig(
      id: id,
      position: position,
      config: MarkerConfig(
        type: MarkerType.svgCustom,
        color: color,
        size: markerSize,
        svgPath: svgPath,
        label: label,
        anchorX: anchorX,
        anchorY: anchorY,
      ),
      metadata: {'type': 'svgCustom', ...metadata},
    );
  }

  /// Creates a PNG asset marker
  ///
  /// [pngAssetPath] is the asset path (e.g., "assets/markers/pin.png")
  /// Make sure to add the asset to your pubspec.yaml:
  /// ```yaml
  /// flutter:
  ///   assets:
  ///     - assets/markers/
  /// ```
  factory GeoMarkerWidget.pngAsset({
    required String id,
    required GeoPoint position,
    required String pngAssetPath,
    double markerSize = 30.0,
    String? label,
    Color borderColor = Colors.transparent,
    double borderWidth = 0.0,
    double anchorX = 0.5,
    double anchorY = 0.5,
    Map<String, dynamic> metadata = const {},
  }) {
    return GeoMarkerWidget.withConfig(
      id: id,
      position: position,
      config: MarkerConfig(
        type: MarkerType.pngAsset,
        color: Colors.transparent,
        size: markerSize,
        pngAssetPath: pngAssetPath,
        label: label,
        borderColor: borderColor,
        borderWidth: borderWidth,
        anchorX: anchorX,
        anchorY: anchorY,
      ),
      metadata: {'type': 'pngAsset', 'assetPath': pngAssetPath, ...metadata},
    );
  }

  @override
  GeoPoint get markerPosition => position;

  @override
  void validate() {
    config?.validate();

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

  /// Gets the effective marker configuration
  /// Returns config if provided, otherwise creates one from legacy properties
  MarkerConfig get effectiveConfig {
    return config ??
        MarkerConfig(
          type: MarkerType.svgCustom,
          color: markerColor,
          size: markerSize,
          label: label,
          borderColor: strokeColor,
          borderWidth: strokeWidth,
          labelColor: labelColor,
          labelFontSize: labelFontSize,
          opacity: alpha,
          svgPath: 'M16,2 L8,10 L2,10 L8,16 L8,28 L12,28 L12,18 L16,18 L16,28 L20,28 L20,16 L26,10 L20,10 Z', // Default pin icon
        );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'type': 'marker',
      'position': position.toMap(),
      'config': config?.toMap(),
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
      'markerType': config?.type.name,
    };
  }

  @override
  String toString() =>
      'GeoMarkerWidget(id: $id, position: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}'
      '${label != null ? ', label: $label' : ''}'
      '${config != null ? ', type: ${config?.type.name}' : ''})';

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
          alpha == other.alpha &&
          config == other.config;

  @override
  int get hashCode =>
      id.hashCode ^
      position.hashCode ^
      label.hashCode ^
      markerColor.value.hashCode ^
      markerSize.hashCode ^
      strokeWidth.hashCode ^
      strokeColor.value.hashCode ^
      alpha.hashCode ^
      config.hashCode;
}
