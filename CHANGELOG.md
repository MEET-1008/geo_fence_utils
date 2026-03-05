# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-03-05

### Added
- **GeoMarkerWidget** - New map marker system with customizable markers
  - Customizable position, labels, colors, sizes, and styling
  - Custom PNG/SVG image asset support
  - Preset factory methods: location(), store(), warning(), danger(), checkpoint(), poi(), at()
- **markers** parameter to GeoGeofenceMap for displaying multiple markers
- **onMarkerTap** callback for marker interaction handling
- Scroll wheel zoom support for desktop platforms
- Enhanced example app with Material 3 design
- 9 marker examples showcasing all preset styles

### Changed
- Complete UI redesign of example app with modern Material 3 design
- 6 main sections: Circles, Polygons, Polylines, Markers, Scenarios, Services
- Improved geofence tap detection accuracy for circles, polygons, and polylines
- Better control panel layout to prevent overflow errors
- Map status card repositioned to avoid control overlap
- SDK requirement relaxed to '>=3.0.0 <4.0.0' for broader compatibility

### Fixed
- Mouse/touchpad zoom not working on desktop
- Geofence tap detection not working for all geofence types
- "BOTTOM OVERFLOWED BY XX PIXELS" error in control panel
- Null crash when accessing metadata on preset widgets
- Missing IDs in preset geofence widgets causing selection issues
- SegmentedButton layout break on smaller screens
- Map status card overlapping zoom controls
- _tappedLocation not being cleared on page change
- Scenario selection using string parsing (now uses dedicated state)

### Breaking Changes
- GeoGeofenceMap now has a required markers parameter (can be empty list)

## [1.0.2] - 2026-03-03

### Fixed
- update readme.md file

## [1.0.1] - 2026-03-03

### Fixed
- Shortened package description to meet pub.dev requirements (149 characters)
- Repository URL now properly configured for pub.dev verification

## [1.0.0] - 2026-03-03

### Added
- Initial release of geo_fence_utils package
- `GeoPoint` model with latitude/longitude validation
- `GeoCircle` model with area and circumference calculations
- `GeoPolygon` model with vertex count, centroid, and convexity detection
- `GeoDistanceService` for distance calculations using Haversine formula
- `GeoCircleService` for circle-based geofence detection
- `GeoPolygonService` for polygon-based geofence detection using Ray Casting
- Custom exception classes:
  - `GeoException` base exception
  - `InvalidRadiusException` for invalid radius values
  - `InvalidPolygonException` for invalid polygon structures
  - `InvalidCoordinateException` for invalid coordinates
  - `GeoCalculationException` for calculation failures

### Features

#### Distance Calculations
- Great-circle distance calculation using Haversine formula
- Batch distance calculations
- Find closest/farthest points
- Sort points by distance
- Filter points by radius
- Check if points are within distance threshold

#### Circle Geofence
- Point-in-circle detection
- Point-on-boundary detection with configurable tolerance
- Distance to boundary calculation (positive=outside, negative=inside)
- Batch operations: filter inside/outside, count
- Percentage calculation for point sets
- Circle overlap detection
- Circle containment check

#### Polygon Geofence
- Point-in-polygon detection using Ray Casting algorithm
- Point-on-boundary detection
- Polygon validation
- Convexity detection
- Batch operations: filter inside/outside, count
- Area calculation
- Perimeter calculation
- Bounding box calculation
- Optimized containment check using bounding box

#### Utility Functions
- Degree/radian conversions
- Bearing calculations
- Destination point calculation
- Midpoint calculation
- Planar distance approximation

### Testing
- Comprehensive test suite with 187 tests
- 96.044% code coverage (437/455 lines)
- Unit tests for all models and services
- Integration tests for real-world scenarios
- Edge case tests (poles, antipodal points, date line)

### Documentation
- Comprehensive README with examples
- API reference for all public methods
- Performance characteristics
- Accuracy specifications
- Use case examples

[2.0.0]: https://github.com/MEET-1008/geo_fence_utils/releases/tag/v2.0.0
[1.0.2]: https://github.com/MEET-1008/geo_fence_utils/releases/tag/v1.0.2
[1.0.1]: https://github.com/MEET-1008/geo_fence_utils/releases/tag/v1.0.1
[1.0.0]: https://github.com/MEET-1008/geo_fence_utils/releases/tag/v1.0.0
