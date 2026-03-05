import 'package:flutter/material.dart';
import 'package:geo_fence_utils/geo_fence_utils.dart';

void main() {
  runApp(const GeoFenceUtilsDemo());
}

/// Complete demo showcasing all features of geo_fence_utils library
class GeoFenceUtilsDemo extends StatefulWidget {
  const GeoFenceUtilsDemo({super.key});

  @override
  State<GeoFenceUtilsDemo> createState() => _GeoFenceUtilsDemoState();
}

class _GeoFenceUtilsDemoState extends State<GeoFenceUtilsDemo> {
  // Current page index
  int _selectedPage = 0;

  // Scenario selection (separate from geofence ID)
  int? _selectedScenarioIndex;

  // Map configuration
  static const _defaultCenter = GeoPoint(latitude: 37.7749, longitude: -122.4194);
  static const double _defaultZoom = 13.0;

  // All geofence examples - predefined static values
  // Use List<GeoGeofenceBase> to avoid unsafe casts
  late final List<GeoGeofenceBase> _circleExamples;
  late final List<GeoGeofenceBase> _polygonExamples;
  late final List<GeoGeofenceBase> _polylineExamples;
  late final List<List<GeoGeofenceBase>> _combinedScenes;
  late final List<GeoMarkerWidget> _markerExamples;
  GeoMarkerWidget? _selectedMarker;

  // Status messages
  String? _tappedGeofenceId;
  String? _tappedLocation;
  String? _tappedMarkerId;

  @override
  void initState() {
    super.initState();
    // Clear marker cache to ensure fresh rendering during development
    MarkerCacheManager.clear();
    _initializeExamples();
  }

  /// Initialize all static examples demonstrating library features
  void _initializeExamples() {
    // ============================================
    // CIRCLE EXAMPLES - With PNG and SVG center markers
    // ============================================
    _circleExamples = [
      // Circle with PNG location marker
      GeoCircleWidget(
        id: 'circle_png_location',
        center: _defaultCenter,
        radius: 500,
        color: Colors.blue.withOpacity(0.3),
        borderColor: Colors.blue,
        strokeWidth: 2.0,
        centerMarker: MarkerConfig(
          type: MarkerType.pngAsset,
          color: Colors.transparent,
          size: 48,
          pngAssetPath: 'marker pin/location.png',
          label: 'Location',
        ),
      ),


      // Circle with PNG marker
      GeoCircleWidget(
        id: 'circle_png_marker',
        center: const GeoPoint(latitude: 37.76, longitude: -122.42),
        radius: 550,
        color: Colors.orange.withOpacity(0.3),
        borderColor: Colors.orange,
        strokeWidth: 2.0,
      ),

      // Circle with SVG location pin marker
      GeoCircleWidget(
        id: 'circle_svg_location_pin',
        center: const GeoPoint(latitude: 38.7625, longitude: -122.42),
        radius: 400,
        color: Colors.red.withOpacity(0.3),
        borderColor: Colors.red,
        strokeWidth: 2.0,
        centerMarker: const MarkerConfig(
          type: MarkerType.svgCustom,
          color: Colors.red,
          size: 48,
          svgPath: 'M29.5,43.6c.33.79,16.25,27.6,18.07,30.66a.5.5,0,0,0,.43.24h0a.48.48,0,0,0,.43-.25L66.5,43.57l0-.07A19.77,19.77,0,0,0,68,36a20,20,0,1,0-38.54,7.49ZM48,17A19,19,0,0,1,67,36a18.8,18.8,0,0,1-1.38,7.09L48,73c-5.16-8.69-17.21-29-17.56-29.78a.76.76,0,0,1,0-.11A19,19,0,0,1,48,17Z',
          label: 'Pin',
        ),
      ),

      // Circle with SVG map marker
      GeoCircleWidget(
        id: 'circle_svg_map_marker',
        center: const GeoPoint(latitude: 37.75, longitude: -122.41),
        radius: 600,
        color: Colors.purple.withOpacity(0.3),
        borderColor: Colors.purple,
        strokeWidth: 2.0,
        centerMarker: MarkerConfig(
          type: MarkerType.svgCustom,
          color: Colors.purple,
          size: 48,
          svgPath: 'M9.7685,23.0866C9.7296,23.1333,9.6866,23.1763,9.6399,23.2152C9.2154,23.5686,8.5849,23.511,8.2315,23.0866C2.74384,16.4959,0,11.6798,0,8.63811C0,3.86741,4.2293,0,9,0C13.7707,0,18,3.86741,18,8.63811C18,11.6798,15.2562,16.4959,9.7685,23.0866Z M9,12C10.6569,12,12,10.6569,12,9C12,7.34315,10.6569,6,9,6C7.3431,6,6,7.34315,6,9C6,10.6569,7.3431,12,9,12z',
          label: 'Map Marker',
        ),
      ),
    ];

    // ============================================
    // POLYGON EXAMPLES - All preset styles with IDs
    // ============================================
    _polygonExamples = [
      // Custom polygon
      GeoPolygonWidget(
        id: 'custom_polygon',
        points: const [
          GeoPoint(latitude: 37.78, longitude: -122.42),
          GeoPoint(latitude: 37.78, longitude: -122.40),
          GeoPoint(latitude: 37.76, longitude: -122.40),
          GeoPoint(latitude: 37.76, longitude: -122.42),
        ],
        color: Colors.purple.withOpacity(0.3),
        borderColor: Colors.purple,
        strokeWidth: 2.0,
      ),

      // Preset: Restricted Area - with explicit ID
      GeoPolygonWidget.restrictedArea(
        id: 'restricted_area',
        points: const [
          GeoPoint(latitude: 37.80, longitude: -122.45),
          GeoPoint(latitude: 37.80, longitude: -122.43),
          GeoPoint(latitude: 37.78, longitude: -122.43),
          GeoPoint(latitude: 37.78, longitude: -122.45),
        ],
      ),

      // Preset: Perimeter - with explicit ID
      GeoPolygonWidget.perimeter(
        id: 'perimeter_zone',
        points: const [
          GeoPoint(latitude: 37.75, longitude: -122.44),
          GeoPoint(latitude: 37.75, longitude: -122.42),
          GeoPoint(latitude: 37.73, longitude: -122.42),
          GeoPoint(latitude: 37.73, longitude: -122.44),
        ],
      ),

      // Preset: Secure Zone - with explicit ID
      GeoPolygonWidget.secureZone(
        id: 'secure_zone',
        points: const [
          GeoPoint(latitude: 37.82, longitude: -122.40),
          GeoPoint(latitude: 37.82, longitude: -122.38),
          GeoPoint(latitude: 37.80, longitude: -122.38),
          GeoPoint(latitude: 37.80, longitude: -122.40),
        ],
      ),

      // Using fromBounds factory - has ID
      GeoPolygonWidget.fromBounds(
        north: 37.74,
        south: 37.72,
        east: -122.39,
        west: -122.41,
        id: 'bounds_polygon',
      ),

      // Using fromCoordinates factory - has ID
      GeoPolygonWidget.fromCoordinates(
        coordinates: const [
          [37.85, -122.47],
          [37.85, -122.45],
          [37.83, -122.45],
          [37.83, -122.47],
        ],
        id: 'coords_polygon',
      ),
    ];

    // ============================================
    // POLYLINE EXAMPLES - All preset styles with IDs
    // ============================================
    _polylineExamples = [
      // Custom polyline
      const GeoPolylineWidget(
        id: 'custom_polyline',
        points: [
          GeoPoint(latitude: 37.7749, longitude: -122.4194),
          GeoPoint(latitude: 37.7849, longitude: -122.4094),
          GeoPoint(latitude: 37.7949, longitude: -122.3994),
        ],
        strokeColor: Colors.red,
        width: 4.0,
        capStyle: PolylineCap.round,
        isGeodesic: true,
        startMarker: MarkerConfig(
          type: MarkerType.svgCustom,
          color: Colors.green,
          size: 32,
          svgPath: 'M12,2A10,10,0,1,0,22,12,10.011,10.011,0,0,0,12,2Zm0,18a8,8,0,1,1,8-8A8.009,8.009,0,0,1,12,20Z',
          label: 'Start',
        ),
        endMarker: MarkerConfig(
          type: MarkerType.svgCustom,
          color: Colors.red,
          size: 32,
          svgPath: 'M12,2A10,10,0,1,0,22,12,10.011,10.011,0,0,0,12,2Zm0,18a8,8,0,1,1,8-8A8.009,8.009,0,0,1,12,20Z',
          label: 'End',
        ),
      ),

      // Preset: Route - with explicit ID
      GeoPolylineWidget.route(
        id: 'route_polyline',
        points: const [
          GeoPoint(latitude: 37.76, longitude: -122.43),
          GeoPoint(latitude: 37.77, longitude: -122.42),
          GeoPoint(latitude: 37.78, longitude: -122.41),
          GeoPoint(latitude: 37.79, longitude: -122.40),
        ],
      ),

      // Preset: Boundary - with explicit ID
      GeoPolylineWidget.boundary(
        id: 'boundary_polyline',
        points: const [
          GeoPoint(latitude: 37.80, longitude: -122.44),
          GeoPoint(latitude: 37.80, longitude: -122.42),
          GeoPoint(latitude: 37.78, longitude: -122.42),
          GeoPoint(latitude: 37.78, longitude: -122.44),
          GeoPoint(latitude: 37.80, longitude: -122.44),
        ],
      ),

      // Preset: Navigation Path - with explicit ID
      GeoPolylineWidget.navigationPath(
        id: 'nav_path',
        points: const [
          GeoPoint(latitude: 37.75, longitude: -122.45),
          GeoPoint(latitude: 37.76, longitude: -122.44),
          GeoPoint(latitude: 37.77, longitude: -122.43),
          GeoPoint(latitude: 37.78, longitude: -122.42),
        ],
      ),

      // Preset: Corridor - with explicit ID
      GeoPolylineWidget.corridor(
        id: 'corridor_polyline',
        points: const [
          GeoPoint(latitude: 37.82, longitude: -122.48),
          GeoPoint(latitude: 37.81, longitude: -122.47),
          GeoPoint(latitude: 37.80, longitude: -122.46),
        ],
      ),

      // Preset: Flight Path - with explicit ID
      GeoPolylineWidget.flightPath(
        id: 'flight_path',
        points: const [
          GeoPoint(latitude: 37.70, longitude: -122.40),
          GeoPoint(latitude: 37.73, longitude: -122.43),
          GeoPoint(latitude: 37.76, longitude: -122.46),
          GeoPoint(latitude: 37.79, longitude: -122.49),
        ],
      ),

      // With dash pattern - has ID
      const GeoPolylineWidget(
        id: 'dashed_line',
        points: [
          GeoPoint(latitude: 37.73, longitude: -122.38),
          GeoPoint(latitude: 37.75, longitude: -122.36),
          GeoPoint(latitude: 37.77, longitude: -122.34),
        ],
        strokeColor: Colors.orange,
        width: 3.0,
        dashPattern: [10, 5],
      ),
    ];

    // ============================================
    // COMBINED SCENARIOS - Real-world use cases
    // ============================================
    _combinedScenes = [
      // Scenario 1: Airport Zone (No Fly + Safe Zones)
      [
        GeoCircleWidget.noFlyZone(
          id: 'airport_no_fly',
          center: const GeoPoint(latitude: 37.7749, longitude: -122.4194),
          radius: 1500,
        ),
        GeoCircleWidget.safeZone(
          id: 'parking_zone',
          center: const GeoPoint(latitude: 37.76, longitude: -122.43),
          radius: 300,
        ),
        GeoPolylineWidget.navigationPath(
          id: 'runway_path',
          points: const [
            GeoPoint(latitude: 37.75, longitude: -122.44),
            GeoPoint(latitude: 37.7749, longitude: -122.4194),
            GeoPoint(latitude: 37.80, longitude: -122.40),
          ],
        ),
      ],

      // Scenario 2: City Security (Perimeter + Restricted Areas)
      [
        GeoPolygonWidget.perimeter(
          id: 'city_perimeter',
          points: const [
            GeoPoint(latitude: 37.79, longitude: -122.44),
            GeoPoint(latitude: 37.79, longitude: -122.40),
            GeoPoint(latitude: 37.75, longitude: -122.40),
            GeoPoint(latitude: 37.75, longitude: -122.44),
          ],
        ),
        GeoCircleWidget.dangerZone(
          id: 'restricted_sector',
          center: const GeoPoint(latitude: 37.77, longitude: -122.42),
          radius: 400,
        ),
        GeoPolygonWidget.restrictedArea(
          id: 'government_zone',
          points: const [
            GeoPoint(latitude: 37.78, longitude: -122.43),
            GeoPoint(latitude: 37.78, longitude: -122.41),
            GeoPoint(latitude: 37.76, longitude: -122.41),
            GeoPoint(latitude: 37.76, longitude: -122.43),
          ],
        ),
      ],

      // Scenario 3: Delivery Route System
      [
        GeoPolylineWidget.route(
          id: 'delivery_route',
          points: const [
            GeoPoint(latitude: 37.7749, longitude: -122.4194),
            GeoPoint(latitude: 37.7849, longitude: -122.4094),
            GeoPoint(latitude: 37.7949, longitude: -122.3994),
            GeoPoint(latitude: 37.7849, longitude: -122.3894),
            GeoPoint(latitude: 37.7749, longitude: -122.3794),
          ],
        ),
        GeoCircleWidget.warningZone(
          id: 'checkpoint_1',
          center: const GeoPoint(latitude: 37.7849, longitude: -122.4094),
          radius: 200,
        ),
        GeoCircleWidget.warningZone(
          id: 'checkpoint_2',
          center: const GeoPoint(latitude: 37.7949, longitude: -122.3994),
          radius: 200,
        ),
        GeoCircleWidget.safeZone(
          id: 'destination',
          center: const GeoPoint(latitude: 37.7749, longitude: -122.3794),
          radius: 250,
        ),
      ],
    ];

    // ============================================
    // MARKER EXAMPLES - Only your uploaded assets
    // ============================================
    _markerExamples = [


      // PNG Custom marker
      GeoMarkerWidget.pngAsset(
        id: 'png_custom',
        position: const GeoPoint(latitude: 37.76, longitude: -122.42),
        pngAssetPath: 'marker pin/marker.png',
        label: 'Marker',
        markerSize: 48,
      ),

      // SVG Map marker
      GeoMarkerWidget.svgPath(
        id: 'svg_map_marker',
        position: const GeoPoint(latitude: 37.77, longitude: -122.40),
        label: 'Map Marker',
        color: Colors.blue,
        markerSize: 48,
        svgPath: 'M9.7685,23.0866C9.7296,23.1333,9.6866,23.1763,9.6399,23.2152C9.2154,23.5686,8.5849,23.511,8.2315,23.0866C2.74384,16.4959,0,11.6798,0,8.63811C0,3.86741,4.2293,0,9,0C13.7707,0,18,3.86741,18,8.63811C18,11.6798,15.2562,16.4959,9.7685,23.0866Z M9,12C10.6569,12,12,10.6569,12,9C12,7.34315,10.6569,6,9,6C7.3431,6,6,7.34315,6,9C6,10.6569,7.3431,12,9,12z',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo Fence Utils - Complete Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Geo Fence Utils Demo ✨ (Updated)'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showInfoDialog,
              tooltip: 'Library Info',
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: _buildPageSelector(),
            ),
            const Divider(height: 1),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return _buildDesktopLayout();
                  }
                  return _buildMobileLayout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // LAYOUT BUILDERS
  // ============================================

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        SizedBox(
          width: 350,
          child: _buildControlPanel(),
        ),
        Expanded(
          child: _buildMapArea(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: _buildMapArea(),
        ),
        Expanded(
          flex: 3,
          child: _buildControlPanel(),
        ),
      ],
    );
  }

  // ============================================
  // CONTROL PANEL
  // ============================================

  Widget _buildControlPanel() {
    return Container(
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildSelectedPageContent(),
      ),
    );
  }


  Widget _buildPageSelector() {
    final pages = [
      {'label': 'Circles', 'icon': Icons.radio_button_unchecked, 'index': 0},
      {'label': 'Polygons', 'icon': Icons.change_history, 'index': 1},
      {'label': 'Polylines', 'icon': Icons.show_chart, 'index': 2},
      {'label': 'Markers', 'icon': Icons.location_on, 'index': 3},
      {'label': 'Scenarios', 'icon': Icons.apps, 'index': 4},
      {'label': 'Services', 'icon': Icons.code, 'index': 5},
    ];

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: pages.map((page) {
        final isSelected = _selectedPage == page['index'];
        return Material(
          color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedPage = page['index'] as int;
                _tappedGeofenceId = null;
                _selectedScenarioIndex = null;
                _tappedLocation = null;
                _tappedMarkerId = null;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    page['icon'] as IconData,
                    size: 18,
                    color: isSelected ? Colors.deepPurple : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    page['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.deepPurple : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectedPageContent() {
    Widget content;
    switch (_selectedPage) {
      case 0:
        content = _buildCirclesPage();
        break;
      case 1:
        content = _buildPolygonsPage();
        break;
      case 2:
        content = _buildPolylinesPage();
        break;
      case 3:
        content = _buildMarkersPage();
        break;
      case 4:
        content = _buildScenariosPage();
        break;
      case 5:
        content = _buildServicesPage();
        break;
      default:
        content = const SizedBox.shrink();
    }
    // Wrap in SingleChildScrollView to prevent overflow
    return SingleChildScrollView(
      child: content,
    );
  }

  // ============================================
  // CIRCLES PAGE
  // ============================================

  Widget _buildCirclesPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Circle Geofences', Icons.circle_outlined),
        const SizedBox(height: 8),
        const Text(
          'Tap any circle to view it on the map',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        ..._circleExamples.asMap().entries.map((entry) {
          final index = entry.key;
          final geofence = entry.value;
          if (geofence is GeoCircleWidget) {
            return _buildCircleCard(index, geofence);
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 16),
        _buildUsageExample('Circle Usage', '''
// Custom circle
GeoCircleWidget(
  id: 'custom_circle',
  center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  radius: 500,
  color: Colors.blue.withOpacity(0.3),
  borderColor: Colors.blue,
  strokeWidth: 2.0,
);

// Preset: Danger Zone
GeoCircleWidget.dangerZone(
  id: 'danger_zone',
  center: GeoPoint(latitude: 37.78, longitude: -122.41),
  radius: 400,
);

// With simple radius
GeoCircleWidget.withRadius(
  center: GeoPoint(latitude: 37.75, longitude: -122.41),
  radius: 1000,
  id: 'simple_circle',
);
'''),
      ],
    );
  }

  Widget _buildCircleCard(int index, GeoCircleWidget circle) {
    final isSelected = _tappedGeofenceId == circle.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _tappedGeofenceId = circle.id),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circle Icon
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: circle.borderColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: circle.borderColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              // Main Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCircleTitle(index),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Lat: ${circle.center.latitude.toStringAsFixed(4)}  |  "
                          "Lng: ${circle.center.longitude.toStringAsFixed(4)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Radius: ${circle.radius.toInt()} meters",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Metadata Chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  circle.metadata['type'] ?? 'preset',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.blue : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  String _getCircleTitle(int index) {
    switch (index) {
      case 0: return 'Custom Circle';
      case 1: return 'Danger Zone';
      case 2: return 'Safe Zone';
      case 3: return 'Warning Zone';
      case 4: return 'No Fly Zone';
      case 5: return 'Simple Radius';
      default: return 'Circle ${index + 1}';
    }
  }

  // ============================================
  // POLYGONS PAGE
  // ============================================

  Widget _buildPolygonsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Polygon Geofences', Icons.change_history),
        const SizedBox(height: 8),
        const Text(
          'Tap any polygon to view it on the map',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        ..._polygonExamples.asMap().entries.map((entry) {
          final index = entry.key;
          final geofence = entry.value;
          if (geofence is GeoPolygonWidget) {
            return _buildPolygonCard(index, geofence);
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 16),
        _buildUsageExample('Polygon Usage', '''
// Custom polygon
GeoPolygonWidget(
  id: 'custom_polygon',
  points: [
    GeoPoint(latitude: 37.78, longitude: -122.42),
    GeoPoint(latitude: 37.78, longitude: -122.40),
    GeoPoint(latitude: 37.76, longitude: -122.40),
    GeoPoint(latitude: 37.76, longitude: -122.42),
  ],
  color: Colors.purple.withOpacity(0.3),
  borderColor: Colors.purple,
  strokeWidth: 2.0,
);

// From bounds
GeoPolygonWidget.fromBounds(
  north: 37.74, south: 37.72,
  east: -122.39, west: -122.41,
  id: 'bounds_polygon',
);

// Preset: Restricted Area
GeoPolygonWidget.restrictedArea(
  id: 'restricted_area',
  points: [...],
);
'''),
      ],
    );
  }

  Widget _buildPolygonCard(int index, GeoPolygonWidget polygon) {
    final isSelected = _tappedGeofenceId == polygon.id;
    return Card(
      color: isSelected ? Colors.purple.shade50 : null,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: polygon.borderColor,
          child: const Icon(Icons.change_history, color: Colors.white),
        ),
        title: Text(_getPolygonTitle(index)),
        subtitle: Text('Vertices: ${polygon.points.length}'),
        trailing: Chip(
          label: Text(_getPolygonMethod(index), style: const TextStyle(fontSize: 10)),
        ),
        onTap: () => setState(() => _tappedGeofenceId = polygon.id),
      ),
    );
  }

  String _getPolygonTitle(int index) {
    switch (index) {
      case 0: return 'Custom Polygon';
      case 1: return 'Restricted Area';
      case 2: return 'Perimeter';
      case 3: return 'Secure Zone';
      case 4: return 'From Bounds';
      case 5: return 'From Coordinates';
      default: return 'Polygon ${index + 1}';
    }
  }

  String _getPolygonMethod(int index) {
    switch (index) {
      case 0: return 'custom';
      case 1: return 'preset';
      case 2: return 'preset';
      case 3: return 'preset';
      case 4: return 'bounds';
      case 5: return 'coords';
      default: return 'factory';
    }
  }

  // ============================================
  // POLYLINES PAGE
  // ============================================

  Widget _buildPolylinesPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Polyline Routes', Icons.show_chart),
        const SizedBox(height: 8),
        const Text(
          'Tap any polyline to view it on the map',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        ..._polylineExamples.asMap().entries.map((entry) {
          final index = entry.key;
          final geofence = entry.value;
          if (geofence is GeoPolylineWidget) {
            return _buildPolylineCard(index, geofence);
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 16),
        _buildUsageExample('Polyline Usage', '''
// Custom polyline
GeoPolylineWidget(
  id: 'custom_polyline',
  points: [
    GeoPoint(latitude: 37.7749, longitude: -122.4194),
    GeoPoint(latitude: 37.7849, longitude: -122.4094),
    GeoPoint(latitude: 37.7949, longitude: -122.3994),
  ],
  strokeColor: Colors.red,
  width: 4.0,
  capStyle: PolylineCap.round,
  isGeodesic: true,
);

// With dash pattern
GeoPolylineWidget(
  id: 'dashed',
  points: [...],
  dashPattern: [10, 5],
);

// Preset: Route
GeoPolylineWidget.route(
  id: 'route',
  points: [...],
);
'''),
      ],
    );
  }

  Widget _buildPolylineCard(int index, GeoPolylineWidget polyline) {
    final isSelected = _tappedGeofenceId == polyline.id;
    return Card(
      color: isSelected ? Colors.red.shade50 : null,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: polyline.strokeColor,
          child: const Icon(Icons.show_chart, color: Colors.white),
        ),
        title: Text(_getPolylineTitle(index)),
        subtitle: Text('Points: ${polyline.points.length} | Width: ${polyline.width}px'),
        trailing: Chip(
          label: Text(polyline.dashPattern != null ? 'dashed' : 'solid', style: const TextStyle(fontSize: 10)),
        ),
        onTap: () => setState(() => _tappedGeofenceId = polyline.id),
      ),
    );
  }

  String _getPolylineTitle(int index) {
    switch (index) {
      case 0: return 'Custom Polyline';
      case 1: return 'Route';
      case 2: return 'Boundary';
      case 3: return 'Navigation Path';
      case 4: return 'Corridor';
      case 5: return 'Flight Path';
      case 6: return 'Dashed Line';
      default: return 'Polyline ${index + 1}';
    }
  }

  // ============================================
  // MARKERS PAGE
  // ============================================

  Widget _buildMarkersPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Map Markers', Icons.location_on),
        const SizedBox(height: 8),
        const Text(
          'Tap any marker to view it on the map',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        ..._markerExamples.asMap().entries.map((entry) {
          final index = entry.key;
          final marker = entry.value;
          return _buildMarkerCard(index, marker);
        }),
        const SizedBox(height: 16),
        _buildUsageExample('Marker Usage', '''
 // PNG Custom marker
      GeoMarkerWidget.pngAsset(
        id: 'png_custom',
        position: const GeoPoint(latitude: 37.76, longitude: -122.42),
        pngAssetPath: 'marker pin/marker.png',
        label: 'Marker',
        markerSize: 48,
      ),

      // SVG Map marker
      GeoMarkerWidget.svgPath(
        id: 'svg_map_marker',
        position: const GeoPoint(latitude: 37.77, longitude: -122.40),
        label: 'Map Marker',
        color: Colors.blue,
        markerSize: 48,
        svgPath: 'M9.7685,23.0866C9.7296,23.1333,9.6866,23.1763,9.6399,23.2152C9.2154,23.5686,8.5849,23.511,8.2315,23.0866C2.74384,16.4959,0,11.6798,0,8.63811C0,3.86741,4.2293,0,9,0C13.7707,0,18,3.86741,18,8.63811C18,11.6798,15.2562,16.4959,9.7685,23.0866Z M9,12C10.6569,12,12,10.6569,12,9C12,7.34315,10.6569,6,9,6C7.3431,6,6,7.34315,6,9C6,10.6569,7.3431,12,9,12z',
      ),
'''),
      ],
    );
  }

Widget _buildMarkerCard(int index, GeoMarkerWidget marker) {
  final isSelected = _tappedMarkerId == marker.id;

  return Card(
    color: isSelected ? Colors.orange.shade50 : null,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: marker.markerColor ?? Colors.blue,
        child: const Icon(
          Icons.location_on,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(_getMarkerTitle(index)),
      subtitle: Text(
        'Position: ${marker.position.latitude.toStringAsFixed(4)}, '
        '${marker.position.longitude.toStringAsFixed(4)}\n'
        '${marker.label != null ? 'Label: ${marker.label}' : 'No label'}',
      ),
      trailing: Chip(
        label: Text(
          marker.metadata['type'] ?? 'custom',
          style: const TextStyle(fontSize: 10),
        ),
      ),
      onTap: () => setState(() => _tappedMarkerId = marker.id),
    ),
  );
}



Widget _buildMarkerInfoCard() {
  final marker = _selectedMarker!;

  return Card(
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: marker.markerColor,
            child: const Icon(Icons.location_on, color: Colors.white),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  marker.label ?? "Marker",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "${marker.position.latitude.toStringAsFixed(4)}, "
                  "${marker.position.longitude.toStringAsFixed(4)}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _selectedMarker = null;
              });
            },
          )
        ],
      ),
    ),
  );
}


  String _getMarkerTitle(int index) {
    switch (index) {
      case 0: return 'Current Location';
      case 1: return 'Construction Zone';
      case 2: return 'Checkpoint 1';
      case 3: return 'Checkpoint 2';
      case 4: return 'Checkpoint 3';
      case 5: return 'Landmark';
      case 6: return 'Minimal Dot';
      case 7: return 'Classic Pin';
      case 8: return 'Modern Flat';
      case 9: return 'Circular Avatar';
      case 10: return 'SVG Star';
      case 11: return 'SVG Heart';
      case 12: return 'Restaurant';
      case 13: return 'Parking';
      case 14: return 'Gym';
      case 15: return 'Cafe';
      case 16: return 'Shopping';
      case 17: return 'Landmark (Star)';
      case 18: return 'Hospital';
      case 19: return 'Hotel';
      case 20: return 'Custom Marker';
      default: return 'Marker ${index + 1}';
    }
  }

  // ============================================
  // SCENARIOS PAGE
  // ============================================

  Widget _buildScenariosPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Real-World Scenarios', Icons.apps),
        const SizedBox(height: 8),
        const Text(
          'Combined geofences for practical use cases',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        _buildScenarioCard(0, 'Airport Zone', Icons.flight_takeoff,
            'No-fly zone with safe parking areas and runway paths'),
        _buildScenarioCard(1, 'City Security', Icons.security,
            'Perimeter fence with restricted sectors and government zones'),
        _buildScenarioCard(2, 'Delivery Route', Icons.local_shipping,
            'Delivery route with checkpoints and destination zones'),
        const SizedBox(height: 16),
        _buildUsageExample('Combined Scenario Example', '''
// Airport zone scenario
final geofences = [
  GeoCircleWidget.noFlyZone(
    id: 'airport_no_fly',
    center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
    radius: 1500,
  ),
  GeoCircleWidget.safeZone(
    id: 'parking_zone',
    center: GeoPoint(latitude: 37.76, longitude: -122.43),
    radius: 300,
  ),
  GeoPolylineWidget.navigationPath(
    id: 'runway_path',
    points: [
      GeoPoint(latitude: 37.75, longitude: -122.44),
      GeoPoint(latitude: 37.7749, longitude: -122.4194),
      GeoPoint(latitude: 37.80, longitude: -122.40),
    ],
  ),
];

GeoGeofenceMap(
  center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  geofences: geofences,
);
'''),
      ],
    );
  }

  Widget _buildScenarioCard(int index, String title, IconData icon, String description) {
    final isSelected = _selectedScenarioIndex == index;
    return Card(
      color: isSelected ? Colors.green.shade50 : null,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon, color: Colors.white),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => setState(() {
          _selectedScenarioIndex = index;
          _tappedGeofenceId = null;
        }),
      ),
    );
  }

  // ============================================
  // SERVICES PAGE - Show all service methods
  // ============================================

  Widget _buildServicesPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Service Methods', Icons.code),
        const SizedBox(height: 8),
        _buildServiceSection('GeoDistanceService', '''
// Calculate distance between two points
double distance = GeoDistanceService.calculateDistance(
  GeoPoint(latitude: 37.7749, longitude: -122.4194),
  GeoPoint(latitude: 37.7849, longitude: -122.4094),
);

// Find closest point
GeoPoint? closest = GeoDistanceService.findClosest(
  origin,
  [point1, point2, point3],
);

// Filter by radius
List<GeoPoint> nearby = GeoDistanceService.filterByRadius(
  origin,
  points,
  radius: 1000, // meters
);

// Check if within distance
bool isNear = GeoDistanceService.isWithinDistance(
  point1, point2,
  maxDistance: 500,
);
'''),
        _buildServiceSection('GeoCircleService', '''
// Check if point is inside circle
bool inside = GeoCircleService.isInsideCircle(
  point: myPoint,
  circle: myCircle,
);

// Distance to boundary
double dist = GeoCircleService.distanceToBoundary(
  point: myPoint,
  circle: myCircle,
);

// Count points inside
int count = GeoCircleService.countInside(
  points: allPoints,
  circle: myCircle,
);

// Check circle overlap
bool overlaps = GeoCircleService.circlesOverlap(
  circle1: circleA,
  circle2: circleB,
);
'''),
        _buildServiceSection('GeoPolygonService', '''
// Point in polygon (Ray Casting)
bool inside = GeoPolygonService.isInsidePolygon(
  point: myPoint,
  polygon: myPolygon,
);

// Calculate area
double area = GeoPolygonService.calculateArea(myPolygon);

// Calculate perimeter
double perimeter = GeoPolygonService.calculatePerimeter(myPolygon);

// Get bounding box
Map bounds = GeoPolygonService.getBoundingBox(myPolygon);

// Check if convex
bool convex = GeoPolygonService.isConvex(myPolygon);
'''),
        _buildServiceSection('GeoMath', '''
// Haversine distance
double dist = GeoMath.haversineDistance(
  lat1, lon1, lat2, lon2,
);

// Calculate bearing
double bearing = GeoMath.calculateBearing(
  lat1, lon1, lat2, lon2,
);

// Calculate destination
Map dest = GeoMath.calculateDestination(
  lat: 37.7749,
  lon: -122.4194,
  bearing: 45.0,
  distance: 1000, // meters
);

// Calculate midpoint
Map mid = GeoMath.calculateMidpoint(
  lat1, lon1, lat2, lon2,
);

// Conversions
double rad = GeoMath.degreesToRadians(180);
double deg = GeoMath.radiansToDegrees(3.14159);
'''),
        _buildServiceSection('GeoPoint Extensions', '''
// Convert to Flutter LatLng
LatLng latLng = geoPoint.toFlutterLatLng();

// Convert to Google LatLng
GoogleLatLng gLatLng = geoPoint.toGoogleLatLng();

// Convert list
List<LatLng> list = points.toFlutterLatLngList();
'''),
        const SizedBox(height: 16),
        _buildUsageExample('Complete Working Example', '''
import 'package:geo_fence_utils/geo_fence_utils.dart';

// Create a geofence
final geofence = GeoCircleWidget.dangerZone(
  id: 'danger_zone',
  center: GeoPoint(latitude: 37.7749, longitude: -122.4194),
  radius: 500,
);

// Check if a point is inside
final testPoint = GeoPoint(latitude: 37.78, longitude: -122.42);
final isInside = GeoCircleService.isInsideCircle(
  point: testPoint,
  circle: GeoCircle(
    center: geofence.center,
    radius: geofence.radius,
  ),
);

// Display on map
GeoGeofenceMap(
  center: geofence.center,
  zoom: 14.0,
  geofences: [geofence],
  onGeofenceTap: (id) => print('Tapped: \$id'),
  onMapTap: (loc) => print('Tapped: \${loc.latitude}, \${loc.longitude}'),
);
'''),
      ],
    );
  }

  Widget _buildServiceSection(String title, String code) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            )),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(code, style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
              )),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // MAP AREA
  // ============================================

  Widget _buildMapArea() {
    return Container(
      color: Colors.grey.shade300,
      child: Stack(
        children: [
          _buildSelectedMap(),
          // Fix #7: Limit width and position to avoid overlap
          if (_selectedMarker != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildMarkerInfoCard(),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedMap() {
    switch (_selectedPage) {
      case 0:
        // Fix #4: Show all when no selection, otherwise show selected
        final geofences = _tappedGeofenceId != null
            ? _circleExamples.where((g) => g.id == _tappedGeofenceId).toList()
            : _circleExamples;
        return _buildMapWithGeofences(geofences);
      case 1:
        final geofences = _tappedGeofenceId != null
            ? _polygonExamples.where((g) => g.id == _tappedGeofenceId).toList()
            : _polygonExamples;
        return _buildMapWithGeofences(geofences);
      case 2:
        final geofences = _tappedGeofenceId != null
            ? _polylineExamples.where((g) => g.id == _tappedGeofenceId).toList()
            : _polylineExamples;
        return _buildMapWithGeofences(geofences);
      case 3:
        // Markers page - show markers
        final markers = _tappedMarkerId != null
            ? _markerExamples.where((m) => m.id == _tappedMarkerId).toList()
            : _markerExamples;
        return _buildMapWithMarkers(markers);
      case 4:
        // Fix #5: Use selectedScenarioIndex instead of string parsing
        if (_selectedScenarioIndex != null) {
          return _buildMapWithGeofences(_combinedScenes[_selectedScenarioIndex!]);
        }
        return _buildMapWithGeofences(_combinedScenes[0]);
      case 5:
        return _buildMapWithGeofences(_circleExamples.take(3).toList());
      default:
        return _buildMapWithGeofences(_circleExamples);
    }
  }

  Widget _buildMapWithGeofences(List<GeoGeofenceBase> geofences) {
    // Fix #9: Disable rotation/compass for desktop/web to reduce UI clutter
    return SizedBox.expand(
      child: GeoGeofenceMap(
        center: _defaultCenter,
        zoom: _defaultZoom,
        geofences: geofences,
        provider: MapProvider.flutterMap,
        // provider: MapProvider.googleMap,
        // googleMapsApiKey: "GOOGLE_MAP_API_KEY",
        showZoomControls: true,
        showCompass: false, // Disabled for cleaner UI
        showMyLocationButton: false, // Disabled as location may not be available
        enableRotation: false, // Disabled for desktop
        enableZoom: true,
        onGeofenceTap: (id) {
          setState(() => _tappedGeofenceId = id);
          _showSnackBar('Tapped geofence: $id');
        },
        onMapTap: (location) {
          setState(() {
            _tappedLocation = '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
          });
        },
      ),
    );
  }

  Widget _buildMapWithMarkers(List<GeoMarkerWidget> markers) {
    return SizedBox.expand(
      child: GeoGeofenceMap(
        center: _defaultCenter,
        zoom: _defaultZoom,
        markers: markers,
        provider: MapProvider.flutterMap,
        // provider: MapProvider.googleMap,
        // googleMapsApiKey: "GOOGLE_MAP_API_KEY",
        showZoomControls: true,
        showCompass: false,
        showMyLocationButton: false,
        enableRotation: false,
        enableZoom: true,
        onMarkerTap: (id) {
          final marker = _markerExamples.firstWhere((m) => m.id == id);

          setState(() {
            _tappedMarkerId = id;
            _selectedMarker = marker;
          });
        },
        onMapTap: (location) {
          setState(() {
            _tappedLocation = '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
          });
        },
      ),
    );
  }

  Widget _buildMapStatusCard() {
    return Card(
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Page: ${_getPageTitle(_selectedPage)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Center: ${_defaultCenter.latitude.toStringAsFixed(4)}, ${_defaultCenter.longitude.toStringAsFixed(4)}'),
            if (_tappedGeofenceId != null)
              Text('Geofence: $_tappedGeofenceId', style: const TextStyle(color: Colors.blue)),
            if (_tappedMarkerId != null)
              Text('Marker: $_tappedMarkerId', style: const TextStyle(color: Colors.orange)),
            if (_tappedLocation != null)
              Text('Location: $_tappedLocation', style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HELPER WIDGETS
  // ============================================

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildUsageExample(String title, String code) {
    return Card(
      color: Colors.blue.shade50,
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: const Icon(Icons.code, color: Colors.blue),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Text(code, style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
            )),
          ),
        ],
      ),
    );
  }

  String _getPageTitle(int page) {
    switch (page) {
      case 0: return 'Circles';
      case 1: return 'Polygons';
      case 2: return 'Polylines';
      case 3: return 'Markers';
      case 4: return 'Scenarios';
      case 5: return 'Services';
      default: return 'Unknown';
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Geo Fence Utils Library'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Circle geofences with presets'),
              Text('• Polygon geofences with bounds'),
              Text('• Polyline routes with styles'),
              Text('• Distance calculations (Haversine)'),
              Text('• Point-in-polygon detection'),
              Text('• Circle containment checks'),
              Text('• Multiple map providers (OSM, Google)'),
              Text('• Interactive tap callbacks'),
              SizedBox(height: 16),
              Text('Services:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• GeoDistanceService'),
              Text('• GeoCircleService'),
              Text('• GeoPolygonService'),
              Text('• GeoMath utilities'),
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
