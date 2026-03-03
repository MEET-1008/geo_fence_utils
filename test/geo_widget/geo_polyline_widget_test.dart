import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fence_utils/geo_fence_utils.dart';

void main() {
  group('GeoPolylineWidget', () {
    late List<GeoPoint> points;

    setUp(() {
      points = const [
        GeoPoint(latitude: 37.7749, longitude: -122.4194),
        GeoPoint(latitude: 37.7849, longitude: -122.4094),
        GeoPoint(latitude: 37.7949, longitude: -122.3994),
      ];
    });

    test('should create a polyline with required parameters', () {
      final polyline = GeoPolylineWidget(
        id: 'test_polyline',
        points: points,
      );

      expect(polyline.id, 'test_polyline');
      expect(polyline.points, points);
      expect(polyline.pointCount, 3);
      expect(polyline.width, 4.0);
      expect(polyline.capStyle, PolylineCap.round);
      expect(polyline.isGeodesic, true);
      expect(polyline.dashPattern, isNull);
      expect(polyline.isInteractive, true);
      expect(polyline.metadata, isEmpty);
    });

    test('should create a route preset', () {
      final polyline = GeoPolylineWidget.route(points: points);

      expect(polyline.id, contains('route_'));
      expect(polyline.strokeColor.value, 0xFF2196F3);
      expect(polyline.width, 5.0);
      expect(polyline.capStyle, PolylineCap.round);
      expect(polyline.isGeodesic, true);
    });

    test('should create a boundary preset', () {
      final polyline = GeoPolylineWidget.boundary(points: points);

      expect(polyline.id, contains('boundary_'));
      expect(polyline.strokeColor.value, 0xFF9E9E9E);
      expect(polyline.width, 2.0);
      expect(polyline.isGeodesic, false);
      expect(polyline.dashPattern, [10, 10]);
    });

    test('should create a navigation path preset', () {
      final polyline = GeoPolylineWidget.navigationPath(points: points);

      expect(polyline.id, contains('nav_path_'));
      expect(polyline.strokeColor.value, 0xFF4CAF50);
      expect(polyline.width, 6.0);
    });

    test('should create a corridor preset', () {
      final polyline = GeoPolylineWidget.corridor(points: points);

      expect(polyline.id, contains('corridor_'));
      expect(polyline.strokeColor.value, 0xFFFF9800);
      expect(polyline.width, 4.0);
    });

    test('should create a flight path preset', () {
      final polyline = GeoPolylineWidget.flightPath(points: points);

      expect(polyline.id, contains('flight_path_'));
      expect(polyline.strokeColor.value, 0xFF9C27B0);
      expect(polyline.dashPattern, [15, 10]);
    });

    test('should validate successfully with valid parameters', () {
      final polyline = GeoPolylineWidget(
        id: 'test',
        points: points,
      );

      expect(() => polyline.validate(), returnsNormally);
    });

    test('should throw StateError when points list is empty', () {
      final polyline = GeoPolylineWidget(
        id: 'test',
        points: const [],
      );

      expect(
        () => polyline.validate(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Polyline must have at least 2 points'),
        )),
      );
    });

    test('should throw StateError when points list has only 1 point', () {
      final polyline = GeoPolylineWidget(
        id: 'test',
        points: const [GeoPoint(latitude: 37.7749, longitude: -122.4194)],
      );

      expect(
        () => polyline.validate(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Polyline must have at least 2 points'),
        )),
      );
    });

    test('should throw StateError when width is zero', () {
      final polyline = GeoPolylineWidget(
        id: 'test',
        points: points,
        width: 0,
      );

      expect(
        () => polyline.validate(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Width must be greater than zero'),
        )),
      );
    });

    test('should throw StateError when width is negative', () {
      final polyline = GeoPolylineWidget(
        id: 'test',
        points: points,
        width: -2.0,
      );

      expect(
        () => polyline.validate(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Width must be greater than zero'),
        )),
      );
    });

    test('should throw StateError when dash pattern is empty', () {
      final polyline = GeoPolylineWidget(
        id: 'test',
        points: points,
        dashPattern: [],
      );

      expect(
        () => polyline.validate(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Dash pattern must not be empty'),
        )),
      );
    });

    test('should convert to map correctly', () {
      final polyline = GeoPolylineWidget(
        id: 'test_polyline',
        points: points,
        width: 5.0,
        capStyle: PolylineCap.butt,
        isGeodesic: false,
        dashPattern: [10, 5],
        metadata: {'key': 'value'},
      );

      final map = polyline.toMap();

      expect(map['id'], 'test_polyline');
      expect(map['type'], 'polyline');
      expect(map['points'], isNotNull);
      expect(map['points'], isList);
      expect((map['points'] as List).length, 3);
      expect(map['width'], 5.0);
      expect(map['capStyle'], 'butt');
      expect(map['isGeodesic'], false);
      expect(map['dashPattern'], [10, 5]);
      expect(map['strokeColor'], isNotNull);
      expect(map['metadata'], {'key': 'value'});
    });

    test('should have correct pointCount', () {
      final polyline = GeoPolylineWidget(
        id: 'test',
        points: points,
      );

      expect(polyline.pointCount, 3);
    });

    test('should compare polylines correctly', () {
      final polyline1 = GeoPolylineWidget(
        id: 'test',
        points: points,
      );

      final polyline2 = GeoPolylineWidget(
        id: 'test',
        points: points,
      );

      final polyline3 = GeoPolylineWidget(
        id: 'other',
        points: points,
      );

      expect(polyline1, equals(polyline2));
      expect(polyline1, isNot(equals(polyline3)));
    });

    test('should have correct hashCode', () {
      final polyline1 = GeoPolylineWidget(
        id: 'test',
        points: points,
      );

      final polyline2 = GeoPolylineWidget(
        id: 'test',
        points: points,
      );

      expect(polyline1.hashCode, equals(polyline2.hashCode));
    });

    test('should have correct toString', () {
      final polyline = GeoPolylineWidget(
        id: 'test',
        points: points,
      );

      final str = polyline.toString();
      expect(str, contains('GeoPolylineWidget'));
      expect(str, contains('test'));
      expect(str, contains('3'));
      expect(str, contains('points'));
    });

    test('should calculate approximate length', () {
      final polyline = GeoPolylineWidget(
        id: 'test',
        points: const [
          GeoPoint(latitude: 37.7749, longitude: -122.4194),
          GeoPoint(latitude: 37.7849, longitude: -122.4094),
        ],
      );

      final length = polyline.approximateLength;
      expect(length, greaterThan(0));
      expect(length, lessThan(5000)); // Should be less than 5km
    });

    test('should have zero length for single point', () {
      final polyline = GeoPolylineWidget(
        id: 'test',
        points: const [GeoPoint(latitude: 37.7749, longitude: -122.4194)],
      );

      expect(polyline.approximateLength, 0);
    });
  });

  group('PolylineCap', () {
    test('should have correct values', () {
      expect(PolylineCap.values.length, 3);
      expect(PolylineCap.values, contains(PolylineCap.butt));
      expect(PolylineCap.values, contains(PolylineCap.round));
      expect(PolylineCap.values, contains(PolylineCap.square));
    });

    test('should have correct names', () {
      expect(PolylineCap.butt.name, 'butt');
      expect(PolylineCap.round.name, 'round');
      expect(PolylineCap.square.name, 'square');
    });
  });
}
