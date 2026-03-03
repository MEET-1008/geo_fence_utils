import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fence_utils/geo_fence_utils.dart';

void main() {
  group('GeoCircleWidget', () {
    late GeoPoint center;

    setUp(() {
      center = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
    });

    test('should create a circle with required parameters', () {
      final circle = GeoCircleWidget(
        id: 'test_circle',
        center: center,
        radius: 500,
      );

      expect(circle.id, 'test_circle');
      expect(circle.center, center);
      expect(circle.radius, 500);
      expect(circle.strokeWidth, 2.0);
      expect(circle.isInteractive, true);
      expect(circle.metadata, isEmpty);
    });

    test('should create a circle with withRadius factory', () {
      final circle = GeoCircleWidget.withRadius(
        center: center,
        radius: 1000,
      );

      expect(circle.id, contains('circle_'));
      expect(circle.center, center);
      expect(circle.radius, 1000);
    });

    test('should create a danger zone preset', () {
      final circle = GeoCircleWidget.dangerZone(
        center: center,
        radius: 800,
      );

      expect(circle.id, contains('danger_'));
      expect(circle.color.value, 0x33F44336);
      expect(circle.borderColor.value, 0xFFF44336);
      expect(circle.strokeWidth, 3.0);
    });

    test('should create a safe zone preset', () {
      final circle = GeoCircleWidget.safeZone(
        center: center,
        radius: 600,
      );

      expect(circle.id, contains('safe_'));
      expect(circle.color.value, 0x334CAF50);
      expect(circle.borderColor.value, 0xFF4CAF50);
      expect(circle.strokeWidth, 2.0);
    });

    test('should create a warning zone preset', () {
      final circle = GeoCircleWidget.warningZone(
        center: center,
        radius: 700,
      );

      expect(circle.id, contains('warning_'));
      expect(circle.color.value, 0x33FF9800);
      expect(circle.borderColor.value, 0xFFFF9800);
      expect(circle.strokeWidth, 2.5);
    });

    test('should create a no fly zone preset', () {
      final circle = GeoCircleWidget.noFlyZone(
        center: center,
        radius: 500,
      );

      expect(circle.id, contains('nofly_'));
      expect(circle.color.value, 0x4DFF0000);
      expect(circle.borderColor.value, 0xFFFF0000);
      expect(circle.strokeWidth, 4.0);
    });

    test('should validate successfully with valid parameters', () {
      final circle = GeoCircleWidget(
        id: 'test',
        center: center,
        radius: 500,
      );

      expect(() => circle.validate(), returnsNormally);
    });

    test('should throw StateError when radius is zero', () {
      final circle = GeoCircleWidget(
        id: 'test',
        center: center,
        radius: 0,
      );

      expect(
        () => circle.validate(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Radius must be greater than zero'),
        )),
      );
    });

    test('should throw StateError when radius is negative', () {
      final circle = GeoCircleWidget(
        id: 'test',
        center: center,
        radius: -100,
      );

      expect(
        () => circle.validate(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Radius must be greater than zero'),
        )),
      );
    });

    test('should throw StateError when stroke width is negative', () {
      final circle = GeoCircleWidget(
        id: 'test',
        center: center,
        radius: 500,
        strokeWidth: -2.0,
      );

      expect(
        () => circle.validate(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Stroke width must be non-negative'),
        )),
      );
    });

    test('should convert to map correctly', () {
      final circle = GeoCircleWidget(
        id: 'test_circle',
        center: center,
        radius: 500,
        strokeWidth: 3.0,
        metadata: {'key': 'value'},
      );

      final map = circle.toMap();

      expect(map['id'], 'test_circle');
      expect(map['type'], 'circle');
      expect(map['center'], center.toMap());
      expect(map['radius'], 500);
      expect(map['strokeWidth'], 3.0);
      expect(map['color'], isNotNull);
      expect(map['borderColor'], isNotNull);
      expect(map['metadata'], {'key': 'value'});
    });

    test('should compare circles correctly', () {
      final circle1 = GeoCircleWidget(
        id: 'test',
        center: center,
        radius: 500,
      );

      final circle2 = GeoCircleWidget(
        id: 'test',
        center: center,
        radius: 500,
      );

      final circle3 = GeoCircleWidget(
        id: 'other',
        center: center,
        radius: 500,
      );

      expect(circle1, equals(circle2));
      expect(circle1, isNot(equals(circle3)));
    });

    test('should have correct hashCode', () {
      final circle1 = GeoCircleWidget(
        id: 'test',
        center: center,
        radius: 500,
      );

      final circle2 = GeoCircleWidget(
        id: 'test',
        center: center,
        radius: 500,
      );

      expect(circle1.hashCode, equals(circle2.hashCode));
    });

    test('should have correct toString', () {
      final circle = GeoCircleWidget(
        id: 'test',
        center: center,
        radius: 500,
      );

      final str = circle.toString();
      expect(str, contains('GeoCircleWidget'));
      expect(str, contains('test'));
      expect(str, contains('500m'));
    });
  });

  group('GeoCircleWidget Presets', () {
    late GeoPoint center;

    setUp(() {
      center = const GeoPoint(latitude: 37.7749, longitude: -122.4194);
    });

    test('danger zone should have correct color values', () {
      final circle = GeoCircleWidget.dangerZone(center: center, radius: 500);
      expect(circle.color.value & 0xFF, 0x36); // Blue channel
      expect(circle.borderColor.value & 0xFF, 0x36); // Red (blue channel)
    });

    test('safe zone should have green color', () {
      final circle = GeoCircleWidget.safeZone(center: center, radius: 500);
      expect(circle.borderColor.value, 0xFF4CAF50);
    });

    test('warning zone should have orange color', () {
      final circle = GeoCircleWidget.warningZone(center: center, radius: 500);
      expect(circle.borderColor.value, 0xFFFF9800);
    });
  });
}
