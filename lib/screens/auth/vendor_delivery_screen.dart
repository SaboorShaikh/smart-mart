import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/auth_provider.dart';
import '../../models/user.dart' as model;

class VendorDeliveryScreen extends StatefulWidget {
  const VendorDeliveryScreen({super.key});

  @override
  State<VendorDeliveryScreen> createState() => _VendorDeliveryScreenState();
}

class _VendorDeliveryScreenState extends State<VendorDeliveryScreen> {
  bool _homeDelivery = true;
  double _radiusKm = 3.0; // default at zoom ~13
  final MapController _map = MapController();
  ll.LatLng? _circleCenter;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Delivery area modes
  DeliveryAreaMode _mode = DeliveryAreaMode.manual;

  bool _isEditMode = false;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    // Load current values if in edit mode
    final args = (Get.arguments as Map?) ?? {};
    _isEditMode = args['isEditMode'] ?? false;

    if (_isEditMode) {
      final currentMode = args['currentMode'];
      debugPrint(
          'VendorDelivery - initState - Loading current mode: $currentMode');
      debugPrint('VendorDelivery - initState - All args: $args');

      // Set home delivery based on current mode
      if (currentMode == 'disabled' ||
          currentMode == null ||
          currentMode == '') {
        _homeDelivery = false;
        _mode = DeliveryAreaMode.manual; // Default when disabled
      } else {
        _homeDelivery = true;

        // Set the mode based on what was saved
        if (currentMode == 'country') {
          _mode = DeliveryAreaMode.country;
        } else if (currentMode == 'city') {
          _mode = DeliveryAreaMode.city;
        } else if (currentMode == 'manual') {
          _mode = DeliveryAreaMode.manual;
        } else {
          // Unknown mode, default to manual
          debugPrint(
              'VendorDelivery - Unknown mode: $currentMode, defaulting to manual');
          _mode = DeliveryAreaMode.manual;
        }
      }

      final currentRadius = args['currentRadius'];
      if (currentRadius != null && currentRadius > 0) {
        _radiusKm = currentRadius;
      }

      debugPrint('VendorDelivery - initState - Set values:');
      debugPrint('  _homeDelivery: $_homeDelivery');
      debugPrint('  _mode: ${_mode.name}');
      debugPrint('  _radiusKm: $_radiusKm');
    }

    // Reset initial load flag after map is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _isInitialLoad = false);
        }
      });
    });
  }

  // Calculate zoom level from radius
  double _getZoomFromRadius(double radiusKm) {
    // Reverse the formula: radius = 3.0 * 2^(13 - zoom)
    // zoom = 13 - log2(radius / 3.0)
    return 13 - (math.log(radiusKm / 3.0) / math.log(2));
  }

  void _updateRadiusFromZoom(double zoom) {
    // Don't update radius during initial load in edit mode
    // This preserves the saved radius value
    if (_isEditMode && _isInitialLoad) {
      return;
    }

    // Map zoom mapping: each +1 zoom halves the displayed radius
    // Keep 3 km at zoom 13 as baseline
    final double newRadius = 3.0 * math.pow(2, 13 - zoom).toDouble();
    if ((newRadius - _radiusKm).abs() > 0.01) {
      setState(() => _radiusKm = newRadius.clamp(0.25, 200.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args = (Get.arguments as Map?) ?? {};
    final center = ll.LatLng(
        (args['lat'] ?? 0.0) as double, (args['lng'] ?? 0.0) as double);
    _circleCenter ??= center;
    final String countryName = (args['country'] ?? 'Country') as String;
    final String cityName = (args['city'] ?? 'City') as String;

    // Calculate initial zoom based on current radius in edit mode
    final initialZoom =
        _isEditMode && _radiusKm > 0 ? _getZoomFromRadius(_radiusKm) : 13.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Options')),
      body: Column(
        children: [
          // Map or placeholder based on mode
          Expanded(
            child: _mode == DeliveryAreaMode.manual
                ? Stack(
                    children: [
                      FlutterMap(
                        mapController: _map,
                        options: MapOptions(
                          initialCenter: center,
                          initialZoom: initialZoom,
                          onMapEvent: (event) {
                            _updateRadiusFromZoom(event.camera.zoom);
                            final c = event.camera.center;
                            if (_circleCenter == null ||
                                _circleCenter!.latitude != c.latitude ||
                                _circleCenter!.longitude != c.longitude) {
                              setState(() => _circleCenter = c);
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          MarkerLayer(markers: [
                            Marker(
                              point: center,
                              width: 44,
                              height: 44,
                              child: const Icon(Icons.store,
                                  size: 40, color: Colors.red),
                            )
                          ]),
                        ],
                      ),
                      // Screen-space green circle overlay covering 70% of the smaller map dimension
                      IgnorePointer(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double size = math.min(constraints.maxWidth,
                                    constraints.maxHeight) *
                                0.7;
                            return Center(
                              child: Container(
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green.withOpacity(0.5),
                                  border:
                                      Border.all(color: Colors.green, width: 2),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _mode == DeliveryAreaMode.country
                            ? 'Delivering across: $countryName'
                            : 'Delivering across: $cityName',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Offer home delivery'),
                  value: _homeDelivery,
                  onChanged: (v) => setState(() => _homeDelivery = v),
                ),
                if (_homeDelivery) ...[
                  RadioListTile<DeliveryAreaMode>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Whole country ($countryName)'),
                    value: DeliveryAreaMode.country,
                    groupValue: _mode,
                    onChanged: (m) => setState(() => _mode = m!),
                  ),
                  RadioListTile<DeliveryAreaMode>(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Whole city ($cityName)'),
                    value: DeliveryAreaMode.city,
                    groupValue: _mode,
                    onChanged: (m) => setState(() => _mode = m!),
                  ),
                  RadioListTile<DeliveryAreaMode>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Select manually on map'),
                    value: DeliveryAreaMode.manual,
                    groupValue: _mode,
                    onChanged: (m) => setState(() => _mode = m!),
                  ),
                ],
                if (_homeDelivery && _mode == DeliveryAreaMode.manual)
                  Text(
                    'Zoom to adjust delivery radius: ${_radiusKm.toStringAsFixed(1)} km',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // If in edit mode, return the data instead of saving
                      if (_isEditMode) {
                        debugPrint('VendorDelivery - Save button pressed');
                        debugPrint('  _homeDelivery: $_homeDelivery');
                        debugPrint('  _mode: ${_mode.name}');
                        debugPrint('  _radiusKm: $_radiusKm');

                        final deliveryMode =
                            _homeDelivery ? _mode.name : 'disabled';
                        final radiusToSave =
                            _homeDelivery && _mode == DeliveryAreaMode.manual
                                ? _radiusKm
                                : null;

                        debugPrint('VendorDelivery - Returning data:');
                        debugPrint('  deliveryMode: $deliveryMode');
                        debugPrint('  deliveryCountry: $countryName');
                        debugPrint('  deliveryCity: $cityName');
                        debugPrint('  deliveryRadiusKm: $radiusToSave km');

                        Get.back(result: {
                          'deliveryMode': deliveryMode,
                          'deliveryCountry': countryName,
                          'deliveryCity': cityName,
                          'deliveryRadiusKm': radiusToSave,
                        });
                        return;
                      }

                      // Original registration flow
                      final auth =
                          Provider.of<AuthProvider>(context, listen: false);
                      final current = auth.user;
                      if (current == null) {
                        Get.offAllNamed('/auth/login');
                        return;
                      }

                      final shopName = (args['shopName'] ?? '') as String;
                      final ownerName =
                          (args['ownerName'] ?? current.name) as String;

                      // Get location data from the location screen
                      final locationLat =
                          (args['lat'] ?? center.latitude) as double;
                      final locationLng =
                          (args['lng'] ?? center.longitude) as double;
                      final locationCountry =
                          (args['country'] ?? countryName) as String;
                      final locationState = (args['state'] ?? '') as String;
                      final locationCity = (args['city'] ?? cityName) as String;
                      final locationPostalCode =
                          (args['postalCode'] ?? '') as String;

                      // Create full address string
                      final fullAddress =
                          '$locationCity, $locationState, $locationCountry $locationPostalCode'
                              .trim();

                      final vendor = model.Vendor(
                        id: current.id,
                        email: current.email,
                        name: current
                            .name, // Use the account holder's name, not ownerName
                        shopName: shopName,
                        shopAddress: fullAddress,
                        shopPhone: current.phone ?? '',
                        isApproved: model.ApprovalStatus.pending,
                        deliveryEnabled: _homeDelivery,
                        pickupEnabled: true,
                        businessLicense: '',
                        commissionRate: 0,
                        phone: current.phone,
                        avatar: current.avatar,
                        createdAt: current.createdAt,
                        updatedAt: DateTime.now(),
                        location: model.LocationData(
                          latitude: locationLat,
                          longitude: locationLng,
                          address: fullAddress,
                          city: locationCity,
                          state: locationState,
                          country: locationCountry,
                          postalCode: locationPostalCode,
                        ),
                        address: fullAddress,
                        city: locationCity,
                        state: locationState,
                        country: locationCountry,
                        postalCode: locationPostalCode,
                      );

                      final vendorData = {
                        ...vendor.toJson(),
                        'role': 'vendor',
                        'deliveryMode': _homeDelivery ? _mode.name : 'disabled',
                        'deliveryCountry': countryName,
                        'deliveryCity': cityName,
                        'deliveryRadiusKm':
                            _homeDelivery && _mode == DeliveryAreaMode.manual
                                ? _radiusKm
                                : 0,
                      };

                      debugPrint(
                          'Vendor Delivery - Saving vendor data to Firebase:');
                      debugPrint('Shop Name: $shopName');
                      debugPrint('Owner Name: $ownerName');
                      debugPrint('Full Address: $fullAddress');
                      debugPrint('Location: $locationLat, $locationLng');
                      debugPrint(
                          'City: $locationCity, State: $locationState, Country: $locationCountry');
                      debugPrint('Postal Code: $locationPostalCode');
                      debugPrint('Delivery Enabled: $_homeDelivery');
                      debugPrint(
                          'Delivery Mode: ${_homeDelivery ? _mode.name : 'disabled'}');
                      debugPrint(
                          'Delivery Radius: ${_homeDelivery && _mode == DeliveryAreaMode.manual ? _radiusKm : 0} km');

                      // Create a separate vendor record instead of updating the existing user
                      final vendorDocRef =
                          await _firestore.collection('users').add(vendorData);
                      debugPrint(
                          'Vendor Delivery - Created vendor record with ID: ${vendorDocRef.id}');

                      await auth.loadCurrentUser();
                      Get.offAllNamed('/vendor');
                    },
                    child: Text(_isEditMode
                        ? 'Save Delivery Range'
                        : 'Finish and Start Selling'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Delivery area modes declaration
enum DeliveryAreaMode { country, city, manual }
