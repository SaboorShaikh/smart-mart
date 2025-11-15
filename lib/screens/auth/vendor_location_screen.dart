import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:country_picker/country_picker.dart';
import '../../widgets/dynamic_city_picker.dart';
import '../../widgets/dynamic_state_picker.dart';

class VendorLocationScreen extends StatefulWidget {
  const VendorLocationScreen({super.key});

  @override
  State<VendorLocationScreen> createState() => _VendorLocationScreenState();
}

class _VendorLocationScreenState extends State<VendorLocationScreen>
    with TickerProviderStateMixin {
  final MapController _map = MapController();
  ll.LatLng? _center;
  String? _country;
  String? _state;
  String? _city;
  final TextEditingController _postal = TextEditingController();
  bool _locating = false;
  bool _fullscreen = false;
  final MapController _fullscreenMap = MapController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _center = ll.LatLng(pos.latitude, pos.longitude));
      _reverseGeocode();
    } catch (_) {
      setState(() => _center = const ll.LatLng(0, 0));
    }
  }

  Future<void> _reverseGeocode() async {
    if (_center == null) return;
    try {
      final placemarks = await geo.placemarkFromCoordinates(
          _center!.latitude, _center!.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _country = p.country;
          _state = p.administrativeArea;
          _city = (p.locality?.isNotEmpty ?? false)
              ? p.locality
              : p.subAdministrativeArea;
          _postal.text = p.postalCode ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> _forwardGeocode() async {
    final parts =
        [_city, _state, _country].where((e) => (e ?? '').isNotEmpty).join(', ');
    if (parts.isEmpty) return;
    try {
      final locs = await geo.locationFromAddress(parts);
      if (locs.isNotEmpty) {
        final l = locs.first;
        setState(() => _center = ll.LatLng(l.latitude, l.longitude));
      }
    } catch (_) {}
  }

  Future<void> _goToMyLocation() async {
    try {
      if (_locating) return;
      setState(() => _locating = true);
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition();
      final next = ll.LatLng(pos.latitude, pos.longitude);
      setState(() => _center = next);
      _map.move(next, 16);
      await _reverseGeocode();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _next() {
    final prev = (Get.arguments as Map?) ?? {};
    final payload = {
      ...prev,
      'lat': _center?.latitude,
      'lng': _center?.longitude,
      'country': _country,
      'state': _state,
      'city': _city,
      'postalCode': _postal.text.trim(),
    };
    Get.toNamed('/auth/register/vendor/delivery', arguments: payload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Mart Location')),
      body: _center == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    // Map at top with margin and rounded corners
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 260,
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _map,
                                options: MapOptions(
                                  initialCenter: _center!,
                                  initialZoom: 16,
                                  onTap: (tapPos, latlng) async {
                                    setState(() => _center = latlng);
                                    await _reverseGeocode();
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    subdomains: const ['a', 'b', 'c'],
                                  ),
                                  if (_center != null)
                                    MarkerLayer(markers: [
                                      Marker(
                                        point: _center!,
                                        width: 44,
                                        height: 44,
                                        child: const Icon(Icons.location_pin,
                                            size: 44, color: Colors.red),
                                      ),
                                    ]),
                                ],
                              ),
                              Positioned(
                                right: 12,
                                bottom: 12,
                                child: Material(
                                  color: Colors.white,
                                  elevation: 3,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: _locating ? null : _goToMyLocation,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        transitionBuilder: (child, anim) =>
                                            FadeTransition(
                                                opacity: anim, child: child),
                                        child: _locating
                                            ? const SizedBox(
                                                key: ValueKey('spinner'),
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2.2),
                                              )
                                            : const Icon(Icons.my_location,
                                                size: 22,
                                                key: ValueKey('icon')),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 12,
                                top: 12,
                                child: Material(
                                  color: Colors.white,
                                  elevation: 3,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () {
                                      setState(() => _fullscreen = true);
                                      if (_center != null) {
                                        _fullscreenMap.move(_center!, 16);
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(Icons.fullscreen, size: 22),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Fields under the map in one column
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          children: [
                            TextFormField(
                              readOnly: true,
                              decoration:
                                  const InputDecoration(labelText: 'Country'),
                              controller:
                                  TextEditingController(text: _country ?? ''),
                              onTap: () => showCountryPicker(
                                context: context,
                                showPhoneCode: false,
                                onSelect: (c) async {
                                  setState(() {
                                    _country = c.name;
                                    _state = null;
                                    _city = null;
                                  });
                                  await _forwardGeocode();
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            DynamicStatePicker(
                              selectedCountry: _country,
                              selectedState: _state,
                              onStateSelected: (state) async {
                                setState(() {
                                  _state = state;
                                  _city = null; // Reset city when state changes
                                });
                                await _forwardGeocode();
                              },
                            ),
                            const SizedBox(height: 12),
                            DynamicCityPicker(
                              selectedCountry: _country,
                              selectedState: _state,
                              selectedCity: _city,
                              onCitySelected: (city, state, countryCode) async {
                                setState(() {
                                  _city = city;
                                  if (_state == null && state != null) {
                                    _state = state;
                                  }
                                });
                                await _forwardGeocode();
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Postal Code'),
                              controller: _postal,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _next,
                                child: const Text('Next: Delivery Options'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Popup overlay kept mounted to animate in/out
                Positioned.fill(
                  child: Stack(
                    children: [
                      // Blurred dim background with animated opacity
                      Positioned.fill(
                        child: IgnorePointer(
                          ignoring: !_fullscreen,
                          child: GestureDetector(
                            onTap: () => setState(() => _fullscreen = false),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeInOut,
                              opacity: _fullscreen ? 1.0 : 0.0,
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                child: Container(
                                  color: Colors.black.withOpacity(0.25),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Animated popup map (scale + fade) with SafeArea/padding to avoid overflow
                      Positioned.fill(
                        child: IgnorePointer(
                          ignoring: !_fullscreen,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                            scale: _fullscreen ? 1.0 : 0.9,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 220),
                              opacity: _fullscreen ? 1.0 : 0.0,
                              child: Align(
                                alignment: Alignment.center,
                                child: SafeArea(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.75,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.92,
                                        child: Stack(
                                          children: [
                                            FlutterMap(
                                              mapController: _fullscreenMap,
                                              options: MapOptions(
                                                initialCenter: _center!,
                                                initialZoom: 16,
                                                onTap: (tapPos, latlng) async {
                                                  setState(
                                                      () => _center = latlng);
                                                  _map.move(latlng, 16);
                                                  await _reverseGeocode();
                                                },
                                              ),
                                              children: [
                                                TileLayer(
                                                  urlTemplate:
                                                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                  subdomains: const [
                                                    'a',
                                                    'b',
                                                    'c'
                                                  ],
                                                ),
                                                if (_center != null)
                                                  MarkerLayer(markers: [
                                                    Marker(
                                                      point: _center!,
                                                      width: 44,
                                                      height: 44,
                                                      child: const Icon(
                                                        Icons.location_pin,
                                                        size: 44,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ]),
                                              ],
                                            ),
                                            Positioned(
                                              right: 12,
                                              top: 12,
                                              child: Material(
                                                color: Colors.white,
                                                elevation: 3,
                                                shape: const CircleBorder(),
                                                child: InkWell(
                                                  customBorder:
                                                      const CircleBorder(),
                                                  onTap: () => setState(() =>
                                                      _fullscreen = false),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(10),
                                                    child: Icon(Icons.close,
                                                        size: 22),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 12,
                                              bottom: 12,
                                              child: Material(
                                                color: Colors.white,
                                                elevation: 3,
                                                shape: const CircleBorder(),
                                                child: InkWell(
                                                  customBorder:
                                                      const CircleBorder(),
                                                  onTap: _locating
                                                      ? null
                                                      : _goToMyLocation,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: AnimatedSwitcher(
                                                      duration: const Duration(
                                                          milliseconds: 200),
                                                      transitionBuilder:
                                                          (child, anim) =>
                                                              FadeTransition(
                                                                  opacity: anim,
                                                                  child: child),
                                                      child: _locating
                                                          ? const SizedBox(
                                                              key: ValueKey(
                                                                  'spinner_full'),
                                                              width: 20,
                                                              height: 20,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2.2),
                                                            )
                                                          : const Icon(
                                                              Icons.my_location,
                                                              size: 22,
                                                              key: ValueKey(
                                                                  'icon_full'),
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
