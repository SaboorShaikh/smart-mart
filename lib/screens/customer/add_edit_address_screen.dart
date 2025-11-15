import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/address.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address;
  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _labelCtrl = TextEditingController();
  AddressLabelType _labelType = AddressLabelType.home;
  final TextEditingController _streetCtrl = TextEditingController();
  final TextEditingController _houseCtrl = TextEditingController();
  final TextEditingController _landmarkCtrl = TextEditingController();
  final TextEditingController _floorCtrl = TextEditingController();

  ll.LatLng? _pickedLatLng;
  String? _placeName;
  final MapController _mapController = MapController();
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      final a = widget.address!;
      _labelType = a.labelType;
      _labelCtrl.text = a.label;
      _streetCtrl.text = a.street;
      _houseCtrl.text = a.houseNumber ?? '';
      _landmarkCtrl.text = a.landmark ?? '';
      _floorCtrl.text = a.floor ?? '';
      _pickedLatLng = ll.LatLng(a.latitude, a.longitude);
      _placeName = a.placeName;
      _loadingLocation = false;
    } else {
      _initLocation();
    }
  }

  Future<void> _initLocation() async {
    try {
      final hasPermission = await Geolocator.checkPermission();
      if (hasPermission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _pickedLatLng = ll.LatLng(pos.latitude, pos.longitude);
        _loadingLocation = false;
      });
      unawaited(_reverseGeocode());
    } catch (_) {
      setState(() => _loadingLocation = false);
    }
  }

  Future<void> _reverseGeocode() async {
    if (_pickedLatLng == null) return;
    try {
      final placemarks = await geo.placemarkFromCoordinates(
        _pickedLatLng!.latitude,
        _pickedLatLng!.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _placeName = [p.name, p.subLocality, p.locality]
              .where((e) => (e ?? '').isNotEmpty)
              .join(', ');
        });
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _pickedLatLng == null) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    if (userId == null) return;

    final now = DateTime.now();
    final model = AddressModel(
      id: widget.address?.id ?? '',
      userId: userId,
      labelType: _labelType,
      label: _labelCtrl.text.trim().isEmpty
          ? _defaultLabelForType(_labelType)
          : _labelCtrl.text.trim(),
      street: _streetCtrl.text.trim(),
      houseNumber:
          _houseCtrl.text.trim().isEmpty ? null : _houseCtrl.text.trim(),
      landmark:
          _landmarkCtrl.text.trim().isEmpty ? null : _landmarkCtrl.text.trim(),
      floor: _floorCtrl.text.trim().isEmpty ? null : _floorCtrl.text.trim(),
      latitude: _pickedLatLng!.latitude,
      longitude: _pickedLatLng!.longitude,
      placeName: _placeName,
      createdAt: widget.address?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.address == null) {
      await FirestoreService.addAddress(userId, model);
    } else {
      await FirestoreService.updateAddress(userId, model);
    }
    Get.back();
  }

  String _defaultLabelForType(AddressLabelType t) {
    switch (t) {
      case AddressLabelType.home:
        return 'Home';
      case AddressLabelType.work:
        return 'Work';
      case AddressLabelType.other:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Add Address' : 'Edit Address'),
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.save, color: Colors.white),
              SizedBox(width: 8),
              Text('Save',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.06),
              theme.colorScheme.secondary.withOpacity(0.04),
            ],
          ),
        ),
        child: _loadingLocation
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Material(
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 260,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.surface.withOpacity(0.96),
                              theme.colorScheme.surfaceContainerHighest
                                  .withOpacity(0.92),
                            ],
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter:
                                      _pickedLatLng ?? const ll.LatLng(0, 0),
                                  initialZoom: 16,
                                  onTap: (tapPos, latlng) {
                                    setState(() => _pickedLatLng = latlng);
                                    _reverseGeocode();
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    subdomains: const ['a', 'b', 'c'],
                                  ),
                                  if (_pickedLatLng != null)
                                    MarkerLayer(markers: [
                                      Marker(
                                        point: _pickedLatLng!,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(Icons.location_pin,
                                            size: 40, color: Colors.red),
                                      ),
                                    ]),
                                ],
                              ),
                              if (_placeName != null)
                                Positioned(
                                  left: 12,
                                  bottom: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.surface
                                              .withOpacity(0.95),
                                          theme.colorScheme
                                              .surfaceContainerHighest
                                              .withOpacity(0.9),
                                        ],
                                      ),
                                    ),
                                    child: Text(_placeName!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Material(
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.surface.withOpacity(0.96),
                                theme.colorScheme.surfaceContainerHighest
                                    .withOpacity(0.92),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildLabelChip(
                                          theme, 'Home', AddressLabelType.home),
                                      _buildLabelChip(
                                          theme, 'Work', AddressLabelType.work),
                                      _buildLabelChip(theme, 'Other',
                                          AddressLabelType.other),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _labelCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Custom label (optional)',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _streetCtrl,
                                    decoration: const InputDecoration(
                                        labelText: 'Street'),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Street is required'
                                            : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _houseCtrl,
                                    decoration: const InputDecoration(
                                        labelText: 'House number (optional)'),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _landmarkCtrl,
                                    decoration: const InputDecoration(
                                        labelText: 'Landmark (optional)'),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _floorCtrl,
                                    decoration: const InputDecoration(
                                        labelText: 'Floor (optional)'),
                                  ),
                                ],
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
    );
  }

  Widget _buildLabelChip(ThemeData theme, String text, AddressLabelType type) {
    final bool selected = _labelType == type;
    return InkWell(
      onTap: () => setState(() => _labelType = type),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: selected
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.22),
                    theme.colorScheme.secondary.withOpacity(0.20),
                  ],
                )
              : null,
          border: Border.all(
            color: (selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant)
                .withOpacity(0.6),
          ),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
