import 'package:flutter/material.dart';
import 'package:geo_fence_utils/geo_fence_utils.dart';

/// Example app demonstrating the geo_widget module.
///
/// This example shows how to use the GeoGeofenceMap widget to display
/// various types of geofences on interactive maps.
///
/// **Features demonstrated:**
/// - Simple circle geofence
/// - Multiple geofences of different types
/// - Interactive map with callbacks
/// - Different map providers (flutter_map and google_map)
/// - Preset geofence styles (danger zone, safe zone, etc.)
///
/// **To run:**
/// ```bash
/// cd example
/// flutter run geo_widget_example.dart
/// ```
///
/// **For Google Maps:**
/// Set your API key in the `googleMapsApiKey` variable below.
void main() {
  runApp(const GeoWidgetExample());
}

class GeoWidgetExample extends StatelessWidget {
  const GeoWidgetExample({super.key});

  // Replace with your Google Maps API key to use Google Maps provider
  static const String googleMapsApiKey = ''; // 'YOUR_API_KEY_HERE';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo Fence Utils - Map Widget Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  int _selectedExample = 0;

  final List<Example> _examples = const [
    Example(
      title: 'Simple Circle',
      description: 'A single circular geofence',
      provider: MapProvider.flutterMap,
    ),
    Example(
      title: 'Multiple Geofences',
      description: 'Circles, polygons, and polylines',
      provider: MapProvider.flutterMap,
    ),
    Example(
      title: 'Preset Zones',
      description: 'Danger, safe, and warning zones',
      provider: MapProvider.flutterMap,
    ),
    Example(
      title: 'Interactive Map',
      description: 'With tap and long press callbacks',
      provider: MapProvider.flutterMap,
    ),
    Example(
      title: 'Google Maps',
      description: 'Using Google Maps provider',
      provider: MapProvider.googleMap,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geo Fence Utils - Map Widgets'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          // Sidebar with examples
          SizedBox(
            width: 250,
            child: ListView.builder(
              itemCount: _examples.length,
              itemBuilder: (context, index) {
                final example = _examples[index];
                final isSelected = _selectedExample == index;

                return ListTile(
                  title: Text(
                    example.title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(example.description),
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedExample = index;
                    });
                  },
                );
              },
            ),
          ),
          // Main content area
          Expanded(
            child: _buildExampleContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleContent() {
    switch (_selectedExample) {
      case 0:
        return _buildSimpleCircleExample();
      case 1:
        return _buildMultipleGeofencesExample();
      case 2:
        return _buildPresetZonesExample();
      case 3:
        return _buildInteractiveExample();
      case 4:
        return _buildGoogleMapsExample();
      default:
        return const Center(child: Text('Select an example'));
    }
  }

  Widget _buildSimpleCircleExample() {
    return GeoGeofenceMap(
      center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
      zoom: 14.0,
      geofences: [
        GeoCircleWidget.withRadius(
          center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
          radius: 500,
        ),
      ],
      provider: MapProvider.flutterMap,
      showZoomControls: true,
    );
  }

  Widget _buildMultipleGeofencesExample() {
    return GeoGeofenceMap(
      center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
      zoom: 13.0,
      geofences: [
        // Circle geofence
        GeoCircleWidget(
          id: 'main_circle',
          center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
          radius: 1000,
          color: const Color(0x332196F3),
          borderColor: const Color(0xFF2196F3),
          strokeWidth: 2.0,
        ),
        // Polygon geofence
        GeoPolygonWidget.fromBounds(
          north: 37.78,
          south: 37.76,
          east: -122.40,
          west: -122.42,
        ),
        // Polyline route
        GeoPolylineWidget.route(
          points: const [
            GeoPoint(latitude: 37.7749, longitude: -122.4194),
            GeoPoint(latitude: 37.7849, longitude: -122.4094),
            GeoPoint(latitude: 37.7949, longitude: -122.3994),
          ],
        ),
      ],
      provider: MapProvider.flutterMap,
      showZoomControls: true,
    );
  }

  Widget _buildPresetZonesExample() {
    return GeoGeofenceMap(
      center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
      zoom: 12.0,
      geofences: [
        // Danger zone
        GeoCircleWidget.dangerZone(
          center: const GeoPoint(latitude: 37.7649, longitude: -122.4294),
          radius: 800,
        ),
        // Safe zone
        GeoCircleWidget.safeZone(
          center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
          radius: 600,
        ),
        // Warning zone
        GeoCircleWidget.warningZone(
          center: const GeoPoint(latitude: 37.7849, longitude: -122.4094),
          radius: 700,
        ),
        // No fly zone
        GeoCircleWidget.noFlyZone(
          center: const GeoPoint(latitude: 37.7549, longitude: -122.4394),
          radius: 500,
        ),
        // Secure zone polygon
        GeoPolygonWidget.secureZone(
          points: const [
            GeoPoint(latitude: 37.79, longitude: -122.41),
            GeoPoint(latitude: 37.80, longitude: -122.40),
            GeoPoint(latitude: 37.79, longitude: -122.39),
          ],
        ),
        // Perimeter polygon
        GeoPolygonWidget.perimeter(
          points: const [
            GeoPoint(latitude: 37.76, longitude: -122.44),
            GeoPoint(latitude: 37.76, longitude: -122.42),
            GeoPoint(latitude: 37.75, longitude: -122.42),
            GeoPoint(latitude: 37.75, longitude: -122.44),
          ],
        ),
      ],
      provider: MapProvider.flutterMap,
      showZoomControls: true,
    );
  }

  Widget _buildInteractiveExample() {
    return GeoGeofenceMap(
      center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
      zoom: 13.0,
      geofences: [
        GeoCircleWidget.withRadius(
          center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
          radius: 800,
        ),
      ],
      provider: MapProvider.flutterMap,
      showZoomControls: true,
      onGeofenceTap: (id) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Geofence tapped: $id')),
        );
      },
      onMapTap: (location) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Map tapped: ${location.latitude.toStringAsFixed(4)}, '
              '${location.longitude.toStringAsFixed(4)}',
            ),
          ),
        );
      },
      onMapLongPress: (location) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Long press: ${location.latitude.toStringAsFixed(4)}, '
              '${location.longitude.toStringAsFixed(4)}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Widget _buildGoogleMapsExample() {
    if (GeoWidgetExample.googleMapsApiKey.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Google Maps API Key Required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Please set your Google Maps API key in the example file to use this example.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GeoGeofenceMap(
      center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
      zoom: 13.0,
      geofences: [
        GeoCircleWidget.dangerZone(
          center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
          radius: 1000,
        ),
        GeoPolygonWidget.fromBounds(
          north: 37.78,
          south: 37.76,
          east: -122.40,
          west: -122.42,
        ),
        GeoPolylineWidget.navigationPath(
          points: const [
            GeoPoint(latitude: 37.7749, longitude: -122.4194),
            GeoPoint(latitude: 37.7849, longitude: -122.4094),
            GeoPoint(latitude: 37.7949, longitude: -122.3994),
          ],
        ),
      ],
      provider: MapProvider.googleMap,
      googleMapsApiKey: GeoWidgetExample.googleMapsApiKey,
      showZoomControls: true,
    );
  }
}

/// Example data class.
class Example {
  final String title;
  final String description;
  final MapProvider provider;

  const Example({
    required this.title,
    required this.description,
    required this.provider,
  });
}
