import 'package:flutter/material.dart';
import 'package:geo_fence_utils/geo_fence_utils.dart';

/// User-friendly demo app for the geo_widget module.
///
/// This example demonstrates an interactive UI where users can:
/// - Input geofence parameters (center, radius, colors)
/// - See the map update in real-time
/// - Select from preset geofence types
/// - Visual feedback on all interactions
///
/// **To run:**
/// ```bash
/// cd example
/// flutter run geo_widget_ui_example.dart
/// ```
void main() {
  runApp(const GeoWidgetUIExample());
}

class GeoWidgetUIExample extends StatefulWidget {
  const GeoWidgetUIExample({super.key});

  @override
  State<GeoWidgetUIExample> createState() => _GeoWidgetUIExampleState();
}

class _GeoWidgetUIExampleState extends State<GeoWidgetUIExample> {
  // Map configuration
  double _latitude = 37.7749;
  double _longitude = -122.4194;
  double _zoom = 13.0;
  MapProvider _selectedProvider = MapProvider.flutterMap;
  String _googleMapsApiKey = '';

  // Circle geofence parameters
  bool _showCircle = true;
  double _circleRadius = 500;
  Color _circleColor = Colors.blue;
  Color _circleBorderColor = Colors.blue;
  double _circleStrokeWidth = 2.0;
  bool _circleInteractive = true;

  // Polygon geofence parameters
  bool _showPolygon = false;
  final List<GeoPoint> _polygonPoints = [];

  // Polyline parameters
  bool _showPolyline = false;
  final List<GeoPoint> _polylinePoints = [];

  // Tapped geofence info
  String? _tappedGeofenceId;
  String? _tappedLocation;

  // Preset selection
  CirclePreset _selectedPreset = CirclePreset.none;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo Fence Utils - Interactive Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Geofence Map Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showInfoDialog(context),
              tooltip: 'About',
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return _buildDesktopLayout(context);
            }
            return _buildMobileLayout(context);
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Control panel - left sidebar
        SizedBox(
          width: 350,
          child: _buildControlPanel(context),
        ),
        // Map display - right side
        Expanded(
          child: _buildMapDisplay(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // Map display - top
        Expanded(
          flex: 2,
          child: _buildMapDisplay(),
        ),
        // Control panel - bottom
        Expanded(
          flex: 3,
          child: _buildControlPanel(context),
        ),
      ],
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Map Settings Section
          _buildSectionHeader('Map Settings', Icons.map),
          const SizedBox(height: 12),
          _buildLatLongInputs(),
          const SizedBox(height: 16),
          _buildZoomSlider(),
          const SizedBox(height: 16),
          _buildProviderSelector(),
          const SizedBox(height: 24),

          // Circle Geofence Section
          _buildSectionHeader('Circle Geofence', Icons.radio_button_unchecked),
          const SizedBox(height: 12),
          _buildCirclePresetSelector(),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Show Circle'),
            subtitle: const Text('Display circle geofence on map'),
            value: _showCircle,
            onChanged: (value) => setState(() => _showCircle = value),
          ),
          if (_showCircle) ...[
            const SizedBox(height: 12),
            _buildRadiusSlider(),
            const SizedBox(height: 12),
            _buildColorPickers(),
            const SizedBox(height: 12),
            _buildStrokeWidthSlider(),
          ],
          const SizedBox(height: 24),

          // Polygon Geofence Section
          _buildSectionHeader('Polygon Geofence', Icons.change_history),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Show Polygon'),
            subtitle: const Text('Display polygon geofence on map'),
            value: _showPolygon,
            onChanged: (value) => setState(() => _showPolygon = value),
          ),
          if (_showPolygon) ...[
            const SizedBox(height: 12),
            _buildPresetPolygonsSection(),
          ],
          const SizedBox(height: 24),

          // Polyline Section
          _buildSectionHeader('Polyline', Icons.show_chart),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Show Polyline'),
            subtitle: const Text('Display polyline on map'),
            value: _showPolyline,
            onChanged: (value) => setState(() => _showPolyline = value),
          ),
          if (_showPolyline) ...[
            const SizedBox(height: 12),
            _buildPresetPolylinesSection(),
          ],
          const SizedBox(height:24),

          // Info section
          _buildSectionHeader('Status', Icons.info),
          const SizedBox(height: 12),
          _buildStatusCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLatLongInputs() {
    return Column(
      children: [
        TextFormField(
          key: const Key('lat_input'),
          decoration: const InputDecoration(
            labelText: 'Latitude',
            hintText: 'Enter latitude (-90 to 90)',
            prefixIcon: Icon(Icons.location_on),
            isDense: true,
          ),
          keyboardType: TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          initialValue: _latitude.toString(),
          onChanged: (value) {
            setState(() {
              _latitude = double.tryParse(value) ?? _latitude;
              _latitude = _latitude.clamp(-90.0, 90.0);
            });
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: const Key('lng_input'),
          decoration: const InputDecoration(
            labelText: 'Longitude',
            hintText: 'Enter longitude (-180 to 180)',
            prefixIcon: Icon(Icons.location_on),
            isDense: true,
          ),
          keyboardType: TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          initialValue: _longitude.toString(),
          onChanged: (value) {
            setState(() {
              _longitude = double.tryParse(value) ?? _longitude;
              _longitude = _longitude.clamp(-180.0, 180.0);
            });
          },
        ),
      ],
    );
  }

  Widget _buildZoomSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Zoom Level'),
            Text(
              _zoom.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: _zoom,
          min: 2.0,
          max: 18.0,
          divisions: 16,
          label: _zoom.toStringAsFixed(1),
          onChanged: (value) => setState(() => _zoom = value),
        ),
      ],
    );
  }

  Widget _buildProviderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Map Provider', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SegmentedButton<MapProvider>(
          segments: const [
            ButtonSegment(
              value: MapProvider.flutterMap,
              label: Text('OpenStreetMap'),
              icon: Icon(Icons.map_outlined),
            ),
            ButtonSegment(
              value: MapProvider.googleMap,
              label: Text('Google Maps'),
              icon: Icon(Icons.map),
            ),
          ],
          selected: {_selectedProvider},
          onSelectionChanged: (Set<MapProvider> provider) {
            setState(() => _selectedProvider = provider.first);
            if (provider == MapProvider.googleMap &&
                (_googleMapsApiKey.isEmpty || _googleMapsApiKey == 'YOUR_API_KEY_HERE')) {
              _showGoogleMapsApiKeyDialog(context);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCirclePresetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Preset Circle Type', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<CirclePreset>(
          value: _selectedPreset,
          decoration: const InputDecoration(
            hintText: 'Select a preset',
            isDense: true,
          ),
          items: [
            const DropdownMenuItem(
              value: CirclePreset.none,
              child: Text('Custom'),
            ),
            DropdownMenuItem(
              value: CirclePreset.dangerZone,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Danger Zone (Red)'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: CirclePreset.safeZone,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Safe Zone (Green)'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: CirclePreset.warningZone,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Warning Zone (Orange)'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: CirclePreset.noFlyZone,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('No Fly Zone'),
                ],
              ),
            ),
          ],
          onChanged: (CirclePreset? preset) {
            if (preset != null) {
              setState(() {
                _selectedPreset = preset;
                _applyPreset(preset);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildRadiusSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Radius (meters)'),
            Text(
              '${_circleRadius.toStringAsFixed(0)}m',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: _circleRadius,
          min: 10,
          max: 5000,
          divisions: 100,
          label: '${_circleRadius.toStringAsFixed(0)}m',
          onChanged: (value) => setState(() => _circleRadius = value),
        ),
      ],
    );
  }

  Widget _buildColorPickers() {
    return Column(
      children: [
        ListTile(
          title: const Text('Fill Color'),
          trailing: ColorIndicator(color: _circleColor),
          onTap: () => _pickColor(context, 'fill'),
        ),
        ListTile(
          title: const Text('Border Color'),
          trailing: ColorIndicator(color: _circleBorderColor),
          onTap: () => _pickColor(context, 'border'),
        ),
      ],
    );
  }

  Widget _buildStrokeWidthSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Border Width'),
            Text(
              '${_circleStrokeWidth.toStringAsFixed(1)}px',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: _circleStrokeWidth,
          min: 1,
          max: 10,
          divisions: 18,
          label: '${_circleStrokeWidth.toStringAsFixed(1)}px',
          onChanged: (value) => setState(() => _circleStrokeWidth = value),
        ),
      ],
    );
  }

  Widget _buildPresetPolygonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPolygonPresetButton(
          'Rectangular Area',
          Icons.rectangle_outlined,
          Colors.purple,
          () => setState(() {
            _polygonPoints.clear();
            _polygonPoints.addAll([
              const GeoPoint(latitude: 37.78, longitude: -122.42),
              const GeoPoint(latitude: 37.78, longitude: -122.40),
              const GeoPoint(latitude: 37.76, longitude: -122.40),
              const GeoPoint(latitude: 37.76, longitude: -122.42),
            ]);
          }),
        ),
        const SizedBox(height: 8),
        _buildPolygonPresetButton(
          'Triangle Zone',
          Icons.change_history,
          Colors.indigo,
          () => setState(() {
            _polygonPoints.clear();
            _polygonPoints.addAll([
              const GeoPoint(latitude: 37.79, longitude: -122.42),
              const GeoPoint(latitude: 37.77, longitude: -122.40),
              const GeoPoint(latitude: 37.77, longitude: -122.44),
            ]);
          }),
        ),
      ],
    );
  }

  Widget _buildPolygonPresetButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
      ),
      label: Text(label),
    );
  }

  Widget _buildPresetPolylinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPolylinePresetButton(
          'Demo Route',
          Icons.alt_route,
          Colors.blue,
          () => setState(() {
            _polylinePoints.clear();
            _polylinePoints.addAll([
              const GeoPoint(latitude: 37.7749, longitude: -122.4194),
              const GeoPoint(latitude: 37.7849, longitude: -122.4094),
              const GeoPoint(latitude: 37.7949, longitude: -122.3994),
              const GeoPoint(latitude: 37.8049, longitude: -122.3894),
            ]);
          }),
        ),
        const SizedBox(height: 8),
        _buildPolylinePresetButton(
          'Boundary Line',
          Icons.linear_scale,
          Colors.grey,
          () => setState(() {
            _polylinePoints.clear();
            _polylinePoints.addAll([
              const GeoPoint(latitude: 37.76, longitude: -122.42),
              const GeoPoint(latitude: 37.78, longitude: -122.42),
              const GeoPoint(latitude: 37.78, longitude: -122.40),
              const GeoPoint(latitude: 37.76, longitude: -122.40),
            ]);
          }),
        ),
      ],
    );
  }

  Widget _buildPolylinePresetButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
      ),
      label: Text(label),
    );
  }

  Widget _buildStatusCard() {
    final center = GeoPoint(latitude: _latitude, longitude: _longitude);
    final geofences = _buildGeofences();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Status',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _buildStatusRow('Center', '${center.latitude.toStringAsFixed(4)}, ${center.longitude.toStringAsFixed(4)}'),
            _buildStatusRow('Geofences', '${geofences.length} active'),
            _buildStatusRow('Provider', _selectedProvider.displayName),
            if (_tappedGeofenceId != null) _buildStatusRow('Last Tapped', _tappedGeofenceId!),
            if (_tappedLocation != null) _buildStatusRow('Map Tap', _tappedLocation!),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildMapDisplay() {
    final center = GeoPoint(latitude: _latitude, longitude: _longitude);
    final geofences = _buildGeofences();

    return Container(
      color: Colors.grey.shade200,
      child: Stack(
        children: [
          GeoGeofenceMap(
            center: center,
            zoom: _zoom,
            geofences: geofences,
            provider: _selectedProvider,
            googleMapsApiKey: _googleMapsApiKey,
            showZoomControls: true,
            showCompass: true,
            showMyLocationButton: true,
            onGeofenceTap: (id) {
              setState(() {
                _tappedGeofenceId = 'Geofence: $id';
              });
              _showSnackBar(context, 'Tapped geofence: $id');
            },
            onMapTap: (location) {
              setState(() {
                _tappedLocation = '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
              });
            },
          ),
          if (_tappedGeofenceId != null || _tappedLocation != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildStatusChip(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    final message = _tappedGeofenceId ?? _tappedLocation ?? '';
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  List<GeoGeofenceBase> _buildGeofences() {
    final center = GeoPoint(latitude: _latitude, longitude: _longitude);
    final geofences = <GeoGeofenceBase>[];

    if (_showCircle) {
      geofences.add(
        _createCircleGeofence(center),
      );
    }

    if (_showPolygon && _polygonPoints.length >= 3) {
      geofences.add(
        GeoPolygonWidget(
          id: 'demo_polygon',
          points: List.from(_polygonPoints),
          color: const Color(0x339C27B0),
          borderColor: const Color(0xFF9C27B0),
        ),
      );
    }

    if (_showPolyline && _polylinePoints.length >= 2) {
      geofences.add(
        GeoPolylineWidget(
          id: 'demo_polyline',
          points: List.from(_polylinePoints),
          strokeColor: const Color(0xFF2196F3),
          width: 4,
        ),
      );
    }

    return geofences;
  }

  GeoCircleWidget _createCircleGeofence(GeoPoint center) {
    switch (_selectedPreset) {
      case CirclePreset.dangerZone:
        return GeoCircleWidget.dangerZone(
          center: center,
          radius: _circleRadius,
        );
      case CirclePreset.safeZone:
        return GeoCircleWidget.safeZone(
          center: center,
          radius: _circleRadius,
        );
      case CirclePreset.warningZone:
        return GeoCircleWidget.warningZone(
          center: center,
          radius: _circleRadius,
        );
      case CirclePreset.noFlyZone:
        return GeoCircleWidget.noFlyZone(
          center: center,
          radius: _circleRadius,
        );
      case CirclePreset.none:
      default:
        return GeoCircleWidget(
          id: 'demo_circle',
          center: center,
          radius: _circleRadius,
          color: _circleColor.withOpacity(0.3),
          borderColor: _circleBorderColor,
          strokeWidth: _circleStrokeWidth,
          isInteractive: _circleInteractive,
        );
    }
  }

  void _applyPreset(CirclePreset preset) {
    switch (preset) {
      case CirclePreset.dangerZone:
        setState(() {
          _circleColor = Colors.red;
          _circleBorderColor = Colors.red.shade700;
          _circleStrokeWidth = 3.0;
        });
        break;
      case CirclePreset.safeZone:
        setState(() {
          _circleColor = Colors.green;
          _circleBorderColor = Colors.green.shade700;
          _circleStrokeWidth = 2.0;
        });
        break;
      case CirclePreset.warningZone:
        setState(() {
          _circleColor = Colors.orange;
          _circleBorderColor = Colors.orange.shade700;
          _circleStrokeWidth = 2.5;
        });
        break;
      case CirclePreset.noFlyZone:
        setState(() {
          _circleColor = Colors.red.shade900;
          _circleBorderColor = Colors.red;
          _circleStrokeWidth = 4.0;
        });
        break;
      case CirclePreset.none:
      default:
        break;
    }
  }

  Future<void> _pickColor(BuildContext context, String type) async {
    final color = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select ${type} color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildColorOption(Colors.blue, 'Blue'),
            _buildColorOption(Colors.red, 'Red'),
            _buildColorOption(Colors.green, 'Green'),
            _buildColorOption(Colors.orange, 'Orange'),
            _buildColorOption(Colors.purple, 'Purple'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (color != null) {
      setState(() {
        if (type == 'fill') {
          _circleColor = color;
        } else {
          _circleBorderColor = color;
        }
      });
    }
  }

  Widget _buildColorOption(Color color, String name) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
      ),
      title: Text(name),
      onTap: () => Navigator.of(context).pop(color),
    );
  }

  void _showGoogleMapsApiKeyDialog(BuildContext context) {
    final controller = TextEditingController(text: _googleMapsApiKey);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Google Maps API Key Required'),
        content: const Text(
          'To use Google Maps, please enter your API key. '
          'The key will be stored only for this session.',
        ),
        actions: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'API Key',
              hintText: 'Enter your Google Maps API key',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _googleMapsApiKey = controller.text;
                    _selectedProvider = MapProvider.flutterMap;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Switched to OpenStreetMap (no API key)'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Use OpenStreetMap'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _googleMapsApiKey = controller.text;
                  });
                  Navigator.pop(context);
                  if (_googleMapsApiKey.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google Maps API key saved'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Save Key'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About This Demo'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This demo showcases the geo_widget module features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Interactive controls to customize geofences'),
              Text('• Real-time map updates as you change settings'),
              Text('• Preset geofence types (danger zone, safe zone, etc.)'),
              Text('• Support for circles, polygons, and polylines'),
              Text('• Two map providers: OpenStreetMap (free) and Google Maps'),
              SizedBox(height: 16),
              Text(
                'Try it out:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('1. Adjust the map center using latitude/longitude inputs'),
              Text('2. Select a circle preset or customize manually'),
              Text('3. Enable polygons/polylines and try the presets'),
              Text('4. Tap on geofences or the map to see callbacks'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Color indicator widget for showing selected colors.
class ColorIndicator extends StatelessWidget {
  final Color color;

  const ColorIndicator({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade400),
      ),
    );
  }
}

/// Circle preset options for quick selection.
enum CirclePreset {
  none,
  dangerZone,
  safeZone,
  warningZone,
  noFlyZone,
}
