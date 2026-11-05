import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/tenant_service.dart';
import '../../ptx/models/property_model.dart';
import '../../ptx/services/property_service.dart';

class GisSpatialView extends StatefulWidget {
  const GisSpatialView({super.key});

  @override
  State<GisSpatialView> createState() => _GisSpatialViewState();
}

class _GisSpatialViewState extends State<GisSpatialView>
    with TickerProviderStateMixin {
  final PropertyService _propertyService = PropertyService();
  final TenantService _tenantService = TenantService();
  final MapController _mapController = MapController();

  AnimationController? _moveAnimationController;
  Timer? _holdDelayTimer;
  Timer? _holdZoomTimer;

  String _selectedLayer = 'All';
  String? _selectedParcelUlpin;
  bool _isLoading = true;
  bool _isSatelliteLayer = false;
  List<PropertySummary> _properties = [];

  // Center coordinates by tenant
  final Map<String, LatLng> _tenantCenters = {
    'GWMC': const LatLng(17.9820, 79.5910), // Greater Warangal
    'GHMC': const LatLng(17.4150, 78.4350), // Greater Hyderabad
  };

  // Real geographic coordinates for parcels
  final Map<String, LatLng> _parcelGeoCoords = {
    'TG-GWMC-506001-00123': const LatLng(17.9825, 79.5890), // Subedari West
    'TG-GWMC-506001-00124': const LatLng(17.9910, 79.5980), // Nakkalagutta
    'TG-GWMC-506001-00125': const LatLng(18.0050, 79.5680), // KU Cross Roads
    'TG-GWMC-506001-00126': const LatLng(17.9620, 79.6200), // Industrial Zone
    'TG-GWMC-506001-00127': const LatLng(17.9740, 79.5850), // Balasamudram
  };

  @override
  void initState() {
    super.initState();
    _tenantService.activeTenant.addListener(_onTenantChanged);
    _loadProperties();
  }

  @override
  void dispose() {
    _holdDelayTimer?.cancel();
    _holdZoomTimer?.cancel();
    _moveAnimationController?.dispose();
    _tenantService.activeTenant.removeListener(_onTenantChanged);
    _mapController.dispose();
    super.dispose();
  }

  void _onTenantChanged() {
    _loadProperties();
    final tenantId = _tenantService.activeTenant.value.tenantId;
    final center = _tenantCenters[tenantId] ?? const LatLng(17.9820, 79.5910);
    _animatedMapMove(center, 14.5, duration: const Duration(milliseconds: 450));
  }

  /// Smoothly animates the Leaflet map's center and zoom using an easing curve
  void _animatedMapMove(
    LatLng destLocation,
    double destZoom, {
    Duration duration = const Duration(milliseconds: 320),
  }) {
    _moveAnimationController?.stop();
    _moveAnimationController?.dispose();

    final camera = _mapController.camera;
    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: camera.zoom,
      end: destZoom.clamp(4.0, 18.5),
    );

    final controller = AnimationController(
      duration: duration,
      vsync: this,
    );
    _moveAnimationController = controller;

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        if (_moveAnimationController == controller) {
          _moveAnimationController = null;
        }
        controller.dispose();
      }
    });

    controller.forward();
  }

  /// Continuous smooth zooming when the user clicks and holds the zoom button
  void _startContinuousZoom({required bool zoomIn}) {
    _holdZoomTimer?.cancel();
    _holdZoomTimer = Timer.periodic(const Duration(milliseconds: 45), (timer) {
      final currentZoom = _mapController.camera.zoom;
      final newZoom = zoomIn
          ? (currentZoom + 0.12).clamp(4.0, 18.5)
          : (currentZoom - 0.12).clamp(4.0, 18.5);

      if (newZoom == currentZoom) {
        _stopContinuousZoom();
        return;
      }
      _mapController.move(_mapController.camera.center, newZoom);
    });
  }

  void _stopContinuousZoom() {
    _holdZoomTimer?.cancel();
    _holdZoomTimer = null;
  }

  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);
    final props = await _propertyService.listProperties(limit: 50);
    if (!mounted) return;

    if (props.isEmpty) {
      _properties = [
        PropertySummary(
          id: 'p-1',
          ulpin: 'TG-GWMC-506001-00123',
          surveyNumber: '142/A',
          address: 'H.No 2-4-123, Postal Colony, Subedari, Hanamkonda',
          wardNumber: 12,
          wardName: 'Subedari West',
          totalUnits: 1,
          ptin: 'PTIN-GWMC-2026-00042',
          ownerName: 'Ramesh Chandra',
          usageCategory: 'Residential',
          currentDemandAmount: 4250.0,
          taxStatus: 'DUE',
        ),
        PropertySummary(
          id: 'p-2',
          ulpin: 'TG-GWMC-506001-00124',
          surveyNumber: '89/B',
          address: 'Shop 12, Main Road, Nakkalagutta, Hanamkonda',
          wardNumber: 14,
          wardName: 'Nakkalagutta Commercial',
          totalUnits: 4,
          ptin: 'PTIN-GWMC-2026-00098',
          ownerName: 'Suresh Commercial Enterprises',
          usageCategory: 'Commercial',
          currentDemandAmount: 18500.0,
          taxStatus: 'ARREARS',
        ),
        PropertySummary(
          id: 'p-3',
          ulpin: 'TG-GWMC-506001-00125',
          surveyNumber: '210/1',
          address: 'Plot 45, Kakatiya University Road, Hanamkonda',
          wardNumber: 8,
          wardName: 'KU Cross Roads',
          totalUnits: 1,
          ptin: 'PTIN-GWMC-2026-00115',
          ownerName: 'Anitha Rao',
          usageCategory: 'Residential',
          currentDemandAmount: 3200.0,
          taxStatus: 'PAID',
        ),
        PropertySummary(
          id: 'p-4',
          ulpin: 'TG-GWMC-506001-00126',
          surveyNumber: '55/C',
          address: 'Warehouse Complex, Industrial Estate, Warangal',
          wardNumber: 22,
          wardName: 'Industrial Zone East',
          totalUnits: 2,
          ptin: 'PTIN-GWMC-2026-00210',
          ownerName: 'Sri Balaji Logistics',
          usageCategory: 'Commercial',
          currentDemandAmount: 24600.0,
          taxStatus: 'DUE',
        ),
        PropertySummary(
          id: 'p-5',
          ulpin: 'TG-GWMC-506001-00127',
          surveyNumber: '11/4',
          address: 'H.No 1-8-442, Balasamudram, Hanamkonda',
          wardNumber: 5,
          wardName: 'Balasamudram Central',
          totalUnits: 1,
          ptin: 'PTIN-GWMC-2026-00304',
          ownerName: 'Dr. K. Srinivas',
          usageCategory: 'Residential',
          currentDemandAmount: 6400.0,
          taxStatus: 'PAID',
        ),
      ];
    } else {
      _properties = props;
    }

    setState(() => _isLoading = false);
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return AppTheme.statusPaid;
      case 'DUE':
        return AppTheme.statusDue;
      case 'ARREARS':
        return AppTheme.statusArrears;
      default:
        return AppTheme.textMuted;
    }
  }

  void _showParcelDetailSheet(PropertySummary parcel, LatLng coords) {
    final statusColor = _getStatusColor(parcel.taxStatus);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        parcel.ulpin,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        parcel.taxStatus,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  parcel.ownerName,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  parcel.address,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEEF0F3)),
                  ),
                  child: Column(
                    children: [
                      _buildRow('Leaflet GPS Coords', '${coords.latitude.toStringAsFixed(4)}° N, ${coords.longitude.toStringAsFixed(4)}° E'),
                      _buildRow('Ward Boundary', '${parcel.wardName ?? "Ward"} (#${parcel.wardNumber ?? 12})'),
                      _buildRow('Survey Number', parcel.surveyNumber),
                      _buildRow('Usage Category', parcel.usageCategory),
                      _buildRow('Tax Demand', '₹${parcel.currentDemandAmount.toStringAsFixed(0)}', isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _animatedMapMove(coords, 16.5, duration: const Duration(milliseconds: 380));
                        },
                        icon: const Icon(Icons.zoom_in, size: 18),
                        label: const Text('Zoom to Parcel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.secondaryTeal,
                              content: Text('Field Geo-Survey triggered for ${parcel.ulpin}'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.gps_fixed, size: 18),
                        label: const Text('Start Survey'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentSaffron,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? AppTheme.primaryNavy : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTenant = _tenantService.activeTenant.value;
    final initialCenter = _tenantCenters[activeTenant.tenantId] ?? const LatLng(17.9820, 79.5910);

    // Filter properties according to active layer chip
    final filteredProps = _properties.where((p) {
      if (_selectedLayer == 'Residential') return p.usageCategory == 'Residential';
      if (_selectedLayer == 'Commercial') return p.usageCategory == 'Commercial';
      if (_selectedLayer == 'Arrears Alerts') return p.taxStatus == 'ARREARS';
      return true;
    }).toList();

    return Column(
      children: [
        // Top Spatial Status Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.map_rounded, color: AppTheme.secondaryTeal, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${activeTenant.tenantId} • Leaflet GIS Map',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.gps_fixed, size: 11, color: AppTheme.statusPaid),
                        SizedBox(width: 3),
                        Text(
                          'Leaflet Tiles • GPS Fixed: ±2.4m',
                          style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${filteredProps.length} Parcels',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                ),
              ),
            ],
          ),
        ),

        // Layer Filter Pills
        Container(
          height: 42,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildLayerChip('All', Icons.grid_view_rounded),
              _buildLayerChip('Residential', Icons.home_rounded),
              _buildLayerChip('Commercial', Icons.storefront_rounded),
              _buildLayerChip('Arrears Alerts', Icons.warning_amber_rounded),
            ],
          ),
        ),

        // Interactive Leaflet Map View
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    // Leaflet FlutterMap Container
                    ClipRRect(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: initialCenter,
                          initialZoom: 14.5,
                          minZoom: 4.0,
                          maxZoom: 18.5,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all,
                          ),
                          onTap: (tapPosition, point) {
                            setState(() => _selectedParcelUlpin = null);
                          },
                        ),
                        children: [
                          // Base Leaflet TileLayer (OpenStreetMap or Satellite)
                          TileLayer(
                            urlTemplate: _isSatelliteLayer
                                ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                                : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'org.suvidha.urban',
                          ),

                          // Cadastral Ward Boundaries (Leaflet PolygonLayer)
                          PolygonLayer(
                            polygons: [
                              // Ward 12 Boundary Polygon (Subedari West)
                              Polygon(
                                points: const [
                                  LatLng(17.9860, 79.5840),
                                  LatLng(17.9880, 79.5930),
                                  LatLng(17.9800, 79.5950),
                                  LatLng(17.9780, 79.5860),
                                ],
                                color: AppTheme.secondaryTeal.withValues(alpha: 0.12),
                                borderColor: AppTheme.secondaryTeal,
                                borderStrokeWidth: 2,
                              ),
                              // Ward 14 Boundary Polygon (Nakkalagutta Commercial)
                              Polygon(
                                points: const [
                                  LatLng(17.9940, 79.5940),
                                  LatLng(17.9960, 79.6040),
                                  LatLng(17.9870, 79.6050),
                                  LatLng(17.9860, 79.5960),
                                ],
                                color: AppTheme.accentSaffron.withValues(alpha: 0.12),
                                borderColor: AppTheme.accentSaffron,
                                borderStrokeWidth: 2,
                              ),
                            ],
                          ),

                          // Municipal Property Parcel Markers (Leaflet MarkerLayer)
                          MarkerLayer(
                            markers: filteredProps.map((p) {
                              final coords = _parcelGeoCoords[p.ulpin] ??
                                  LatLng(
                                    initialCenter.latitude + ((p.ulpin.hashCode % 20) - 10) * 0.0015,
                                    initialCenter.longitude + ((p.ownerName.hashCode % 20) - 10) * 0.0015,
                                  );

                              final isSelected = _selectedParcelUlpin == p.ulpin;
                              final color = _getStatusColor(p.taxStatus);

                              return Marker(
                                point: coords,
                                width: 85,
                                height: 60,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedParcelUlpin = p.ulpin);
                                    _showParcelDetailSheet(p, coords);
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Top Tag
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: color, width: 1.2),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 3,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          p.ulpin.split('-').last,
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                      // Marker Pin
                                      Icon(
                                        Icons.location_on,
                                        color: color,
                                        size: isSelected ? 34 : 28,
                                        shadows: const [
                                          Shadow(
                                            color: Colors.black38,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // Floating Map Controls (Satellite Switch, Zoom In/Out, Center)
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Column(
                        children: [
                          _buildMapControlBtn(
                            _isSatelliteLayer ? Icons.map_outlined : Icons.satellite_alt_rounded,
                            _isSatelliteLayer ? 'Street Map' : 'Satellite Ortho',
                            () {
                              setState(() => _isSatelliteLayer = !_isSatelliteLayer);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(milliseconds: 900),
                                  content: Text(
                                    _isSatelliteLayer
                                        ? 'Switched to Esri Satellite Ortho Tiles'
                                        : 'Switched to OpenStreetMap Standard Tiles',
                                  ),
                                ),
                              );
                            },
                            isActive: _isSatelliteLayer,
                          ),
                          const SizedBox(height: 8),

                          // Smooth Zoom In Button (with press & hold continuous zoom)
                          _buildZoomButton(
                            isZoomIn: true,
                            tooltip: 'Zoom In (Hold to Zoom)',
                          ),
                          const SizedBox(height: 8),

                          // Smooth Zoom Out Button (with press & hold continuous zoom)
                          _buildZoomButton(
                            isZoomIn: false,
                            tooltip: 'Zoom Out (Hold to Zoom)',
                          ),
                          const SizedBox(height: 8),

                          // Smooth Center on Ward Button
                          _buildMapControlBtn(
                            Icons.my_location_rounded,
                            'Center on Ward',
                            () {
                              _animatedMapMove(initialCenter, 14.5, duration: const Duration(milliseconds: 400));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 1),
                                  content: Text('Centered on ${activeTenant.tenantId} Municipal Center'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Leaflet Powered Attribution & Watermark Pill
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.layers_rounded, size: 12, color: AppTheme.secondaryTeal),
                            SizedBox(width: 4),
                            Text(
                              'Leaflet • OSM / Esri',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Floating Geotag Tool Banner
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.touch_app_rounded, color: AppTheme.accentSaffron, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Pan, pinch or hold zoom buttons to inspect cadastral parcels',
                                style: TextStyle(color: Colors.white, fontSize: 11.5, height: 1.2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: AppTheme.secondaryTeal,
                                    content: Text('GPS Geotag crosshair activated. Tap map point.'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryTeal,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: const Size(60, 32),
                              ),
                              child: const Text('Geotag', style: TextStyle(fontSize: 11, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  /// Custom Interactive Zoom Button supporting single tap smooth animation & hold-to-zoom
  Widget _buildZoomButton({
    required bool isZoomIn,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTapDown: (_) {
          _holdDelayTimer?.cancel();
          // After 220ms of continuous press, activate smooth continuous zooming
          _holdDelayTimer = Timer(const Duration(milliseconds: 220), () {
            _startContinuousZoom(zoomIn: isZoomIn);
          });
        },
        onTapUp: (_) {
          final wasHolding = _holdZoomTimer != null;
          _holdDelayTimer?.cancel();
          _stopContinuousZoom();

          // If released before hold threshold, smoothly animate zoom by 1 step
          if (!wasHolding) {
            final targetZoom = isZoomIn
                ? _mapController.camera.zoom + 1.0
                : _mapController.camera.zoom - 1.0;
            _animatedMapMove(_mapController.camera.center, targetZoom);
          }
        },
        onTapCancel: () {
          _holdDelayTimer?.cancel();
          _stopContinuousZoom();
        },
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              isZoomIn ? Icons.add_rounded : Icons.remove_rounded,
              size: 22,
              color: AppTheme.primaryNavy,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayerChip(String label, IconData icon) {
    final isSelected = _selectedLayer == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 14,
          color: isSelected ? Colors.white : AppTheme.primaryNavy,
        ),
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF374151),
        ),
        selected: isSelected,
        selectedColor: AppTheme.primaryNavy,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? AppTheme.primaryNavy : const Color(0xFFE5E7EB),
          width: 1,
        ),
        onSelected: (_) {
          setState(() => _selectedLayer = label);
        },
      ),
    );
  }

  Widget _buildMapControlBtn(
    IconData icon,
    String tooltip,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryNavy : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 20,
          color: isActive ? Colors.white : AppTheme.primaryNavy,
        ),
        tooltip: tooltip,
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
