/// Example usage of the geo_fence_utils package
///
/// This file demonstrates how to use the various features of the
/// geo_fence_utils package for geofence calculations.
library;

import 'package:geo_fence_utils/geo_fence_utils.dart';

void main() {
  print('=== Geo Fence Utils Examples ===\n');

  // 1. Distance Calculation
  example1_distanceCalculation();

  // 2. Circle Geofence
  example2_circleGeofence();

  // 3. Polygon Geofence
  example3_polygonGeofence();

  // 4. Batch Operations
  example4_batchOperations();

  // 5. Find Closest Point
  example5_findClosest();

  // 6. Sort by Distance
  example6_sortByDistance();

  // 7. Distance to Boundary
  example7_distanceToBoundary();

  // 8. Rectangle Polygon
  example8_rectanglePolygon();

  // 9. Circle Overlap Detection
  example9_circleOverlap();

  // 10. Bounding Box Optimization
  example10_boundingBox();

  print('\n=== All examples completed ===');
}

/// Example 1: Distance Calculation
///
/// Calculate the distance between two geographical points.
void example1_distanceCalculation() {
  print('1. Distance Calculation');
  print('   -------------------');

  final sf = GeoPoint(latitude: 37.7749, longitude: -122.4194); // San Francisco
  final nyc = GeoPoint(latitude: 40.7128, longitude: -74.0060); // New York

  final distance = GeoDistanceService.calculateDistance(sf, nyc);

  print('   SF: (${sf.latitude}, ${sf.longitude})');
  print('   NYC: (${nyc.latitude}, ${nyc.longitude})');
  print('   Distance: ${(distance / 1000).toStringAsFixed(1)} km\n');
}

/// Example 2: Circle Geofence
///
/// Check if points are within a circular geofence.
void example2_circleGeofence() {
  print('2. Circle Geofence');
  print('   ---------------');

  final circle = GeoCircle(
    center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
    radius: 500, // 500 meters
  );

  final points = [
    GeoPoint(latitude: 37.7750, longitude: -122.4195), // Inside
    GeoPoint(latitude: 37.7800, longitude: -122.4100), // Outside
  ];

  for (final point in points) {
    final inside = GeoCircleService.isInsideCircle(
      point: point,
      circle: circle,
    );

    print('   Point (${point.latitude}, ${point.longitude}): ${inside ? "INSIDE" : "OUTSIDE"}');
  }
  print('');
}

/// Example 3: Polygon Geofence
///
/// Check if points are within a polygon geofence.
void example3_polygonGeofence() {
  print('3. Polygon Geofence');
  print('   ----------------');

  final polygon = GeoPolygon(points: [
    GeoPoint(latitude: 37.7749, longitude: -122.4194),
    GeoPoint(latitude: 37.7849, longitude: -122.4094),
    GeoPoint(latitude: 37.7649, longitude: -122.4094),
  ]);

  final points = [
    GeoPoint(latitude: 37.7750, longitude: -122.4180), // Inside
    GeoPoint(latitude: 37.7650, longitude: -122.4050), // Outside
  ];

  for (final point in points) {
    final inside = GeoPolygonService.isInsidePolygon(
      point: point,
      polygon: polygon,
    );

    print('   Point (${point.latitude}, ${point.longitude}): ${inside ? "INSIDE" : "OUTSIDE"}');
  }
  print('');
}

/// Example 4: Batch Operations
///
/// Filter multiple points at once.
void example4_batchOperations() {
  print('4. Batch Operations');
  print('   ----------------');

  final circle = GeoCircle(
    center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
    radius: 1000,
  );

  final points = [
    GeoPoint(latitude: 37.7750, longitude: -122.4195),
    GeoPoint(latitude: 37.7800, longitude: -122.4100),
    GeoPoint(latitude: 40.7128, longitude: -74.0060), // Far away
    GeoPoint(latitude: 37.7700, longitude: -122.4200),
  ];

  final insidePoints = GeoCircleService.filterInside(
    points: points,
    circle: circle,
  );

  final count = GeoCircleService.countInside(
    points: points,
    circle: circle,
  );

  final percentage = GeoCircleService.percentageInside(
    points: points,
    circle: circle,
  );

  print('   Total points: ${points.length}');
  print('   Points inside: $count');
  print('   Percentage: ${percentage.toStringAsFixed(1)}%');
  print('   Inside points:');
  for (final point in insidePoints) {
    print('     - (${point.latitude}, ${point.longitude})');
  }
  print('');
}

/// Example 5: Find Closest Point
///
/// Find the nearest point from a list of candidates.
void example5_findClosest() {
  print('5. Find Closest Point');
  print('   -------------------');

  final origin = GeoPoint(latitude: 37.7749, longitude: -122.4194);

  final candidates = [
    GeoPoint(latitude: 37.78, longitude: -122.41),
    GeoPoint(latitude: 37.76, longitude: -122.42),
    GeoPoint(latitude: 40.71, longitude: -74.00),
  ];

  final closest = GeoDistanceService.findClosest(origin, candidates);

  if (closest != null) {
    final distance = GeoDistanceService.calculateDistance(origin, closest);
    print('   Origin: (${origin.latitude}, ${origin.longitude})');
    print('   Closest: (${closest.latitude}, ${closest.longitude})');
    print('   Distance: ${distance.toStringAsFixed(0)} meters\n');
  }
}

/// Example 6: Sort by Distance
///
/// Sort points by their distance from a reference point.
void example6_sortByDistance() {
  print('6. Sort by Distance');
  print('   ----------------');

  final origin = GeoPoint(latitude: 37.7749, longitude: -122.4194);

  final points = [
    GeoPoint(latitude: 37.78, longitude: -122.41),
    GeoPoint(latitude: 40.71, longitude: -74.00),
    GeoPoint(latitude: 37.76, longitude: -122.42),
  ];

  final sorted = GeoDistanceService.sortByDistance(origin, points);

  print('   Points sorted by distance from (${origin.latitude}, ${origin.longitude}):');
  for (final point in sorted) {
    final distance = GeoDistanceService.calculateDistance(origin, point);
    print('     - (${point.latitude}, ${point.longitude}): ${(distance / 1000).toStringAsFixed(2)} km');
  }
  print('');
}

/// Example 7: Distance to Boundary
///
/// Find how far a point is from the geofence boundary.
void example7_distanceToBoundary() {
  print('7. Distance to Boundary');
  print('   --------------------');

  final circle = GeoCircle(
    center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
    radius: 500,
  );

  final points = [
    GeoPoint(latitude: 37.7749, longitude: -122.4194), // Center
    GeoPoint(latitude: 37.7750, longitude: -122.4195), // Inside
    GeoPoint(latitude: 37.7800, longitude: -122.4100), // Outside
  ];

  for (final point in points) {
    final distance = GeoCircleService.distanceToBoundary(
      point: point,
      circle: circle,
    );

    String status;
    if (distance < 0) {
      status = '${distance.abs().toStringAsFixed(0)}m inside';
    } else if (distance > 0) {
      status = '${distance.toStringAsFixed(0)}m outside';
    } else {
      status = 'On boundary';
    }

    print('   Point (${point.latitude}, ${point.longitude}): $status');
  }
  print('');
}

/// Example 8: Rectangle Polygon
///
/// Create a rectangular geofence using the factory constructor.
void example8_rectanglePolygon() {
  print('8. Rectangle Polygon');
  print('   ------------------');

  final rect = GeoPolygon.rectangle(
    north: 37.78,
    south: 37.76,
    east: -122.40,
    west: -122.42,
  );

  final points = [
    GeoPoint(latitude: 37.77, longitude: -122.41), // Inside
    GeoPoint(latitude: 37.79, longitude: -122.41), // Outside (north)
    GeoPoint(latitude: 37.77, longitude: -122.39), // Outside (east)
  ];

  print('   Rectangle: N ${rect.points[0].latitude}, S ${rect.points[2].latitude}, '
        'E ${rect.points[1].longitude}, W ${rect.points[0].longitude}');

  for (final point in points) {
    final inside = GeoPolygonService.isInsidePolygon(
      point: point,
      polygon: rect,
    );
    print('   Point (${point.latitude}, ${point.longitude}): ${inside ? "INSIDE" : "OUTSIDE"}');
  }
  print('');
}

/// Example 9: Circle Overlap Detection
///
/// Check if two circles overlap.
void example9_circleOverlap() {
  print('9. Circle Overlap Detection');
  print('   ------------------------');

  final circle1 = GeoCircle(
    center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
    radius: 500,
  );

  final circle2 = GeoCircle(
    center: GeoPoint(latitude: 37.7760, longitude: -122.4180),
    radius: 500,
  );

  final circle3 = GeoCircle(
    center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
    radius: 300,
  );

  final overlaps1_2 = GeoCircleService.circlesOverlap(
    circle1: circle1,
    circle2: circle2,
  );

  final contains3 = GeoCircleService.containsCircle(
    outer: circle1,
    inner: circle3,
  );

  print('   Circle 1 center: (${circle1.center.latitude}, ${circle1.center.longitude}), r=${circle1.radius}m');
  print('   Circle 2 center: (${circle2.center.latitude}, ${circle2.center.longitude}), r=${circle2.radius}m');
  print('   Circle 3 center: (${circle3.center.latitude}, ${circle3.center.longitude}), r=${circle3.radius}m');
  print('   Circle 1 and 2 overlap: $overlaps1_2');
  print('   Circle 1 contains circle 3: $contains3\n');
}

/// Example 10: Bounding Box Optimization
///
/// Use bounding box for fast preliminary filtering.
void example10_boundingBox() {
  print('10. Bounding Box Optimization');
  print('    -------------------------');

  final polygon = GeoPolygon.rectangle(
    north: 37.78,
    south: 37.76,
    east: -122.40,
    west: -122.42,
  );

  final farPoint = GeoPoint(latitude: 40.0, longitude: -122.41);
  final nearPoint = GeoPoint(latitude: 37.77, longitude: -122.41);

  final farPointInBbox = GeoPolygonService.isInBoundingBox(
    point: farPoint,
    polygon: polygon,
  );

  final nearPointInBbox = GeoPolygonService.isInBoundingBox(
    point: nearPoint,
    polygon: polygon,
  );

  final bbox = GeoPolygonService.getBoundingBox(polygon);

  print('   Bounding box:');
  print('     North: ${bbox['north']}');
  print('     South: ${bbox['south']}');
  print('     East: ${bbox['east']}');
  print('     West: ${bbox['west']}');
  print('   Far point (${farPoint.latitude}, ${farPoint.longitude}) in bbox: $farPointInBbox');
  print('   Near point (${nearPoint.latitude}, ${nearPoint.longitude}) in bbox: $nearPointInBbox');
  print('');
}
