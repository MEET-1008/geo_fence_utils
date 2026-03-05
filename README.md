<div align="center">

# geo_fence_utils

**A production-ready Dart package for geofence calculations**

[![Pub Version](https://img.shields.io/pub/v/geo_fence_utils)](https://pub.dev/packages/geo_fence_utils)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![Dart](https://img.shields.io/badge/dart-3.0%2B-blue)](https://dart.dev)
[![Tests](https://img.shields.io/badge/tests-187%20passing-success)](TEST_COVERAGE.md)
[![Coverage](https://img.shields.io/badge/coverage-96%25-brightgreen)](TEST_COVERAGE.md)

</div>

---

# What is geo_fence_utils?

**geo_fence_utils** is a comprehensive Flutter/Dart package designed for handling geofence calculations and location-based operations.

It provides utilities for:

* Calculating distances between geographic points
* Detecting whether points lie within circular or polygonal boundaries
* Performing batch operations on multiple locations efficiently

This package is ideal for developers building **location-aware applications** without dealing with complex geographic calculations.

---

# 📸 Screenshots

| Circle Geofence | Polygon Geofence | Custom Markers |
|-----------------|------------------|----------------|
| <img src="doc/circle_example_photo.png" width="250"> | <img src="doc/polygons_example_photos.png" width="250"> | <img src="doc/marker_example_photos.png" width="250"> |

---

# 🎯 Purpose

The primary purpose of this package is to simplify **geospatial calculations** in Flutter and Dart applications.

It handles complex geographic math so you can focus on **building your application logic**.

---

# 🚀 Common Use Cases

* **Delivery & Logistics** – Determine if delivery addresses fall within service areas
* **Location-Based Notifications** – Trigger alerts when users enter or exit zones
* **Asset Tracking** – Monitor vehicles or equipment within boundaries
* **Gaming** – Create location-based game zones
* **Security Systems** – Detect devices leaving authorized areas
* **Attendance Systems** – Check if users are inside allowed locations
* **Ride Sharing** – Match drivers with passengers within radius
* **Marketing** – Send location-based promotions

---

# ✨ Key Features

| Feature                              | Description                              |
| ------------------------------------ | ---------------------------------------- |
| 📏 **Accurate Distance Calculation** | Uses Haversine formula (~0.5% accuracy)  |
| 🔵 **Circle Geofence**               | Efficient point-in-circle detection      |
| 🔺 **Polygon Geofence**              | Ray casting algorithm for complex shapes |
| ⚡ **Batch Operations**               | Process many points efficiently          |
| 🗺 **Map Widgets**                   | Works with Flutter Map and Google Maps   |
| 📍 **Custom Markers**                | Support PNG and SVG markers              |
| 🌍 **Cross Platform**                | Works on iOS, Android, Web, Desktop      |
| 🧪 **Well Tested**                   | 187 tests with 96% coverage              |
| 🧩 **Pure Dart**                     | No native dependencies                   |
| 🔒 **Type Safe**                     | Full null safety support                 |

---

# 📦 Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  geo_fence_utils: ^2.0.0
```

Then run:

```bash
flutter pub get
```

Or use Flutter CLI:

```bash
flutter pub add geo_fence_utils
```

---



# 📚 Documentation

Full usage examples are available in the **example app**.

➡ See example usage here:

`example/README.md`

The example demonstrates:

* Creating geofence circles
* Creating polygon boundaries
* Drawing polylines
* Adding custom markers
* Displaying geofences on maps
* Running geofence detection logic

---


# 🧩 Package Overview
## Core Models
The package provides three main data models:

* **GeoPoint** – Represents a geographic coordinate
* **GeoCircle** – Circular geofence with center and radius
* **GeoPolygon** – Polygon geofence with multiple vertices

---

## Services

Three main service classes handle operations:

* **GeoDistanceService**

    * Calculate distance between points
    * Find closest or farthest point

* **GeoCircleService**

    * Check points inside circles
    * Detect circle overlap

* **GeoPolygonService**

    * Point inside polygon
    * Polygon area and perimeter

---

## Map Widgets

Interactive widgets for visualizing geofences:

* **GeoGeofenceMap** – Main map widget
* **GeoCircleWidget** – Circular geofence display
* **GeoPolygonWidget** – Polygon geofence display
* **GeoPolylineWidget** – Route and path display
* **GeoMarkerWidget** – Custom markers (PNG/SVG)

---

# ⚙ Technical Details

* **Coordinate System:** WGS 84 (GPS standard)
* **Distance Formula:** Haversine
* **Distance Units:** Meters
* **Supported Platforms:**

    * iOS
    * Android
    * Web
    * Windows
    * macOS
    * Linux

---

# ⚡ Performance

| Operation            | Time Complexity | Notes                |
| -------------------- | --------------- | -------------------- |
| Distance calculation | O(1)            | Constant time        |
| Circle containment   | O(1)            | Constant time        |
| Polygon containment  | O(n)            | Linear with vertices |
| Batch filtering      | O(n×m)          | n points, m vertices |

---

# 📚 Documentation & Resources

* **API Docs:** https://pub.dev/packages/geo_fence_utils
* **Test Coverage:** [TEST_COVERAGE.md](TEST_COVERAGE.md)
* **Example App:** `/example` directory
* **Issues:** https://github.com/MEET-1008/geo_fence_utils/issues
* **Discussions:** https://github.com/MEET-1008/geo_fence_utils/discussions

---

# 🧪 Testing

Run tests:

```bash
flutter test
```

Generate coverage report:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

# 🤝 Contributing

Contributions are welcome.

Please ensure:

* All tests pass
* Code follows Dart style guidelines
* New features include tests
* Documentation updated

Steps:

1. Fork repository
2. Create feature branch
3. Commit changes
4. Push branch
5. Open Pull Request

---

# 📄 License

This project is licensed under the **MIT License**.

See the [LICENSE](LICENSE) file for details.

---

<div align="center">

Built with ❤️ for the Flutter/Dart community

</div>
