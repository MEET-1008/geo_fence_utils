# Marker System Implementation Plan

## Overview

A production-ready, customizable marker system that works consistently across both Flutter Map and Google Maps providers with support for 6 predefined marker styles, custom SVG paths, caching, and performance optimization.

---

## 1. Folder Structure

```
lib/
├── markers/
│   ├── models/
│   │   ├── marker_type.dart           # Enum defining marker styles
│   │   ├── marker_config.dart         # Configuration data class
│   │   └── marker_position.dart       # Position with offset support
│   ├── adapters/
│   │   ├── base_marker_adapter.dart   # Abstract interface
│   │   ├── google_map_marker_adapter.dart
│   │   └── flutter_map_marker_adapter.dart
│   ├── factory/
│   │   └── marker_factory.dart       # Factory for creating markers
│   ├── cache/
│   │   ├── marker_cache_manager.dart # LRU cache for bitmaps/widgets
│   │   └── cache_key.dart            # Cache key generation
│   ├── painters/
│   │   ├── marker_painter.dart       # CustomPainter for markers
│   │   ├── classic_pin_painter.dart
│   │   ├── modern_flat_painter.dart
│   │   ├── circular_avatar_painter.dart
│   │   ├── minimal_dot_painter.dart
│   │   └── svg_marker_painter.dart   # SVG path rendering
│   ├── widgets/
│   │   ├── marker_widget.dart        # Unified marker widget
│   │   └── marker_label.dart         # Label widget for markers
│   └── markers.dart                  # Barrel export file
└── geo_widget/
    ├── geo_marker_widget.dart        # Updated to use new system
    └── implementations/
        ├── flutter_map_impl.dart     # Updated marker rendering
        └── google_map_impl.dart      # Updated marker rendering
```

---

## 2. Core Models

### 2.1 MarkerType Enum

**File:** `lib/markers/models/marker_type.dart`

```dart
/// Defines the visual style of map markers
enum MarkerType {
  /// Default teardrop-shaped pin (Google Maps style)
  defaultPin,

  /// Classic map pin with wider head and sharp point
  classicPin,

  /// Modern flat design with rounded corners
  modernFlat,

  /// Circular marker with optional content inside
  circularAvatar,

  /// Minimal dot for subtle location indicators
  minimalDot,

  /// Custom marker rendered from SVG path
  svgCustom,
}

extension MarkerTypeExtension on MarkerType {
  bool get isSvgBased => this == MarkerType.svgCustom;
  bool get hasShadow => this != MarkerType.minimalDot;
  String get displayName {
    switch (this) {
      case MarkerType.defaultPin: return 'Default Pin';
      case MarkerType.classicPin: return 'Classic Pin';
      case MarkerType.modernFlat: return 'Modern Flat';
      case MarkerType.circularAvatar: return 'Circular Avatar';
      case MarkerType.minimalDot: return 'Minimal Dot';
      case MarkerType.svgCustom: return 'SVG Custom';
    }
  }
}
```

### 2.2 MarkerConfig Model

**File:** `lib/markers/models/marker_config.dart`

```dart
import 'package:flutter/material.dart';
import 'marker_type.dart';

/// Configuration for marker appearance and behavior
class MarkerConfig {
  /// The visual style of the marker
  final MarkerType type;

  /// Primary color of the marker
  final Color color;

  /// Size of the marker in logical pixels
  final double size;

  /// Whether to render a shadow below the marker
  final bool enableShadow;

  /// Custom SVG path data (required when type is svgCustom)
  /// Format: Standard SVG path string (e.g., "M10,10 L20,20...")
  final String? svgPath;

  /// Optional custom widget to display inside the marker
  /// Used with circularAvatar type
  final Widget? customWidget;

  /// Optional label text to display
  final String? label;

  /// Label text color
  final Color labelColor;

  /// Label font size
  final double labelFontSize;

  /// Label background color (null for transparent)
  final Color? labelBackgroundColor;

  /// Border/Stroke color
  final Color borderColor;

  /// Border/Stroke width
  final double borderWidth;

  /// Opacity of the marker (0.0 to 1.0)
  final double opacity;

  /// Rotation angle in degrees (0 is pointing up)
  final double rotation;

  /// Z-index for layering (higher = drawn on top)
  final int zIndex;

  const MarkerConfig({
    required this.type,
    required this.color,
    this.size = 40.0,
    this.enableShadow = true,
    this.svgPath,
    this.customWidget,
    this.label,
    this.labelColor = Colors.white,
    this.labelFontSize = 12.0,
    this.labelBackgroundColor,
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
    this.opacity = 1.0,
    this.rotation = 0.0,
    this.zIndex = 0,
  });

  /// Creates a copy with modified fields
  MarkerConfig copyWith({
    MarkerType? type,
    Color? color,
    double? size,
    bool? enableShadow,
    String? svgPath,
    Widget? customWidget,
    String? label,
    Color? labelColor,
    double? labelFontSize,
    Color? labelBackgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? opacity,
    double? rotation,
    int? zIndex,
  }) {
    return MarkerConfig(
      type: type ?? this.type,
      color: color ?? this.color,
      size: size ?? this.size,
      enableShadow: enableShadow ?? this.enableShadow,
      svgPath: svgPath ?? this.svgPath,
      customWidget: customWidget ?? this.customWidget,
      label: label ?? this.label,
      labelColor: labelColor ?? this.labelColor,
      labelFontSize: labelFontSize ?? this.labelFontSize,
      labelBackgroundColor: labelBackgroundColor ?? this.labelBackgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      opacity: opacity ?? this.opacity,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
    );
  }

  /// Validates the configuration
  void validate() {
    if (type == MarkerType.svgCustom && svgPath == null) {
      throw ArgumentError('svgPath must be provided when type is svgCustom');
    }
    if (size <= 0) {
      throw ArgumentError('size must be greater than 0');
    }
    if (opacity < 0 || opacity > 1) {
      throw ArgumentError('opacity must be between 0.0 and 1.0');
    }
  }

  /// Generates a unique cache key for this configuration
  String get cacheKey {
    return '${type.name}_${color.value}_${size}_$enableShadow_${svgPath?.hashCode ?? 0}_$rotation';
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
          rotation == other.rotation &&
          opacity == other.opacity;

  @override
  int get hashCode =>
      type.hashCode ^
      color.value.hashCode ^
      size.hashCode ^
      enableShadow.hashCode ^
      svgPath.hashCode ^
      rotation.hashCode ^
      opacity.hashCode;
}
```

### 2.3 Preset Configurations

**File:** `lib/markers/models/marker_config.dart` (continued)

```dart
/// Preset marker configurations for common use cases
class MarkerConfigs {
  /// Default blue location marker
  static const location = MarkerConfig(
    type: MarkerType.defaultPin,
    color: Color(0xFF2196F3),
    size: 40.0,
  );

  /// Green store/shop marker
  static const store = MarkerConfig(
    type: MarkerType.classicPin,
    color: Color(0xFF4CAF50),
    size: 44.0,
  );

  /// Orange warning marker
  static const warning = MarkerConfig(
    type: MarkerType.defaultPin,
    color: Color(0xFFFF9800),
    size: 40.0,
  );

  /// Red danger/hazard marker
  static const danger = MarkerConfig(
    type: MarkerType.classicPin,
    color: Color(0xFFF44336),
    size: 48.0,
  );

  /// Purple checkpoint marker
  static const checkpoint = MarkerConfig(
    type: MarkerType.circularAvatar,
    color: Color(0xFF9C27B0),
    size: 36.0,
  );

  /// Amber POI marker
  static const poi = MarkerConfig(
    type: MarkerType.modernFlat,
    color: Color(0xFFFFC107),
    size: 38.0,
  );

  /// Minimal dot marker (no shadow)
  static const minimal = MarkerConfig(
    type: MarkerType.minimalDot,
    color: Color(0xFF424242),
    size: 16.0,
    enableShadow: false,
  );
}
```

---

## 3. Adapter Interface

### 3.1 BaseMarkerAdapter

**File:** `lib/markers/adapters/base_marker_adapter.dart`

```dart
import 'package:flutter/material.dart';
import '../models/marker_config.dart';

/// Abstract base class for map-specific marker adapters
///
/// Each map provider (Google Maps, Flutter Map) implements this
/// interface to provide consistent marker rendering.
abstract class BaseMarkerAdapter {
  /// Builds a Flutter widget representing the marker
  ///
  /// Used by FlutterMap and for preview purposes
  Widget buildMarker(
    MarkerConfig config, {
    VoidCallback? onTap,
    bool isSelected = false,
  });

  /// Converts a marker configuration to a BitmapDescriptor
  ///
  /// Used by Google Maps which requires bitmaps for markers
  Future<BitmapDescriptor> buildBitmapDescriptor(
    MarkerConfig config,
  );

  /// Creates a marker with label positioned below it
  Widget buildMarkerWithLabel(
    MarkerConfig config, {
    VoidCallback? onTap,
    Offset labelOffset = const Offset(0, 8),
  });

  /// Validates if the adapter supports the given marker type
  bool supportsMarkerType(MarkerType type);

  /// Gets the approximate hit-test radius for the marker
  double getHitTestRadius(MarkerConfig config);
}
```

---

## 4. Map-Specific Adapters

### 4.1 FlutterMapMarkerAdapter

**File:** `lib/markers/adapters/flutter_map_marker_adapter.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/geo_point.dart';
import '../models/marker_config.dart';
import '../painters/marker_painter.dart';
import '../painters/classic_pin_painter.dart';
import '../painters/modern_flat_painter.dart';
import '../painters/circular_avatar_painter.dart';
import '../painters/minimal_dot_painter.dart';
import '../painters/svg_marker_painter.dart';
import '../widgets/marker_label.dart';
import 'base_marker_adapter.dart';

/// Marker adapter for FlutterMap (OpenStreetMap)
class FlutterMapMarkerAdapter extends BaseMarkerAdapter {
  const FlutterMapMarkerAdapter();

  @override
  bool supportsMarkerType(MarkerType type) => true;

  @override
  double getHitTestRadius(MarkerConfig config) {
    return config.size / 2;
  }

  @override
  Widget buildMarker(
    MarkerConfig config, {
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: config.opacity,
        child: Transform.rotate(
          angle: config.rotation * 3.14159 / 180,
          child: _buildMarkerWidget(config),
        ),
      ),
    );
  }

  Widget _buildMarkerWidget(MarkerConfig config) {
    switch (config.type) {
      case MarkerType.defaultPin:
        return CustomPaint(
          size: Size(config.size, config.size * 1.2),
          painter: MarkerPainter(
            color: config.color,
            borderColor: config.borderColor,
            borderWidth: config.borderWidth,
            enableShadow: config.enableShadow,
          ),
        );

      case MarkerType.classicPin:
        return CustomPaint(
          size: Size(config.size, config.size * 1.3),
          painter: ClassicPinPainter(
            color: config.color,
            borderColor: config.borderColor,
            borderWidth: config.borderWidth,
            enableShadow: config.enableShadow,
          ),
        );

      case MarkerType.modernFlat:
        return CustomPaint(
          size: Size(config.size, config.size),
          painter: ModernFlatPainter(
            color: config.color,
            borderColor: config.borderColor,
            borderWidth: config.borderWidth,
            enableShadow: config.enableShadow,
          ),
        );

      case MarkerType.circularAvatar:
        return CustomPaint(
          size: Size(config.size, config.size),
          painter: CircularAvatarPainter(
            color: config.color,
            borderColor: config.borderColor,
            borderWidth: config.borderWidth,
            enableShadow: config.enableShadow,
            customWidget: config.customWidget,
          ),
        );

      case MarkerType.minimalDot:
        return CustomPaint(
          size: Size(config.size, config.size),
          painter: MinimalDotPainter(
            color: config.color,
          ),
        );

      case MarkerType.svgCustom:
        return CustomPaint(
          size: Size(config.size, config.size),
          painter: SvgMarkerPainter(
            svgPath: config.svgPath!,
            color: config.color,
            borderColor: config.borderColor,
            borderWidth: config.borderWidth,
            enableShadow: config.enableShadow,
          ),
        );
    }
  }

  @override
  Widget buildMarkerWithLabel(
    MarkerConfig config, {
    VoidCallback? onTap,
    Offset labelOffset = const Offset(0, 8),
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (config.label != null)
          MarkerLabel(
            label: config.label!,
            backgroundColor: config.labelBackgroundColor,
            textColor: config.labelColor,
            fontSize: config.labelFontSize,
          ),
        SizedBox(height: labelOffset.dy),
        buildMarker(config, onTap: onTap),
      ],
    );
  }

  @override
  Future<BitmapDescriptor> buildBitmapDescriptor(
    MarkerConfig config,
  ) async {
    // For FlutterMap, we don't need BitmapDescriptor
    // This is mainly for Google Maps compatibility
    throw UnimplementedError(
      'FlutterMap uses widgets directly, not BitmapDescriptor',
    );
  }

  /// Creates a flutter_map Marker from configuration
  Marker createMapMarker({
    required String id,
    required GeoPoint position,
    required MarkerConfig config,
    VoidCallback? onTap,
  }) {
    return Marker(
      point: LatLng(position.latitude, position.longitude),
      width: config.size + 20,
      height: config.size * 1.3 + 20,
      child: buildMarker(
        config,
        onTap: onTap,
      ),
    );
  }
}
```

### 4.2 GoogleMapMarkerAdapter

**File:** `lib/markers/adapters/google_map_marker_adapter.dart`

```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';
import '../models/marker_config.dart';
import '../painters/marker_painter.dart';
import '../painters/classic_pin_painter.dart';
import '../painters/modern_flat_painter.dart';
import '../painters/circular_avatar_painter.dart';
import '../painters/minimal_dot_painter.dart';
import '../painters/svg_marker_painter.dart';
import 'base_marker_adapter.dart';

/// Marker adapter for Google Maps
class GoogleMapMarkerAdapter extends BaseMarkerAdapter {
  const GoogleMapMarkerAdapter();

  @override
  bool supportsMarkerType(MarkerType type) => true;

  @override
  double getHitTestRadius(MarkerConfig config) {
    return config.size / 2;
  }

  @override
  Widget buildMarker(
    MarkerConfig config, {
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    // For preview/debug purposes, render the widget
    return SizedBox(
      width: config.size,
      height: config.size * 1.2,
      child: CustomPaint(
        painter: _getPainter(config),
      ),
    );
  }

  CustomPainter _getPainter(MarkerConfig config) {
    switch (config.type) {
      case MarkerType.defaultPin:
        return MarkerPainter(
          color: config.color,
          borderColor: config.borderColor,
          borderWidth: config.borderWidth,
          enableShadow: config.enableShadow,
        );
      case MarkerType.classicPin:
        return ClassicPinPainter(
          color: config.color,
          borderColor: config.borderColor,
          borderWidth: config.borderWidth,
          enableShadow: config.enableShadow,
        );
      case MarkerType.modernFlat:
        return ModernFlatPainter(
          color: config.color,
          borderColor: config.borderColor,
          borderWidth: config.borderWidth,
          enableShadow: config.enableShadow,
        );
      case MarkerType.circularAvatar:
        return CircularAvatarPainter(
          color: config.color,
          borderColor: config.borderColor,
          borderWidth: config.borderWidth,
          enableShadow: config.enableShadow,
          customWidget: config.customWidget,
        );
      case MarkerType.minimalDot:
        return MinimalDotPainter(color: config.color);
      case MarkerType.svgCustom:
        return SvgMarkerPainter(
          svgPath: config.svgPath!,
          color: config.color,
          borderColor: config.borderColor,
          borderWidth: config.borderWidth,
          enableShadow: config.enableShadow,
        );
    }
  }

  @override
  Future<BitmapDescriptor> buildBitmapDescriptor(
    MarkerConfig config,
  ) async {
    // Check cache first
    final cached = MarkerCacheManager.getBitmapDescriptor(config);
    if (cached != null) {
      return cached;
    }

    // Generate new bitmap
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(config.size, config.size * 1.2);

    // Draw the marker
    final painter = _getPainter(config);
    painter.paint(canvas, size);

    // Convert to bitmap
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (config.size * ui.window.devicePixelRatio).toInt(),
      (config.size * 1.2 * ui.window.devicePixelRatio).toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final bitmapDescriptor = BitmapDescriptor.fromBytes(bytes);

    // Cache the result
    MarkerCacheManager.putBitmapDescriptor(config, bitmapDescriptor);

    return bitmapDescriptor;
  }

  @override
  Widget buildMarkerWithLabel(
    MarkerConfig config, {
    VoidCallback? onTap,
    Offset labelOffset = const Offset(0, 8),
  }) {
    // Google Maps handles labels via InfoWindow
    // This is mainly for preview
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: config.labelBackgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            config.label ?? '',
            style: TextStyle(
              color: config.labelColor,
              fontSize: config.labelFontSize,
            ),
          ),
        ),
        SizedBox(height: labelOffset.dy),
        buildMarker(config, onTap: onTap),
      ],
    );
  }

  /// Creates a Google Maps Marker from configuration
  Marker createMapMarker({
    required MarkerId markerId,
    required GeoPoint position,
    required MarkerConfig config,
    VoidCallback? onTap,
  }) {
    return Marker(
      markerId: markerId,
      position: LatLng(position.latitude, position.longitude),
      icon: config.type == MarkerType.svgCustom
          ? BitmapDescriptor.defaultMarkerWithHue(
              HSLColor.fromColor(config.color).hue,
            )
          : null, // Will be set async via buildBitmapDescriptor
      infoWindow: config.label != null
          ? InfoWindow(title: config.label)
          : InfoWindow.noText,
      onTap: onTap,
      zIndex: config.zIndex,
      alpha: config.opacity,
    );
  }
}
```

---

## 5. Marker Factory

**File:** `lib/markers/factory/marker_factory.dart`

```dart
import 'package:flutter/widgets.dart';
import '../models/marker_config.dart';
import '../models/marker_type.dart';
import '../adapters/base_marker_adapter.dart';
import '../adapters/flutter_map_marker_adapter.dart';
import '../adapters/google_map_marker_adapter.dart';
import '../cache/marker_cache_manager.dart';

/// Factory for creating markers with the appropriate adapter
class MarkerFactory {
  static const _flutterAdapter = FlutterMapMarkerAdapter();
  static const _googleAdapter = GoogleMapMarkerAdapter();

  /// Get the appropriate adapter for the map provider
  static BaseMarkerAdapter getAdapter(MapProvider provider) {
    switch (provider) {
      case MapProvider.flutterMap:
      case MapProvider.auto:
        return _flutterAdapter;
      case MapProvider.googleMap:
        return _googleAdapter;
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
  }) {
    return _flutterAdapter.buildMarkerWithLabel(
      config,
      onTap: onTap,
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
    return Future.wait(
      configs.map((config) => createBitmapDescriptor(config)),
    );
  }

  /// Preload marker bitmaps for better performance
  static Future<void> preloadMarkers(List<MarkerConfig> configs) async {
    await createBitmapDescriptors(configs);
  }

  /// Clear all cached markers
  static void clearCache() {
    MarkerCacheManager.clear();
  }
}
```

---

## 6. Cache Manager

**File:** `lib/markers/cache/marker_cache_manager.dart`

```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/marker_config.dart';
import 'cache_key.dart';

/// Cache manager for marker widgets and bitmaps
class MarkerCacheManager {
  static const _maxCacheSize = 50;

  static final Map<String, Widget> _widgetCache = {};
  static final Map<String, BitmapDescriptor> _bitmapCache = {};
  static final List<String> _cacheAccessOrder = [];

  /// Get a cached widget for the given configuration
  static Widget? getCachedWidget(MarkerConfig config) {
    final key = config.cacheKey;
    _updateAccessOrder(key);
    return _widgetCache[key];
  }

  /// Cache a widget for the given configuration
  static void putWidget(MarkerConfig config, Widget widget) {
    final key = config.cacheKey;
    _ensureCapacity();
    _widgetCache[key] = widget;
    _updateAccessOrder(key);
  }

  /// Get a cached BitmapDescriptor for Google Maps
  static BitmapDescriptor? getCachedBitmapDescriptor(
    MarkerConfig config,
  ) {
    final key = config.cacheKey;
    _updateAccessOrder(key);
    return _bitmapCache[key];
  }

  /// Cache a BitmapDescriptor for Google Maps
  static void putBitmapDescriptor(
    MarkerConfig config,
    BitmapDescriptor descriptor,
  ) {
    final key = config.cacheKey;
    _ensureCapacity();
    _bitmapCache[key] = descriptor;
    _updateAccessOrder(key);
  }

  /// Clear all caches
  static void clear() {
    _widgetCache.clear();
    _bitmapCache.clear();
    _cacheAccessOrder.clear();
  }

  /// Remove specific entry from cache
  static void remove(MarkerConfig config) {
    final key = config.cacheKey;
    _widgetCache.remove(key);
    _bitmapCache.remove(key);
    _cacheAccessOrder.remove(key);
  }

  /// Get cache statistics
  static Map<String, dynamic> getStats() {
    return {
      'widgetCacheSize': _widgetCache.length,
      'bitmapCacheSize': _bitmapCache.length,
      'maxCacheSize': _maxCacheSize,
    };
  }

  static void _ensureCapacity() {
    while (_widgetCache.length + _bitmapCache.length >= _maxCacheSize) {
      if (_cacheAccessOrder.isNotEmpty) {
        final oldestKey = _cacheAccessOrder.removeAt(0);
        _widgetCache.remove(oldestKey);
        _bitmapCache.remove(oldestKey);
      } else {
        break;
      }
    }
  }

  static void _updateAccessOrder(String key) {
    _cacheAccessOrder.remove(key);
    _cacheAccessOrder.add(key);
  }
}
```

---

## 7. Custom Painters

### 7.1 Marker Painter (Default Pin)

**File:** `lib/markers/painters/marker_painter.dart`

```dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Painter for the default teardrop pin marker
class MarkerPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final bool enableShadow;

  const MarkerPainter({
    required this.color,
    required this.borderColor,
    this.borderWidth = 2.0,
    this.enableShadow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final path = _createPinPath(center, radius);

    // Draw shadow
    if (enableShadow) {
      final shadowPath = _createPinPath(
        center + const Offset(0, 4),
        radius,
      );
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(shadowPath, shadowPaint);
    }

    // Fill
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Border
    if (borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawPath(path, borderPaint);
    }

    // Inner circle
    final innerCirclePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.15),
      radius * 0.2,
      innerCirclePaint,
    );
  }

  ui.Path _createPinPath(Offset center, double radius) {
    final path = ui.Path();
    final topY = center.dy - radius * 0.7;

    // Outer circle (teardrop top)
    path.addOval(Rect.fromCircle(
      center: Offset(center.dx, topY),
      radius: radius * 0.5,
    ));

    // Pointy bottom
    path.moveTo(center.dx - radius * 0.5, topY);
    path.lineTo(center.dx, center.dy + radius * 0.3);
    path.lineTo(center.dx + radius * 0.5, topY);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant MarkerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.enableShadow != enableShadow;
  }
}
```

### 7.2 Other Painters (Summary)

**Classic Pin Painter** - Wider head, longer point
**Modern Flat Painter** - Rounded rectangle with flat bottom
**Circular Avatar Painter** - Circle with optional content inside
**Minimal Dot Painter** - Simple filled circle, no shadow
**SVG Marker Painter** - Renders custom SVG paths with color fill

---

## 8. Public API

### 8.1 Updated GeoMarkerWidget

**File:** `lib/geo_widget/geo_marker_widget.dart`

```dart
import 'package:flutter/material.dart';
import '../models/geo_point.dart';
import '../markers/models/marker_config.dart';
import '../markers/models/marker_type.dart';
import 'geo_geofence_base.dart';

/// Enhanced marker widget with configurable styles
class GeoMarkerWidget extends GeoGeofenceBase {
  final GeoPoint position;
  final MarkerConfig? config;

  // Legacy properties (for backward compatibility)
  final String? label;
  final Color markerColor;
  final double markerSize;

  const GeoMarkerWidget({
    required super.id,
    required this.position,
    this.config,
    this.label,
    this.markerColor = const Color(0xFF2196F3),
    this.markerSize = 32.0,
    super.isInteractive,
    super.metadata,
  })  : super(color: markerColor);

  /// Create a marker with full configuration
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
      metadata: metadata,
      isInteractive: isInteractive,
    );
  }

  /// Preset factories now use MarkerConfig
  factory GeoMarkerWidget.location({
    required String id,
    required GeoPoint position,
    String? label,
    double markerSize = 32.0,
  }) {
    return GeoMarkerWidget.withConfig(
      id: id,
      position: position,
      config: MarkerConfigs.location.copyWith(size: markerSize),
    );
  }

  factory GeoMarkerWidget.store({
    required String id,
    required GeoPoint position,
    String? label,
    double markerSize = 36.0,
  }) {
    return GeoMarkerWidget.withConfig(
      id: id,
      position: position,
      config: MarkerConfigs.store.copyWith(size: markerSize),
    );
  }

  // ... other presets

  @override
  void validate() {
    config?.validate();
  }

  /// Get the effective marker configuration
  MarkerConfig get effectiveConfig {
    return config ??
        MarkerConfig(
          type: MarkerType.defaultPin,
          color: markerColor,
          size: markerSize,
          label: label,
        );
  }
}
```

---

## 9. Applying Markers to Geofences

### 9.1 Geofence Center Markers

```dart
// Add a marker at the center of a circle geofence
final circle = GeoCircleWidget(
  id: 'zone',
  center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  radius: 500,
);

final centerMarker = GeoMarkerWidget.withConfig(
  id: 'zone_center',
  position: circle.center,
  config: MarkerConfig(
    type: MarkerType.minimalDot,
    color: circle.borderColor,
    size: 16,
    enableShadow: false,
  ),
);

GeoGeofenceMap(
  geofences: [circle],
  markers: [centerMarker],
)
```

### 9.2 Polygon Vertex Markers

```dart
// Create markers for each vertex of a polygon
final polygon = GeoPolygonWidget(
  id: 'area',
  points: [
    GeoPoint(latitude: 37.78, longitude: -122.42),
    GeoPoint(latitude: 37.78, longitude: -122.40),
    GeoPoint(latitude: 37.76, longitude: -122.40),
    GeoPoint(latitude: 37.76, longitude: -122.42),
  ],
);

// Generate vertex markers
final vertexMarkers = polygon.points.asMap().entries.map((entry) {
  return GeoMarkerWidget.withConfig(
    id: 'vertex_${entry.key}',
    position: entry.value,
    config: MarkerConfig(
      type: MarkerType.minimalDot,
      color: polygon.borderColor,
      size: 12,
      enableShadow: false,
    ),
  );
}).toList();
```

### 9.3 Polyline Start/End Markers

```dart
// Create markers for polyline endpoints
final polyline = GeoPolylineWidget(
  id: 'route',
  points: [
    GeoPoint(latitude: 37.7749, longitude: -122.4194),
    GeoPoint(latitude: 37.7849, longitude: -122.4094),
    GeoPoint(latitude: 37.7949, longitude: -122.3994),
  ],
);

final startMarker = GeoMarkerWidget.withConfig(
  id: 'start',
  position: polyline.points.first,
  config: MarkerConfigs.checkpoint.copyWith(
    label: 'Start',
    customWidget: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
  ),
);

final endMarker = GeoMarkerWidget.withConfig(
  id: 'end',
  position: polyline.points.last,
  config: MarkerConfigs.checkpoint.copyWith(
    label: 'End',
    customWidget: const Icon(Icons.flag, color: Colors.white, size: 16),
  ),
);
```

---

## 10. Example Usage

### 10.1 Basic Marker

```dart
import 'package:geo_fence_utils/geo_fence_utils.dart';

// Simple default marker
final marker = GeoMarkerWidget.location(
  id: 'location',
  position: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  label: 'San Francisco',
);

// Display on map
GeoGeofenceMap(
  center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  zoom: 13.0,
  markers: [marker],
  onMarkerTap: (id) => print('Tapped: $id'),
)
```

### 10.2 Custom Configuration

```dart
// Custom marker with specific style
final customMarker = GeoMarkerWidget.withConfig(
  id: 'custom',
  position: GeoPoint(latitude: 37.78, longitude: -122.41),
  config: MarkerConfig(
    type: MarkerType.modernFlat,
    color: const Color(0xFF9C27B0), // Purple
    size: 48.0,
    enableShadow: true,
    label: 'My Location',
    labelColor: Colors.white,
    labelBackgroundColor: Colors.black87,
  ),
);
```

### 10.3 SVG Custom Marker

```dart
// Custom SVG path marker
final svgMarker = GeoMarkerWidget.withConfig(
  id: 'svg_custom',
  position: GeoPoint(latitude: 37.79, longitude: -122.43),
  config: MarkerConfig(
    type: MarkerType.svgCustom,
    color: const Color(0xFFE91E63), // Pink
    size: 50.0,
    svgPath: 'M25,0 L50,25 L25,50 L0,25 Z', // Diamond shape
    label: 'Diamond Zone',
  ),
);
```

### 10.4 Batch Marker Creation

```dart
// Create multiple checkpoints
final checkpoints = List.generate(5, (index) {
  final lat = 37.77 + (index * 0.01);
  final lng = -122.42 + (index * 0.01);

  return GeoMarkerWidget.withConfig(
    id: 'checkpoint_$index',
    position: GeoPoint(latitude: lat, longitude: lng),
    config: MarkerConfigs.checkpoint.copyWith(
      customWidget: Text('${index + 1}', style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      )),
    ),
  );
});

GeoGeofenceMap(
  center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  zoom: 12.0,
  markers: checkpoints,
)
```

---

## 11. Performance Optimization

### 11.1 Web Optimization

```dart
// Preload markers for better web performance
await MarkerFactory.preloadMarkers([
  MarkerConfigs.location,
  MarkerConfigs.store,
  MarkerConfigs.warning,
  MarkerConfigs.danger,
]);
```

### 11.2 Cache Management

```dart
// Clear cache when memory is constrained
MarkerFactory.clearCache();

// Get cache statistics
final stats = MarkerCacheManager.getStats();
print('Cache stats: $stats');
```

### 11.3 Lazy Loading

```dart
// Load markers on demand for large datasets
class LazyMarkerLoader {
  final List<GeoMarkerWidget> _allMarkers = [];
  final int _batchSize = 50;
  int _loadedCount = 0;

  List<GeoMarkerWidget> loadMore() {
    final start = _loadedCount;
    final end = (_loadedCount + _batchSize).clamp(0, _allMarkers.length);
    _loadedCount = end;
    return _allMarkers.sublist(start, end);
  }
}
```

---

## 12. Best Practices

### 12.1 Use Presets When Possible

```dart
// ✅ Good - uses optimized preset
GeoMarkerWidget.location(id: 'loc', position: pos)

// ❌ Avoid - creates new config each time
GeoMarkerWidget.withConfig(
  id: 'loc',
  position: pos,
  config: MarkerConfig(type: MarkerType.defaultPin, ...),
)
```

### 12.2 Reuse Configurations

```dart
// ✅ Good - reuse config
final blueConfig = MarkerConfig(
  type: MarkerType.defaultPin,
  color: Colors.blue,
  size: 40.0,
);

final marker1 = GeoMarkerWidget.withConfig(
  id: 'm1',
  position: pos1,
  config: blueConfig,
);

final marker2 = GeoMarkerWidget.withConfig(
  id: 'm2',
  position: pos2,
  config: blueConfig,
);
```

### 12.3 Preload for Better UX

```dart
// Preload common markers at app startup
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    MarkerFactory.preloadMarkers([
      MarkerConfigs.location,
      MarkerConfigs.store,
      MarkerConfigs.warning,
    ]);
  });
}
```

---

## 13. Migration Guide

### From Old GeoMarkerWidget

**Before:**
```dart
GeoMarkerWidget(
  id: 'marker',
  position: GeoPoint(lat: 37.7749, lng: -122.4194),
  label: 'Location',
  markerColor: Colors.blue,
  markerSize: 40.0,
)
```

**After:**
```dart
GeoMarkerWidget.withConfig(
  id: 'marker',
  position: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  config: MarkerConfig(
    type: MarkerType.defaultPin,
    color: Colors.blue,
    size: 40.0,
    label: 'Location',
  ),
)
```

---

## 14. Testing Checklist

- [ ] All 6 marker types render correctly on Flutter Map
- [ ] All 6 marker types render correctly on Google Maps
- [ ] SVG custom markers render accurately
- [ ] Shadow renders correctly (when enabled)
- [ ] Labels display with proper positioning
- [ ] Tap detection works for all marker types
- [ ] Cache hits reduce render time
- [ ] Web performance is acceptable
- [ ] Memory usage stays within limits
- [ ] Custom widgets display in circular avatar markers

---

## 15. Future Enhancements

- Animated marker transitions
- Marker clustering for large datasets
- Custom marker images from network URLs
- Marker drag-and-drop support
- Marker rotation based on bearing
- Pulse animation for selected markers
- Trail/path rendering for moving markers

---

**Document Version:** 1.0
**Last Updated:** 2026-03-04
**Status:** Ready for Implementation
