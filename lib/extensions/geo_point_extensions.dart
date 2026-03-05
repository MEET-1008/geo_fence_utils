import 'package:google_maps_flutter/google_maps_flutter.dart' as google;
import 'package:latlong2/latlong.dart';
import '../models/geo_point.dart';

/// Extension methods for converting [GeoPoint] to map SDK coordinate types.
///
/// These extensions provide convenient conversion between the internal
/// [GeoPoint] format and the coordinate types used by various map SDKs.
///
/// **Example:**
/// ```dart
/// final point = GeoPoint(latitude: 37.7749, longitude: -122.4194);
///
/// // Convert for flutter_map
/// final latLng = point.toFlutterLatLng();
///
/// // Convert for google_maps_flutter
/// final googleLatLng = point.toGoogleLatLng();
/// ```
extension GeoPointExtensions on GeoPoint {
  /// Converts this [GeoPoint] to a [LatLng] for use with flutter_map.
  ///
  /// **Example:**
  /// ```dart
  /// final point = GeoPoint(latitude: 37.7749, longitude: -122.4194);
  /// final latLng = point.toFlutterLatLng();
  /// print(latLng); // LatLng(37.7749, -122.4194)
  /// ```
  LatLng toFlutterLatLng() {
    return LatLng(latitude, longitude);
  }

  /// Converts this [GeoPoint] to a [google.LatLng] for use with google_maps_flutter.
  ///
  /// **Example:**
  /// ```dart
  /// final point = GeoPoint(latitude: 37.7749, longitude: -122.4194);
  /// final googleLatLng = point.toGoogleLatLng();
  /// print(googleLatLng); // LatLng(37.7749, -122.4194)
  /// ```
  google.LatLng toGoogleLatLng() {
    return google.LatLng(latitude, longitude);
  }
}

/// Extension methods for lists of [GeoPoint].
///
/// Provides batch conversion for collections of geographic points.
///
/// **Example:**
/// ```dart
/// final points = [
///   GeoPoint(latitude: 37.7749, longitude: -122.4194),
///   GeoPoint(latitude: 37.7849, longitude: -122.4094),
/// ];
///
/// // Convert all for flutter_map
/// final latLngs = points.toFlutterLatLngList();
///
/// // Convert all for google_maps_flutter
/// final googleLatLngs = points.toGoogleLatLngList();
/// ```
extension GeoPointListExtensions on List<GeoPoint> {
  /// Converts a list of [GeoPoint] to a list of [LatLng] for flutter_map.
  ///
  /// **Example:**
  /// ```dart
  /// final points = [
  ///   GeoPoint(latitude: 37.7749, longitude: -122.4194),
  ///   GeoPoint(latitude: 37.7849, longitude: -122.4094),
  /// ];
  /// final latLngs = points.toFlutterLatLngList();
  /// ```
  List<LatLng> toFlutterLatLngList() {
    return map((point) => point.toFlutterLatLng()).toList();
  }

  /// Converts a list of [GeoPoint] to a list of [google.LatLng] for google_maps_flutter.
  ///
  /// **Example:**
  /// ```dart
  /// final points = [
  ///   GeoPoint(latitude: 37.7749, longitude: -122.4194),
  ///   GeoPoint(latitude: 37.7849, longitude: -122.4094),
  /// ];
  /// final googleLatLngs = points.toGoogleLatLngList();
  /// ```
  List<google.LatLng> toGoogleLatLngList() {
    return map((point) => point.toGoogleLatLng()).toList();
  }

  /// Converts a list of [GeoPoint] to a list of [LatLng] for latlong2.
  ///
  /// **Example:**
  /// ```dart
  /// final points = [
  ///   GeoPoint(latitude: 37.7749, longitude: -122.4194),
  ///   GeoPoint(latitude: 37.7849, longitude: -122.4094),
  /// ];
  /// final latLngs = points.toLatLong2List();
  /// ```
  List<LatLng> toLatLong2List() {
    return map((point) => LatLng(point.latitude, point.longitude)).toList();
  }
}

/// Extension methods for converting map SDK coordinates back to [GeoPoint].
///
/// These extensions provide convenient conversion from map SDK coordinate
/// types back to the internal [GeoPoint] format.
extension LatLngExtensions on LatLng {
  /// Converts this [LatLng] (from flutter_map) to a [GeoPoint].
  ///
  /// **Example:**
  /// ```dart
  /// final latLng = LatLng(37.7749, -122.4194);
  /// final point = latLng.toGeoPoint();
  /// ```
  GeoPoint toGeoPoint() {
    return GeoPoint(latitude: latitude, longitude: longitude);
  }
}

/// Extension methods for converting Google Maps coordinates to [GeoPoint].
extension GoogleLatLngExtensions on google.LatLng {
  /// Converts this [google.LatLng] to a [GeoPoint].
  ///
  /// **Example:**
  /// ```dart
  /// final latLng = google.LatLng(37.7749, -122.4194);
  /// final point = latLng.toGeoPoint();
  /// ```
  GeoPoint toGeoPoint() {
    return GeoPoint(latitude: latitude, longitude: longitude);
  }
}
