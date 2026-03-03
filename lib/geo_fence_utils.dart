/// Geo Fence Utilities - Production-ready geofence calculations for Dart/Flutter
///
/// This library provides comprehensive geofence functionality including:
///
/// - **Distance Calculation**: Accurate Haversine formula implementation
/// - **Circle Geofences**: Point-in-circle detection with radius-based filtering
/// - **Polygon Geofences**: Ray Casting algorithm for complex polygon detection
/// - **Math Utilities**: Coordinate conversions, bearing calculations, and more
///
/// ## Basic Usage
///
/// ### Distance Calculation
/// ```dart
/// import 'package:geo_fence_utils/geo_fence_utils.dart';
///
/// final sf = GeoPoint(latitude: 37.7749, longitude: -122.4194);
/// final nyc = GeoPoint(latitude: 40.7128, longitude: -74.0060);
///
/// final distance = GeoDistanceService.calculateDistance(sf, nyc);
/// print('Distance: ${(distance / 1000).toStringAsFixed(0)} km');
/// ```
///
/// ### Circle Geofence
/// ```dart
/// final circle = GeoCircle(
///   center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
///   radius: 500, // 500 meters
/// );
///
/// final point = GeoPoint(latitude: 37.7750, longitude: -122.4195);
/// final inside = GeoCircleService.isInsideCircle(
///   point: point,
///   circle: circle,
/// );
/// ```
///
/// ### Polygon Geofence
/// ```dart
/// final polygon = GeoPolygon(points: [
///   GeoPoint(latitude: 37.7749, longitude: -122.4194),
///   GeoPoint(latitude: 37.7849, longitude: -122.4094),
///   GeoPoint(latitude: 37.7649, longitude: -122.4094),
/// ]);
///
/// final point = GeoPoint(latitude: 37.7750, longitude: -122.4180);
/// final isInside = GeoPolygonService.isInsidePolygon(
///   point: point,
///   polygon: polygon,
/// );
/// ```
///
/// ## Library Structure
///
/// ### Models
/// - [GeoPoint] - A geographical point with latitude and longitude
/// - [GeoCircle] - A circular geofence area
/// - [GeoPolygon] - A polygonal geofence area
///
/// ### Services
/// - [GeoDistanceService] - Distance calculations
/// - [GeoCircleService] - Circle geofence operations
/// - [GeoPolygonService] - Polygon geofence operations
///
/// ### Exceptions
/// - [InvalidRadiusException] - Thrown for invalid radius values
/// - [InvalidPolygonException] - Thrown for invalid polygons
/// - [InvalidCoordinateException] - Thrown for invalid coordinates
/// - [GeoCalculationException] - Thrown for calculation failures
///
/// ## Performance Notes
///
/// - Distance calculations: O(1) - constant time
/// - Circle containment checks: O(1) - constant time
/// - Polygon containment checks: O(n) - linear with vertex count
/// - Batch operations: O(n×m) - n points, m polygon vertices
///
/// ## Accuracy
///
/// - Haversine Formula: ~0.5% (spherical Earth assumption)
/// - Coordinate System: WGS 84 (GPS standard)
/// - Distance Units: Meters
///
/// ## License
///
/// MIT License - See LICENSE file for details
library geo_fence_utils;

// ========================================================================
// MODELS - Data Structures
// ========================================================================

/// Geographical data models
///
/// These classes represent the core data structures used throughout
/// the library. All models are immutable and provide serialization support.
export 'models/geo_point.dart';
export 'models/geo_circle.dart';
export 'models/geo_polygon.dart';

// ========================================================================
// SERVICES - Business Logic
// ========================================================================

/// Geofence detection and calculation services
///
/// Services provide the main API for geofence operations.
/// All methods are static and stateless.
export 'services/geo_distance_service.dart';
export 'services/geo_circle_service.dart';
export 'services/geo_polygon_service.dart';

// ========================================================================
// EXCEPTIONS - Error Handling
// ========================================================================

/// Custom exception types for geofence operations
///
/// Use these exceptions for fine-grained error handling in your code.
export 'exceptions/geo_exceptions.dart';

// ========================================================================
// GEO WIDGET UI - Map Display Components
// ========================================================================

/// Map widgets for displaying geofences on interactive maps
///
/// These widgets provide declarative, easy-to-use map components for
/// visualizing geofences without complex setup.
export 'geo_widget/geo_geofence_base.dart';
export 'geo_widget/geo_geofence_map.dart';
export 'geo_widget/geo_circle_widget.dart';
export 'geo_widget/geo_polygon_widget.dart';
export 'geo_widget/geo_polyline_widget.dart';
export 'geo_widget/map_provider.dart';

// ========================================================================
// EXTENSIONS - Utility Extensions
// ========================================================================

/// Extension methods for geographic coordinates
///
/// Provides conversions between internal types and map SDK types.
export 'extensions/geo_point_extensions.dart';
