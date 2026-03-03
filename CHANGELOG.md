# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.0.0]: https://github.com/yourusername/geo_fence_utils/releases/tag/v1.0.0
