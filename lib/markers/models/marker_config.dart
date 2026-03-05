import 'package:flutter/material.dart';
import 'marker_type.dart';

/// Configuration for marker appearance and behavior
class MarkerConfig {
  /// The visual style of the marker
  final MarkerType type;

  /// Primary color of the marker (for SVG)
  final Color color;

  /// Size of the marker in logical pixels
  final double size;

  /// Whether to render a shadow below the marker
  final bool enableShadow;

  /// Custom SVG path data (required when type is svgCustom)
  /// Format: Standard SVG path string (e.g., "M10,10 L20,20...")
  final String? svgPath;

  /// PNG asset path (required when type is pngAsset)
  /// Format: Asset path (e.g., "assets/images/marker.png")
  final String? pngAssetPath;

  /// Border/Stroke color (for SVG)
  final Color borderColor;

  /// Border/Stroke width (for SVG)
  final double borderWidth;

  /// Opacity of the marker (0.0 to 1.0)
  final double opacity;

  /// Rotation angle in degrees (0 is pointing up)
  final double rotation;

  /// Z-index for layering (higher = drawn on top)
  final int zIndex;

  /// Optional label text to display
  final String? label;

  /// Label text color
  final Color labelColor;

  /// Label font size
  final double labelFontSize;

  /// Label background color (null for transparent)
  final Color? labelBackgroundColor;

  /// Horizontal anchor (0.0=left, 0.5=center, 1.0=right)
  final double anchorX;

  /// Vertical anchor (0.0=top, 0.5=center, 1.0=bottom)
  final double anchorY;

  const MarkerConfig({
    required this.type,
    this.color = Colors.blue,
    this.size = 30.0,
    this.enableShadow = true,
    this.svgPath,
    this.pngAssetPath,
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
    this.opacity = 1.0,
    this.rotation = 0.0,
    this.zIndex = 0,
    this.label,
    this.labelColor = Colors.white,
    this.labelFontSize = 12.0,
    this.labelBackgroundColor,
    this.anchorX = 0.5,
    this.anchorY = 1.0,
  });

  /// Creates a copy with modified fields
  MarkerConfig copyWith({
    MarkerType? type,
    Color? color,
    double? size,
    bool? enableShadow,
    String? svgPath,
    String? pngAssetPath,
    Color? borderColor,
    double? borderWidth,
    double? opacity,
    double? rotation,
    int? zIndex,
    String? label,
    Color? labelColor,
    double? labelFontSize,
    Color? labelBackgroundColor,
    double? anchorX,
    double? anchorY,
  }) {
    return MarkerConfig(
      type: type ?? this.type,
      color: color ?? this.color,
      size: size ?? this.size,
      enableShadow: enableShadow ?? this.enableShadow,
      svgPath: svgPath ?? this.svgPath,
      pngAssetPath: pngAssetPath ?? this.pngAssetPath,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      opacity: opacity ?? this.opacity,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
      label: label ?? this.label,
      labelColor: labelColor ?? this.labelColor,
      labelFontSize: labelFontSize ?? this.labelFontSize,
      labelBackgroundColor: labelBackgroundColor ?? this.labelBackgroundColor,
      anchorX: anchorX ?? this.anchorX,
      anchorY: anchorY ?? this.anchorY,
    );
  }

  /// Validates the configuration
  void validate() {
    if (type == MarkerType.svgCustom && svgPath == null) {
      throw ArgumentError('svgPath must be provided when type is svgCustom');
    }
    if (type == MarkerType.pngAsset && pngAssetPath == null) {
      throw ArgumentError('pngAssetPath must be provided when type is pngAsset');
    }
    if (size <= 0) {
      throw ArgumentError('size must be greater than 0');
    }
    if (opacity < 0 || opacity > 1) {
      throw ArgumentError('opacity must be between 0.0 and 1.0');
    }
    if (borderWidth < 0) {
      throw ArgumentError('borderWidth must be non-negative');
    }
  }

  /// Generates a unique cache key for this configuration
  String get cacheKey {
    return '${type.name}_${color.value}_${size}_$enableShadow${svgPath?.hashCode ?? 0}${pngAssetPath?.hashCode ?? 0}_${rotation}_${anchorX}_${anchorY}_$opacity';
  }

  /// Converts the configuration to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'color': color.value,
      'size': size,
      'enableShadow': enableShadow,
      'svgPath': svgPath,
      'pngAssetPath': pngAssetPath,
      'borderColor': borderColor.value,
      'borderWidth': borderWidth,
      'opacity': opacity,
      'rotation': rotation,
      'zIndex': zIndex,
      'label': label,
      'labelColor': labelColor.value,
      'labelFontSize': labelFontSize,
      'labelBackgroundColor': labelBackgroundColor?.value,
      'anchorX': anchorX,
      'anchorY': anchorY,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkerConfig &&
          type == other.type &&
          color.value == other.color.value &&
          size == other.size &&
          enableShadow == other.enableShadow &&
          svgPath == other.svgPath &&
          pngAssetPath == other.pngAssetPath &&
          borderColor.value == other.borderColor.value &&
          borderWidth == other.borderWidth &&
          rotation == other.rotation &&
          anchorX == other.anchorX &&
          anchorY == other.anchorY &&
          opacity == other.opacity;

  @override
  int get hashCode =>
      type.hashCode ^
      color.value.hashCode ^
      size.hashCode ^
      enableShadow.hashCode ^
      (svgPath?.hashCode ?? 0) ^
      (pngAssetPath?.hashCode ?? 0) ^
      borderColor.value.hashCode ^
      borderWidth.hashCode ^
      rotation.hashCode ^
      anchorX.hashCode ^
      anchorY.hashCode ^
      opacity.hashCode;
}
