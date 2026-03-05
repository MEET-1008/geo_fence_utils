# Geo Fence Utils

A powerful, production-ready Flutter/Dart package for geofence calculations, location-based operations, and interactive map visualizations.

## Features

- **Distance Calculations** - Accurate great-circle distances using Haversine formula (~0.5% accuracy)
- **Circle Geofences** - Point-in-circle detection with radius-based filtering
- **Polygon Geofences** - Ray casting algorithm for complex polygon shapes
- **Batch Operations** - Efficient processing of multiple points
- **Map Integration** - Interactive widgets for visualizing geofences
- **Custom Markers** - PNG and SVG marker support
- **Pure Dart** - No native dependencies, works on all platforms

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  geo_fence_utils: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:geo_fence_utils/geo_fence_utils.dart';

// Create a location
final sanFrancisco = GeoPoint(
  latitude: 37.7749,
  longitude: -122.4194,
);

// Create a circular geofence (500m radius)
final circle = GeoCircle(
  center: sanFrancisco,
  radius: 500,
);

// Check if a point is inside the geofence
final testPoint = GeoPoint(latitude: 37.7750, longitude: -122.4195);
final isInside = GeoCircleService.isInsideCircle(
  point: testPoint,
  circle: circle,
);
print('Is inside geofence: $isInside');
```

## Core Classes

### GeoPoint
Represents a geographical coordinate.

```dart
final point = GeoPoint(
  latitude: 37.7749,   // -90 to 90
  longitude: -122.4194, // -180 to 180
);

// Convert to/from JSON
final json = point.toJson();
final restored = GeoPoint.fromJson(json);
```

### GeoCircle
Defines a circular geofence area.

```dart
final circle = GeoCircle(
  center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  radius: 1000, // meters
);

// Calculate properties
final area = circle.area;           // in square meters
final circumference = circle.circumference; // in meters
```

### GeoPolygon
Defines a polygonal geofence area.

```dart
final polygon = GeoPolygon(points: [
  GeoPoint(latitude: 37.7749, longitude: -122.4194),
  GeoPoint(latitude: 37.7849, longitude: -122.4094),
  GeoPoint(latitude: 37.7649, longitude: -122.4094),
]);

// Create from bounding box
final rect = GeoPolygon.fromBounds(
  minLat: 37.76,
  maxLat: 37.78,
  minLon: -122.42,
  maxLon: -122.40,
);

// Calculate centroid
final center = polygon.centroid;
```

## Services

### GeoDistanceService
Calculate distances between geographic points.

```dart
// Distance between two points (Haversine formula)
final distance = GeoDistanceService.calculateDistance(
  point1: sf,
  point2: nyc,
); // returns distance in meters

// Batch calculate distances
final distances = GeoDistanceService.calculateDistances(
  origin: center,
  points: [point1, point2, point3],
);

// Find closest/farthest point
final closest = GeoDistanceService.findClosest(
  origin: center,
  candidates: points,
);

// Filter points within radius
final nearby = GeoDistanceService.filterByRadius(
  origin: center,
  points: allPoints,
  radius: 1000, // 1 km
);
```

### GeoCircleService
Operations for circular geofences.

```dart
// Check if point is inside circle
final inside = GeoCircleService.isInsideCircle(
  point: testPoint,
  circle: myCircle,
);

// Distance to circle boundary
final distance = GeoCircleService.distanceToBoundary(
  point: testPoint,
  circle: myCircle,
);

// Check if two circles overlap
final overlaps = GeoCircleService.circlesOverlap(
  circle1: circleA,
  circle2: circleB,
);

// Filter points inside/outside
final insidePoints = GeoCircleService.filterInside(
  points: allPoints,
  circle: myCircle,
);
```

### GeoPolygonService
Operations for polygon geofences.

```dart
// Check if point is inside polygon (ray casting)
final inside = GeoPolygonService.isInsidePolygon(
  point: testPoint,
  polygon: myPolygon,
);

// Check if point is on boundary
final onBoundary = GeoPolygonService.isOnBoundary(
  point: testPoint,
  polygon: myPolygon,
);

// Calculate area and perimeter
final area = GeoPolygonService.calculateArea(polygon);
final perimeter = GeoPolygonService.calculatePerimeter(polygon);

// Get bounding box
final bounds = GeoPolygonService.getBoundingBox(polygon);

// Count points inside polygon
final count = GeoPolygonService.countInside(
  points: allPoints,
  polygon: myPolygon,
);
```

## Map Widget

Display geofences on an interactive map.

```dart
GeoGeofenceMap(
  center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  zoom: 13.0,
  geofences: [
    // Circle geofence
    GeoCircleWidget(
      id: 'danger_zone',
      circle: GeoCircle(
        center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
        radius: 1000,
      ),
      color: GeoColor.red,
      strokeWidth: 2,
      onTap: () => print('Circle tapped!'),
    ),

    // Polygon geofence
    GeoPolygonWidget(
      id: 'restricted_area',
      polygon: GeoPolygon(points: [...]),
      color: GeoColor.blue,
      fillPattern: FillPattern.diagonal,
    ),

    // Polyline route
    GeoPolylineWidget(
      id: 'route',
      points: [point1, point2, point3],
      color: GeoColor.green,
      strokeWidth: 4,
    ),

    // Custom marker
    GeoMarkerWidget(
      id: 'marker1',
      position: GeoPoint(latitude: 37.7749, longitude: -122.4194),
      config: MarkerConfig(
        type: MarkerType.svgCustom,
        svgPath: 'M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z',
        color: GeoColor.red,
        size: 40,
        label: 'San Francisco',
      ),
    ),
  ],

  // Choose map provider
  provider: MapProvider.flutterMap,
  // or provider: MapProvider.googleMaps,

  // Callbacks
  onGeofenceTap: (id) => print('Tapped: $id'),
  onMarkerTap: (id) => print('Marker: $id'),
  onMapTap: (location) => print('Tapped map at: $location'),
)
```

## Predefined Geofence Styles

```dart
// Danger zone (red)
GeoCircleWidget.dangerZone(
  id: 'zone1',
  center: center,
  radius: 1000,
)

// Safe zone (green)
GeoCircleWidget.safeZone(
  id: 'zone2',
  center: center,
  radius: 500,
)

// Restricted area (blue polygon)
GeoPolygonWidget.restrictedArea(
  id: 'area1',
  points: polygonPoints,
)

// Security perimeter (orange)
GeoPolygonWidget.securityPerimeter(
  id: 'perimeter1',
  points: boundaryPoints,
)

// Navigation route (blue polyline)
GeoPolylineWidget.navigationRoute(
  id: 'route1',
  points: routePoints,
)
```

## Marker Configuration

### PNG Asset Marker

```dart
MarkerConfig(
  type: MarkerType.pngAsset,
  assetPath: 'assets/icons/pin.png',
  size: 48,
  label: 'Location 1',
)
```

### SVG Custom Marker

```dart
MarkerConfig(
  type: MarkerType.svgCustom,
  svgPath: 'M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z',
  color: GeoColor.fromHex('#FF5722'),
  size: 40,
  label: 'Custom SVG',
)
```

### Default Shape Marker

```dart
MarkerConfig(
  type: MarkerType.defaultShape,
  defaultShape: MarkerShape.pin,
  color: GeoColor.purple,
  size: 36,
  label: 'Default Pin',
)
```

## Batch Operations

Process multiple points efficiently:

```dart
final points = [point1, point2, point3, point4, point5];

// Find closest point
final closest = GeoDistanceService.findClosest(
  origin: center,
  candidates: points,
);

// Find farthest point
final farthest = GeoDistanceService.findFarthest(
  origin: center,
  candidates: points,
);

// Filter by radius
final nearby = GeoDistanceService.filterByRadius(
  origin: center,
  points: points,
  radius: 5000,
);

// Count inside polygon
final count = GeoPolygonService.countInside(
  points: points,
  polygon: myPolygon,
);

// Filter inside polygon
final inside = GeoPolygonService.filterInside(
  points: points,
  polygon: myPolygon,
);
```

## Use Cases

### 1. Location-Based Notifications

```dart
// Check if user enters a geofence
final userLocation = GeoPoint(lat: 37.775, lon: -122.419);
final notificationZone = GeoCircle(
  center: GeoPoint(lat: 37.7749, lon: -122.4194),
  radius: 500,
);

if (GeoCircleService.isInsideCircle(
  point: userLocation,
  circle: notificationZone,
)) {
  sendNotification('Welcome to the area!');
}
```

### 2. Find Nearby Places

```dart
// Find all points of interest within 1km
final userLocation = getUserLocation();
final nearbyPOIs = GeoDistanceService.filterByRadius(
  origin: userLocation,
  points: allPointsOfInterest,
  radius: 1000,
);
```

### 3. Delivery Route Tracking

```dart
// Check if delivery location is in service area
final serviceArea = GeoPolygon(points: serviceZonePoints);
final deliveryLocation = getDeliveryAddress();

if (GeoPolygonService.isInsidePolygon(
  point: deliveryLocation,
  polygon: serviceArea,
)) {
  processDelivery();
}
```

### 4. Fleet Management

```dart
// Find closest vehicle to customer
final customerLocation = GeoPoint(lat: 37.7749, lon: -122.4194);
final vehicles = getVehicleLocations();

final closestVehicle = GeoDistanceService.findClosest(
  origin: customerLocation,
  candidates: vehicles,
);
assignVehicle(closestVehicle);
```

## Performance

- **Distance Calculation**: ~0.5% accuracy using Haversine formula
- **Polygon Detection**: Efficient ray casting algorithm
- **Batch Operations**: Optimized for processing multiple points
- **No Native Dependencies**: Pure Dart implementation

## Platforms

- iOS
- Android
- Web
- macOS
- Windows
- Linux

## License

MIT License - see LICENSE for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues, questions, or contributions, please visit the GitHub repository.
