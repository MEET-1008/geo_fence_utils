import 'package:flutter_test/flutter_test.dart';
import 'package:geo_fence_utils/exceptions/geo_exceptions.dart';

void main() {
  group('GeoException - Base Exception', () {
    test('should create base exception', () {
      final exc = const GeoException('Something went wrong');

      expect(exc.toString(), contains('GeoException'));
      expect(exc.toString(), contains('Something went wrong'));
    });

    test('should create exception with code', () {
      final exc = const GeoException(
        'Something went wrong',
        code: 'ERROR_CODE',
      );

      expect(exc.toString(), contains('code: ERROR_CODE'));
    });

    test('should create exception with cause', () {
      final cause = Exception('Root cause');
      final exc = GeoException(
        'Something went wrong',
        cause: cause,
      );

      expect(exc.toString(), contains('Caused by'));
    });
  });

  group('InvalidRadiusException', () {
    test('should create exception for negative radius', () {
      final exc = InvalidRadiusException.negative(-100);

      expect(exc.invalidValue, -100);
      expect(exc.toString(), contains('negative'));
      expect(exc.toString(), contains('-100'));
    });

    test('should create exception for zero radius', () {
      final exc = InvalidRadiusException.zero();

      expect(exc.invalidValue, 0);
      expect(exc.toString(), contains('cannot be zero'));
      expect(exc.toString(), contains('ZERO_RADIUS'));
    });

    test('should create exception for too small radius', () {
      final exc = InvalidRadiusException.tooSmall(10, 100);

      expect(exc.invalidValue, 10);
      expect(exc.minValue, 100);
      expect(exc.toString(), contains('at least 100'));
    });

    test('should create exception for too large radius', () {
      final exc = InvalidRadiusException.tooLarge(1000000, 5000);

      expect(exc.invalidValue, 1000000);
      expect(exc.maxValue, 5000);
      expect(exc.toString(), contains('cannot exceed 5000'));
    });
  });

  group('InvalidPolygonException', () {
    test('should create exception for too few vertices', () {
      final exc = InvalidPolygonException.tooFewVertices(2);

      expect(exc.vertexCount, 2);
      expect(exc.toString(), contains('at least 3 vertices'));
      expect(exc.toString(), contains('TOO_FEW_VERTICES'));
    });

    test('should create exception for duplicate vertices', () {
      final exc = InvalidPolygonException.duplicateVertices();

      expect(exc.toString(), contains('duplicate consecutive vertices'));
      expect(exc.toString(), contains('DUPLICATE_VERTICES'));
    });

    test('should create exception for self-intersecting', () {
      final exc = InvalidPolygonException.selfIntersecting();

      expect(exc.toString(), contains('self-intersecting'));
      expect(exc.toString(), contains('SELF_INTERSECTING'));
    });

    test('should create exception with custom detail', () {
      final exc = InvalidPolygonException.invalidStructure('Custom error');

      expect(exc.toString(), contains('Custom error'));
      expect(exc.toString(), contains('INVALID_STRUCTURE'));
    });
  });

  group('InvalidCoordinateException', () {
    test('should create exception for invalid latitude', () {
      final exc = InvalidCoordinateException.invalidLatitude(100);

      expect(exc.latitude, 100);
      expect(exc.toString(), contains('Latitude must be between -90 and 90'));
      expect(exc.toString(), contains('lat: 100'));
    });

    test('should create exception for invalid longitude', () {
      final exc = InvalidCoordinateException.invalidLongitude(200);

      expect(exc.longitude, 200);
      expect(exc.toString(), contains('Longitude must be between -180 and 180'));
      expect(exc.toString(), contains('lon: 200'));
    });

    test('should create exception for both invalid', () {
      final exc = InvalidCoordinateException.invalid(
        latitude: 100,
        longitude: 200,
      );

      expect(exc.latitude, 100);
      expect(exc.longitude, 200);
      expect(exc.toString(), contains('lat: 100'));
      expect(exc.toString(), contains('lon: 200'));
    });

    test('should create exception for non-finite values', () {
      final exc = InvalidCoordinateException.notFinite(
        latitude: double.nan,
        longitude: double.infinity,
      );

      expect(exc.toString(), contains('not finite'));
    });
  });

  group('GeoCalculationException', () {
    test('should create exception for distance failure', () {
      final exc = GeoCalculationException.distanceCalculation();

      expect(exc.operation, 'distance_calculation');
      expect(exc.toString(), contains('Failed to calculate distance'));
      expect(exc.toString(), contains('operation: distance_calculation'));
    });

    test('should create exception with custom detail', () {
      final exc = GeoCalculationException.distanceCalculation(
        'Invalid coordinates provided',
      );

      expect(exc.toString(), contains('Invalid coordinates provided'));
    });

    test('should create exception for bearing failure', () {
      final exc = GeoCalculationException.bearingCalculation();

      expect(exc.operation, 'bearing_calculation');
    });

    test('should create exception for area failure', () {
      final exc = GeoCalculationException.areaCalculation();

      expect(exc.operation, 'area_calculation');
    });
  });

  group('Exception Hierarchy', () {
    test('InvalidRadiusException should be GeoException', () {
      final exc = InvalidRadiusException.zero();

      expect(exc, isA<GeoException>());
    });

    test('InvalidPolygonException should be GeoException', () {
      final exc = InvalidPolygonException.tooFewVertices(2);

      expect(exc, isA<GeoException>());
    });

    test('InvalidCoordinateException should be GeoException', () {
      final exc = InvalidCoordinateException.invalidLatitude(100);

      expect(exc, isA<GeoException>());
    });

    test('GeoCalculationException should be GeoException', () {
      final exc = GeoCalculationException.distanceCalculation();

      expect(exc, isA<GeoException>());
    });
  });

  group('Exception Catching', () {
    test('should catch specific exception types', () {
      try {
        throw InvalidRadiusException.negative(-100);
      } on InvalidRadiusException catch (e) {
        expect(e.invalidValue, -100);
        expect(e, isA<GeoException>());
      }
    });

    test('should catch as GeoException', () {
      try {
        throw InvalidPolygonException.tooFewVertices(2);
      } on GeoException catch (e) {
        expect(e, isA<InvalidPolygonException>());
      }
    });

    test('should catch all exceptions with GeoException', () {
      int caughtType = 0;

      try {
        throw InvalidRadiusException.zero();
      } on GeoException {
        caughtType = 1;
      }

      expect(caughtType, 1);
    });
  });
}
