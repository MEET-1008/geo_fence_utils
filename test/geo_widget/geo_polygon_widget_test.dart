import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fence_utils/geo_fence_utils.dart';

void main() {
  group('GeoPolygonWidget', () {
    late List<GeoPoint> points;

    setUp(() {
      points = const [
        GeoPoint(latitude: 37.7749, longitude: -122.4194),
        GeoPoint(latitude: 37.7849, longitude: -122.4094),
        GeoPoint(latitude: 37.7649, longitude: -122.4094),
      ];
    });

    test('should create a polygon with required parameters', () {
      final polygon = GeoPolygonWidget(
        id: 'test_polygon',
        points: points,
      );

      expect(polygon.id, 'test_polygon');
      expect(polygon.points, points);
      expect(polygon.vertexCount, 3);
      expect(polygon.strokeWidth, 2.0);
      expect(polygon.isInteractive, true);
      expect(polygon.metadata, isEmpty);
    });

    test('should create a polygon from bounds', () {
      final polygon = GeoPolygonWidget.fromBounds(
        north: 37.78,
        south: 37.76,
        east: -122.40,
        west: -122.42,
      );

      expect(polygon.points.length, 4);
      expect(polygon.points[0].latitude, 37.78);
      expect(polygon.points[0].longitude, -122.42);
      expect(polygon.points[2].latitude, 37.76);
      expect(polygon.points[2].longitude, -122.40);
    });

    test('should create a polygon from coordinates', () {
      final coordinates = [
        [37.7749, -122.4194],
        [37.7849, -122.4094],
        [37.7649, -122.4094],
      ];

      final polygon = GeoPolygonWidget.fromCoordinates(
        coordinates: coordinates,
      );

      expect(polygon.points.length, 3);
      expect(polygon.points[0].latitude, 37.7749);
      expect(polygon.points[0].longitude, -122.4194);
    });

    test('should create a restricted area preset', () {
      final polygon = GeoPolygonWidget.restrictedArea(points: points);

      expect(polygon.id, contains('restricted_'));
      expect(polygon.color.value, 0x4D000000);
      expect(polygon.borderColor.value, 0xFFFF0000);
      expect(polygon.strokeWidth, 3.0);
    });

    test('should create a perimeter preset', () {
      final polygon = GeoPolygonWidget.perimeter(points: points);

      expect(polygon.id, contains('perimeter_'));
      expect(polygon.color.value, 0x1A2196F3);
      expect(polygon.borderColor.value, 0xFF2196F3);
      expect(polygon.strokeWidth, 2.5);
    });

    test('should create a secure zone preset', () {
      final polygon = GeoPolygonWidget.secureZone(points: points);

      expect(polygon.id, contains('secure_'));
      expect(polygon.color.value, 0x334CAF50);
      expect(polygon.borderColor.value, 0xFF4CAF50);
      expect(polygon.strokeWidth, 3.0);
    });

    test('should validate successfully with valid parameters', () {
      final polygon = GeoPolygonWidget(
        id: 'test',
        points: points,
      );

      expect(() => polygon.validate(), returnsNormally);
    });

    test('should throw StateError when points list is empty', () {
      final polygon = GeoPolygonWidget(
        id: 'test',
        points: [],
      );

      expect(
        () => polygon.validate(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Polygon must have at least 3 points'),
        )),
      );
    });

    test('should throw StateError when points list has less than 3 points', () {
      final polygon = GeoPolygonWidget(
        id: 'test',
        points: points.sublist(0, 2),
      );

      expect(
        () => polygon.validate(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Polygon must have at least 3 points'),
        )),
      );
    });

    test('should throw StateError when stroke width is negative', () {
      final polygon = GeoPolygonWidget(
        id: 'test',
        points: points,
        strokeWidth: -2.0,
      );

      expect(
        () => polygon.validate(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Stroke width must be non-negative'),
        )),
      );
    });

    test('should convert to map correctly', () {
      final polygon = GeoPolygonWidget(
        id: 'test_polygon',
        points: points,
        strokeWidth: 3.0,
        metadata: {'key': 'value'},
      );

      final map = polygon.toMap();

      expect(map['id'], 'test_polygon');
      expect(map['type'], 'polygon');
      expect(map['points'], isNotNull);
      expect(map['points'], isList);
      expect((map['points'] as List).length, 3);
      expect(map['strokeWidth'], 3.0);
      expect(map['color'], isNotNull);
      expect(map['borderColor'], isNotNull);
      expect(map['metadata'], {'key': 'value'});
    });

    test('should calculate centroid correctly', () {
      final polygon = GeoPolygonWidget(
        id: 'test',
        points: points,
      );

      final centroid = polygon.centroid;

      expect(centroid.latitude, closeTo(37.7749, 0.0001));
      expect(centroid.longitude, closeTo(-122.4127, 0.0001));
    });

    test('should throw StateError when calculating centroid of empty polygon', () {
      final polygon = GeoPolygonWidget(
        id: 'test',
        points: const [],
      );

      expect(
        () => polygon.centroid,
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Cannot compute centroid of empty polygon'),
        )),
      );
    });

    test('should compare polygons correctly', () {
      final polygon1 = GeoPolygonWidget(
        id: 'test',
        points: points,
      );

      final polygon2 = GeoPolygonWidget(
        id: 'test',
        points: points,
      );

      final polygon3 = GeoPolygonWidget(
        id: 'other',
        points: points,
      );

      expect(polygon1, equals(polygon2));
      expect(polygon1, isNot(equals(polygon3)));
    });

    test('should have correct hashCode', () {
      final polygon1 = GeoPolygonWidget(
        id: 'test',
        points: points,
      );

      final polygon2 = GeoPolygonWidget(
        id: 'test',
        points: points,
      );

      expect(polygon1.hashCode, equals(polygon2.hashCode));
    });

    test('should have correct toString', () {
      final polygon = GeoPolygonWidget(
        id: 'test',
        points: points,
      );

      final str = polygon.toString();
      expect(str, contains('GeoPolygonWidget'));
      expect(str, contains('test'));
      expect(str, contains('3'));
    });

    test('should have correct vertexCount', () {
      final polygon = GeoPolygonWidget(
        id: 'test',
        points: points,
      );

      expect(polygon.vertexCount, 3);
    });
  });

  group('GeoPolygonWidget Presets', () {
    late List<GeoPoint> points;

    setUp(() {
      points = const [
        GeoPoint(latitude: 37.7749, longitude: -122.4194),
        GeoPoint(latitude: 37.7849, longitude: -122.4094),
        GeoPoint(latitude: 37.7649, longitude: -122.4094),
      ];
    });

    test('restricted area should have red border', () {
      final polygon = GeoPolygonWidget.restrictedArea(points: points);
      expect(polygon.borderColor.value, 0xFFFF0000);
    });

    test('perimeter should have blue color', () {
      final polygon = GeoPolygonWidget.perimeter(points: points);
      expect(polygon.borderColor.value, 0xFF2196F3);
    });

    test('secure zone should have green color', () {
      final polygon = GeoPolygonWidget.secureZone(points: points);
      expect(polygon.borderColor.value, 0xFF4CAF50);
    });
  });
}
