import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fence_utils/geo_fence_utils.dart';

void main() {
  group('MapProvider', () {
    test('should have correct values', () {
      expect(MapProvider.values.length, 3);
      expect(MapProvider.values, contains(MapProvider.flutterMap));
      expect(MapProvider.values, contains(MapProvider.googleMap));
      expect(MapProvider.values, contains(MapProvider.auto));
    });

    test('should have correct display names', () {
      expect(MapProvider.flutterMap.displayName, 'OpenStreetMap (flutter_map)');
      expect(MapProvider.googleMap.displayName, 'Google Maps');
      expect(MapProvider.auto.displayName, 'Auto');
    });

    test('should correctly identify API key requirements', () {
      expect(MapProvider.flutterMap.requiresApiKey, false);
      expect(MapProvider.googleMap.requiresApiKey, true);
      expect(MapProvider.auto.requiresApiKey, false);
    });

    test('should correctly identify free providers', () {
      expect(MapProvider.flutterMap.isFree, true);
      expect(MapProvider.googleMap.isFree, false);
      expect(MapProvider.auto.isFree, true);
    });

    test('should have correct descriptions', () {
      expect(
        MapProvider.flutterMap.description,
        'Free OpenStreetMap tiles, no API key required',
      );
      expect(
        MapProvider.googleMap.description,
        'Requires Google Maps API key, usage may incur costs',
      );
      expect(
        MapProvider.auto.description,
        'Automatically selects best available option',
      );
    });
  });

  group('MapProviderExtension', () {
    test('should provide displayName', () {
      expect(MapProvider.flutterMap.displayName, isNotEmpty);
      expect(MapProvider.googleMap.displayName, isNotEmpty);
      expect(MapProvider.auto.displayName, isNotEmpty);
    });

    test('should provide requiresApiKey', () {
      expect(MapProvider.flutterMap.requiresApiKey, isA<bool>());
      expect(MapProvider.googleMap.requiresApiKey, isA<bool>());
      expect(MapProvider.auto.requiresApiKey, isA<bool>());
    });

    test('should provide isFree', () {
      expect(MapProvider.flutterMap.isFree, isA<bool>());
      expect(MapProvider.googleMap.isFree, isA<bool>());
      expect(MapProvider.auto.isFree, isA<bool>());
    });

    test('should provide description', () {
      expect(MapProvider.flutterMap.description, isNotEmpty);
      expect(MapProvider.googleMap.description, isNotEmpty);
      expect(MapProvider.auto.description, isNotEmpty);
    });
  });

  group('MapProvider Selection Logic', () {
    test('flutterMap should not require API key', () {
      expect(MapProvider.flutterMap.requiresApiKey, false);
      expect(MapProvider.flutterMap.isFree, true);
    });

    test('googleMap should require API key', () {
      expect(MapProvider.googleMap.requiresApiKey, true);
      expect(MapProvider.googleMap.isFree, false);
    });

    test('auto should adapt based on API key availability', () {
      // Auto mode itself doesn't require an API key
      // But the implementation will choose based on availability
      expect(MapProvider.auto.requiresApiKey, false);
      expect(MapProvider.auto.isFree, true);
    });
  });

  group('MapProvider Display Names', () {
    test('should have unique display names', () {
      final names = MapProvider.values.map((p) => p.displayName).toSet();
      expect(names.length, MapProvider.values.length);
    });

    test('should contain provider names', () {
      expect(
        MapProvider.flutterMap.displayName.toLowerCase(),
        contains('openstreetmap'),
      );
      expect(
        MapProvider.googleMap.displayName.toLowerCase(),
        contains('google'),
      );
      expect(
        MapProvider.auto.displayName.toLowerCase(),
        contains('auto'),
      );
    });
  });

  group('MapProvider Cost Considerations', () {
    test('flutterMap should be free', () {
      expect(MapProvider.flutterMap.isFree, true);
      expect(MapProvider.flutterMap.description.toLowerCase(), contains('free'));
      expect(
        MapProvider.flutterMap.description.toLowerCase(),
        contains('no api key'),
      );
    });

    test('googleMap should indicate potential costs', () {
      expect(MapProvider.googleMap.isFree, false);
      expect(
        MapProvider.googleMap.description.toLowerCase(),
        contains('api key'),
      );
    });

    test('auto should mention automatic selection', () {
      expect(
        MapProvider.auto.description.toLowerCase(),
        contains('automatically'),
      );
    });
  });
}
