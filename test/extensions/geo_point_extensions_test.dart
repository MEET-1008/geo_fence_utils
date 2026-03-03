import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fence_utils/geo_fence_utils.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('GeoPointExtensions', () {
    late GeoPoint point;

    setUp(() {
      point = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
    });

    test('should convert to flutter_map LatLng', () {
      final latLng = point.toFlutterLatLng();

      expect(latLng, isA<LatLng>());
      expect(latLng.latitude, 37.7749);
      expect(latLng.longitude, -122.4194);
    });

    test('should convert to google_maps_flutter LatLng', () {
      final googleLatLng = point.toGoogleLatLng();

      expect(googleLatLng.latitude, 37.7749);
      expect(googleLatLng.longitude, -122.4194);
    });

    test('should handle negative coordinates', () {
      final point = const GeoPoint(latitude: -33.8688, longitude: 151.2093);
      final latLng = point.toFlutterLatLng();

      expect(latLng.latitude, -33.8688);
      expect(latLng.longitude, 151.2093);
    });

    test('should handle edge case coordinates', () {
      final point = const GeoPoint(latitude: 0, longitude: 0);
      final latLng = point.toFlutterLatLng();

      expect(latLng.latitude, 0);
      expect(latLng.longitude, 0);
    });
  });

  group('GeoPointListExtensions', () {
    late List<GeoPoint> points;

    setUp(() {
      points = const [
        GeoPoint(latitude: 37.7749, longitude: -122.4194),
        GeoPoint(latitude: 37.7849, longitude: -122.4094),
        GeoPoint(latitude: 37.7949, longitude: -122.3994),
      ];
    });

    test('should convert list to flutter_map LatLng list', () {
      final latLngs = points.toFlutterLatLngList();

      expect(latLngs, isA<List<LatLng>>());
      expect(latLngs.length, 3);
      expect(latLngs[0].latitude, 37.7749);
      expect(latLngs[0].longitude, -122.4194);
      expect(latLngs[1].latitude, 37.7849);
      expect(latLngs[1].longitude, -122.4094);
      expect(latLngs[2].latitude, 37.7949);
      expect(latLngs[2].longitude, -122.3994);
    });

    test('should convert list to google_maps_flutter LatLng list', () {
      final googleLatLngs = points.toGoogleLatLngList();

      expect(googleLatLngs, isA<List>());
      expect(googleLatLngs.length, 3);
      expect(googleLatLngs[0].latitude, 37.7749);
      expect(googleLatLngs[0].longitude, -122.4194);
    });

    test('should handle empty list', () {
      final emptyPoints = <GeoPoint>[];
      final latLngs = emptyPoints.toFlutterLatLngList();

      expect(latLngs, isEmpty);
    });

    test('should handle single point list', () {
      final singlePoint = const [
        GeoPoint(latitude: 37.7749, longitude: -122.4194),
      ];
      final latLngs = singlePoint.toFlutterLatLngList();

      expect(latLngs.length, 1);
      expect(latLngs[0].latitude, 37.7749);
    });

    test('should convert to latlong2 list', () {
      final latLngs = points.toLatLong2List();

      expect(latLngs, isA<List<LatLng>>());
      expect(latLngs.length, 3);
      expect(latLngs[0].latitude, 37.7749);
      expect(latLngs[0].longitude, -122.4194);
    });
  });

  group('LatLngExtensions', () {
    test('should convert flutter_map LatLng to GeoPoint', () {
      final latLng = LatLng(37.7749, -122.4194);
      final point = latLng.toGeoPoint();

      expect(point, isA<GeoPoint>());
      expect(point.latitude, 37.7749);
      expect(point.longitude, -122.4194);
    });

    test('should handle negative coordinates in conversion', () {
      final latLng = LatLng(-33.8688, 151.2093);
      final point = latLng.toGeoPoint();

      expect(point.latitude, -33.8688);
      expect(point.longitude, 151.2093);
    });

    test('should handle edge case coordinates in conversion', () {
      final latLng = LatLng(0, 0);
      final point = latLng.toGeoPoint();

      expect(point.latitude, 0);
      expect(point.longitude, 0);
    });
  });

  group('Coordinate Conversion Round Trips', () {
    test('should maintain precision in round trip conversion', () {
      final original = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
      final latLng = original.toFlutterLatLng();
      final converted = latLng.toGeoPoint();

      expect(converted.latitude, closeTo(original.latitude, 0.00001));
      expect(converted.longitude, closeTo(original.longitude, 0.00001));
    });

    test('should handle list round trip conversion', () {
      final original = const [
        GeoPoint(latitude: 37.7749, longitude: -122.4194),
        GeoPoint(latitude: 37.7849, longitude: -122.4094),
      ];
      final latLngs = original.toFlutterLatLngList();
      final converted = latLngs.map((ll) => ll.toGeoPoint()).toList();

      expect(converted.length, original.length);
      expect(converted[0].latitude, original[0].latitude);
      expect(converted[0].longitude, original[0].longitude);
      expect(converted[1].latitude, original[1].latitude);
      expect(converted[1].longitude, original[1].longitude);
    });
  });
}
