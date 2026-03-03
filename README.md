<div align="center">

# geo_fence_utils

**A production-ready Dart package for geofence calculations**

[![Pub Version](https://img.shields.io/pub/v/geo_fence_utils)](https://pub.dev/packages/geo_fence_utils)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![Dart](https://img.shields.io/badge/dart-2.19%2B-blue)](https://dart.dev)
[![Tests](https://img.shields.io/badge/tests-187%20passing-success)](TEST_COVERAGE.md)
[![Coverage](https://img.shields.io/badge/coverage-96%25-brightgreen)](TEST_COVERAGE.md)

Features • Installation • Usage • API • Contributing

</div>

---

## ✨ Features

- **🎯 Accurate Distance Calculation** — Haversine formula with ~0.5% accuracy
- **⭕ Circle Geofence** — Point-in-circle detection with radius filtering
- **🔷 Polygon Geofence** — Ray casting algorithm for complex shapes
- **📊 Batch Operations** — Process multiple points efficiently
- **🧪 Well Tested** — Comprehensive test suite with 96% coverage (187 tests)
- **📱 Pure Dart** — No native dependencies, works everywhere
- **🔧 Type Safe** — Full null safety support

---

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  geo_fence_utils: ^1.0.0
```

Then run:

```bash
flutter pub get
```

Or use Flutter command:

```bash
flutter pub add geo_fence_utils
```

---

## 🚀 Quick Start

### Distance Calculation

Calculate the great-circle distance between two points:

```dart
import 'package:geo_fence_utils/geo_fence_utils.dart';

void main() {
  final sf = GeoPoint(latitude: 37.7749, longitude: -122.4194);
  final nyc = GeoPoint(latitude: 40.7128, longitude: -74.0060);

  final distance = GeoDistanceService.calculateDistance(sf, nyc);
  print('Distance: ${(distance / 1000).toStringAsFixed(0)} km');
  // Output: Distance: 4,130 km
}
```

### Circle Geofence

Check if a point is within a circular area:

```dart
void circleGeofence() {
  final circle = GeoCircle(
    center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
    radius: 500, // 500 meters
  );

  final point = GeoPoint(latitude: 37.7750, longitude: -122.4195);

  final inside = GeoCircleService.isInsideCircle(
    point: point,
    circle: circle,
  );

  print('Inside geofence: $inside'); // Inside geofence: true
}
```

### Polygon Geofence

Check if a point is within a polygon:

```dart
void polygonGeofence() {
  final polygon = GeoPolygon(points: [
    GeoPoint(latitude: 37.7749, longitude: -122.4194),
    GeoPoint(latitude: 37.7849, longitude: -122.4094),
    GeoPoint(latitude: 37.7649, longitude: -122.4094),
  ]);

  final point = GeoPoint(latitude: 37.7750, longitude: -122.4180);

  final inside = GeoPolygonService.isInsidePolygon(
    point: point,
    polygon: polygon,
  );

  print('Inside polygon: $inside'); // Inside polygon: true
}
```

---

## 📚 Advanced Usage

### Batch Operations

Filter multiple points at once:

```dart
void batchOperations() {
  final circle = GeoCircle(
    center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
    radius: 1000,
  );

  final points = [
    GeoPoint(latitude: 37.7750, longitude: -122.4195),
    GeoPoint(latitude: 37.7800, longitude: -122.4100),
    GeoPoint(latitude: 40.7128, longitude: -74.0060), // Far away
  ];

  final insidePoints = GeoCircleService.filterInside(
    points: points,
    circle: circle,
  );

  print('Points inside: ${insidePoints.length}'); // Points inside: 2
}
```

### Distance to Boundary

Find how far a point is from the geofence boundary:

```dart
void distanceToBoundary() {
  final circle = GeoCircle(
    center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
    radius: 500,
  );

  final point = GeoPoint(latitude: 37.7750, longitude: -122.4195);

  final distance = GeoCircleService.distanceToBoundary(
    point: point,
    circle: circle,
  );

  if (distance < 0) {
    print('${distance.abs().toStringAsFixed(0)} meters inside');
  } else if (distance > 0) {
    print('${distance.toStringAsFixed(0)} meters outside');
  } else {
    print('On the boundary');
  }
}
```

### Rectangle Polygon

Create a rectangular geofence easily:

```dart
void rectanglePolygon() {
  final rect = GeoPolygon.rectangle(
    north: 37.78,
    south: 37.76,
    east: -122.40,
    west: -122.42,
  );

  final point = GeoPoint(latitude: 37.77, longitude: -122.41);

  final inside = GeoPolygonService.isInsidePolygon(
    point: point,
    polygon: rect,
  );

  print('Inside rectangle: $inside');
}
```

### Find Closest Point

Find the nearest point from a list:

```dart
void findClosest() {
  final origin = GeoPoint(latitude: 37.7749, longitude: -122.4194);

  final candidates = [
    GeoPoint(latitude: 37.78, longitude: -122.41),
    GeoPoint(latitude: 40.71, longitude: -74.00),
  ];

  final closest = GeoDistanceService.findClosest(origin, candidates);

  print('Closest point: ${closest?.latitude}, ${closest?.longitude}');
}
```

### Sort by Distance

Sort points by their distance from a reference point:

```dart
void sortByDistance() {
  final origin = GeoPoint(latitude: 37.7749, longitude: -122.4194);

  final points = [
    GeoPoint(latitude: 37.78, longitude: -122.41),
    GeoPoint(latitude: 40.71, longitude: -74.00),
  ];

  final sorted = GeoDistanceService.sortByDistance(origin, points);

  for (final point in sorted) {
    final distance = GeoDistanceService.calculateDistance(origin, point);
    print('${point.latitude}: ${(distance / 1000).toStringAsFixed(1)} km');
  }
}
```

### Error Handling

Handle validation errors gracefully:

```dart
void errorHandling() {
  try {
    final polygon = GeoPolygon(points: [
      GeoPoint(latitude: 37.77, longitude: -122.42),
      GeoPoint(latitude: 37.78, longitude: -122.41),
      // Only 2 points - will throw assertion error
    ]);
  } on AssertionError catch (e) {
    print('Invalid polygon: ${e.message}');
  }

  // Using service validation
  try {
    GeoPolygonService.validatePolygon(/* ... */);
  } on InvalidPolygonException catch (e) {
    print('Invalid polygon: ${e.message}');
    // Output: Invalid polygon: Polygon must have at least 3 vertices
  }
}
```

### Circle Overlap Detection

Check if two circles overlap:

```dart
void circleOverlap() {
  final circle1 = GeoCircle(
    center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
    radius: 500,
  );

  final circle2 = GeoCircle(
    center: GeoPoint(latitude: 37.7760, longitude: -122.4180),
    radius: 500,
  );

  final overlaps = GeoCircleService.circlesOverlap(
    circle1: circle1,
    circle2: circle2,
  );

  print('Circles overlap: $overlaps');
}
```

---

## 📖 API Reference

### Models

#### GeoPoint

A geographical point with latitude and longitude.

```dart
final point = GeoPoint(
  latitude: 37.7749,  // Range: -90 to 90
  longitude: -122.4194, // Range: -180 to 180
);

// Properties
point.latitude;  // double
point.longitude; // double

// Methods
point.toJson();  // Map<String, dynamic>
GeoPoint.fromJson(json); // Static factory
```

#### GeoCircle

A circular geofence area.

```dart
final circle = GeoCircle(
  center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  radius: 500, // meters
);

// Properties
circle.center; // GeoPoint
circle.radius; // double (meters)
circle.area;   // double (square meters)
circle.circumference; // double (meters)
```

#### GeoPolygon

A polygonal geofence area.

```dart
final polygon = GeoPolygon(points: [
  GeoPoint(latitude: 37.7749, longitude: -122.4194),
  GeoPoint(latitude: 37.7849, longitude: -122.4094),
  GeoPoint(latitude: 37.7649, longitude: -122.4094),
]);

// Properties
polygon.points;  // List<GeoPoint>
polygon.vertexCount; // int
polygon.centroid; // GeoPoint
polygon.isConvex; // bool

// Factory constructor
final rect = GeoPolygon.rectangle(
  north: 37.78,
  south: 37.76,
  east: -122.40,
  west: -122.42,
);
```

### Services

#### GeoDistanceService

| Method | Description |
|--------|-------------|
| `calculateDistance(p1, p2)` | Distance between two points |
| `calculateDistances(origin, destinations)` | Distances to multiple points |
| `findClosest(origin, candidates)` | Find nearest point |
| `findFarthest(origin, candidates)` | Find farthest point |
| `sortByDistance(origin, points)` | Sort by distance |
| `filterByRadius(origin, points, radius)` | Filter within radius |
| `isWithinDistance(p1, p2, maxDistance)` | Check distance threshold |

#### GeoCircleService

| Method | Description |
|--------|-------------|
| `isInsideCircle(point, circle)` | Check if point is inside |
| `isOutsideCircle(point, circle)` | Check if point is outside |
| `isOnBoundary(point, circle, tolerance)` | Check if on boundary |
| `distanceToBoundary(point, circle)` | Distance to edge |
| `filterInside(points, circle)` | Get points inside |
| `filterOutside(points, circle)` | Get points outside |
| `countInside(points, circle)` | Count inside points |
| `percentageInside(points, circle)` | Percentage inside |
| `circlesOverlap(circle1, circle2)` | Check overlap |
| `containsCircle(outer, inner)` | Check containment |

#### GeoPolygonService

| Method | Description |
|--------|-------------|
| `isInsidePolygon(point, polygon)` | Check if point is inside |
| `isOnBoundary(point, polygon)` | Check if on boundary |
| `isValidPolygon(polygon)` | Validate polygon |
| `isConvex(polygon)` | Check if convex |
| `filterInside(points, polygon)` | Get points inside |
| `filterOutside(points, polygon)` | Get points outside |
| `countInside(points, polygon)` | Count inside points |
| `calculateArea(polygon)` | Calculate area |
| `calculatePerimeter(polygon)` | Calculate perimeter |
| `getBoundingBox(polygon)` | Get bounding box |

### Exceptions

| Exception | When Thrown |
|-----------|-------------|
| `InvalidRadiusException` | Invalid radius value |
| `InvalidPolygonException` | Invalid polygon structure |
| `InvalidCoordinateException` | Invalid coordinates |
| `GeoCalculationException` | Calculation failure |

---

## 🧪 Testing

Run the test suite:

```bash
flutter test
```

Run with coverage:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

See [TEST_COVERAGE.md](TEST_COVERAGE.md) for detailed coverage information.

---

## 📊 Performance

| Operation | Complexity | Notes |
|-----------|------------|-------|
| Distance calculation | O(1) | Constant time |
| Circle containment | O(1) | Constant time |
| Polygon containment | O(n) | Linear with vertices |
| Batch filter | O(n×m) | n points, m vertices |

---

## 📐 Accuracy

- **Haversine Formula**: ~0.5% (spherical Earth assumption)
- **Coordinate System**: WGS 84 (GPS standard)
- **Distance Units**: Meters

---

## 💡 Use Cases

- **Delivery Apps**: Check if delivery address is within service area
- **Location-Based Notifications**: Trigger alerts when entering geofence
- **Asset Tracking**: Monitor if vehicles stay within designated zones
- **Gaming**: Create location-based game boundaries
- **Security**: Alert when devices leave secure areas

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure:
- All tests pass
- Code follows Dart style guidelines
- New features include tests
- Documentation is updated

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Haversine formula implementation based on standard geodesic formulas
- Ray casting algorithm following the even-odd rule
- Built for the Flutter/Dart ecosystem

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/geo_fence_utils/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/geo_fence_utils/discussions)

---

<div align="center">

**Made with ❤️ for the Flutter community**

</div>
