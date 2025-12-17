import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/dynamic_city_picker.dart';
import '../../widgets/dynamic_state_picker.dart';

class CustomerLocationScreen extends StatefulWidget {
  const CustomerLocationScreen({super.key});

  @override
  State<CustomerLocationScreen> createState() => _CustomerLocationScreenState();
}

class _CustomerLocationScreenState extends State<CustomerLocationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  String? _country;
  String? _state;
  String? _city;
  final TextEditingController _address1 = TextEditingController();
  final TextEditingController _address2 = TextEditingController();
  final TextEditingController _postalCode = TextEditingController();
  bool _pickerError = false;
  bool _isLocating = false;
  AnimationController? _pulseController;
  Animation<double>? _pulseScale;
  AnimationController? _shineController;
  Animation<double>? _shineValue;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController!,
        curve: Curves.easeInOut,
      ),
    );

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _shineValue = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shineController!, curve: Curves.linear),
    );

    _address1.addListener(_triggerRebuild);
    _address2.addListener(_triggerRebuild);
    _postalCode.addListener(_triggerRebuild);
  }

  Future<void> _fillFromCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
        setState(() => _isLocating = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location permission denied. Enable it in settings.')),
        );
        setState(() => _isLocating = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception('Could not fetch address for current location');
      }

      final place = placemarks.first;
      final countryName = place.country;
      final stateName = place.administrativeArea;
      final cityName = place.locality?.isNotEmpty == true
          ? place.locality
          : place.subAdministrativeArea;

      setState(() {
        _country = countryName;
        _state = stateName;
        _city = cityName;
        _pickerError = false;
        _address1.text = [
          place.street,
          place.subLocality,
        ].where((s) => s != null && s.trim().isNotEmpty).join(', ');
        _postalCode.text = place.postalCode ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch location: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _submit() {
    final validForm = _formKey.currentState!.validate();
    final validPicker = _country != null && _state != null && _city != null;
    if (!validPicker) {
      setState(() => _pickerError = true);
    }
    if (!validForm || !validPicker) return;
    final data = {
      'country': _country!,
      'state': _state!,
      'city': _city!,
      'address1': _address1.text.trim(),
      'address2': _address2.text.trim(),
      'postalCode': _postalCode.text.trim(),
    };
    Get.toNamed('/auth/register/customer/account', arguments: data);
  }

  @override
  void dispose() {
    _address1.dispose();
    _address2.dispose();
    _postalCode.dispose();
    _pulseController?.dispose();
    _shineController?.dispose();
    super.dispose();
  }

  void _triggerRebuild() => setState(() {});

  bool get _canSubmit {
    return _country != null &&
        _state != null &&
        _city != null &&
        _address1.text.trim().isNotEmpty &&
        _postalCode.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final inputDecorationTheme = theme.inputDecorationTheme.copyWith(
      filled: true,
      fillColor: const Color(0xFFF7F8FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.2),
      ),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF4B5563),
        fontWeight: FontWeight.w600,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _isLocating ? null : _fillFromCurrentLocation,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _isLocating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Auto-fill',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1D4ED8),
                              letterSpacing: 0.1,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Tap to autofill from current location',
                  preferBelow: false,
                  child: GestureDetector(
                    onTap: _isLocating ? null : _fillFromCurrentLocation,
                    child: AnimatedBuilder(
                      animation: _shineValue ?? const AlwaysStoppedAnimation(0.0),
                      builder: (context, child) {
                        final t = (_shineValue?.value ?? 0.0).clamp(0.0, 1.0);
                        final angle = t * 2 * math.pi;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            ScaleTransition(
                              scale:
                                  _pulseScale ?? const AlwaysStoppedAnimation(1.0),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: SweepGradient(
                                    colors: const [
                                      Color(0xFFA5F3FC),
                                      Color(0xFF60A5FA),
                                      Color(0xFFC084FC),
                                      Color(0xFFA5F3FC),
                                    ],
                                    startAngle: angle,
                                    endAngle: angle + 2 * math.pi,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: _isLocating
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/icons/map_icon.png',
                                      width: 28,
                                      height: 28,
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'Your Location',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Help us deliver accurately',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Theme(
                  data: theme.copyWith(inputDecorationTheme: inputDecorationTheme),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Country',
                            suffixIcon: Icon(Icons.arrow_drop_down),
                          ),
                          controller: TextEditingController(text: _country ?? ''),
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              showPhoneCode: false,
                              useSafeArea: true,
                              countryListTheme: CountryListThemeData(
                                bottomSheetHeight: mediaQuery.size.height * 0.8,
                                backgroundColor: Colors.white,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                                textStyle: theme.textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF111827),
                                  fontWeight: FontWeight.w600,
                                ),
                                inputDecoration: InputDecoration(
                                  hintText: 'Search country',
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: const Color(0xFFF7F8FA),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 1.2),
                                  ),
                                ),
                              ),
                              onSelect: (c) => setState(() {
                                _country = c.name;
                                _state = null; // Reset state when country changes
                                _city = null; // Reset city when country changes
                                _pickerError = false;
                              }),
                            );
                          },
                          validator: (_) =>
                              _country == null ? 'Please select a country' : null,
                        ),
                        const SizedBox(height: 14),
                        DynamicStatePicker(
                          selectedCountry: _country,
                          selectedState: _state,
                          onStateSelected: (state) => setState(() {
                            _state = state;
                            _city = null; // Reset city when state changes
                            _pickerError = false;
                          }),
                        ),
                        const SizedBox(height: 14),
                        DynamicCityPicker(
                          selectedCountry: _country,
                          selectedState: _state,
                          selectedCity: _city,
                          onCitySelected: (city, state, countryCode) => setState(() {
                            _city = city;
                            // Update state if it wasn't set
                            if (_state == null && state != null) {
                              _state = state;
                            }
                            _pickerError = false;
                          }),
                          errorText: _pickerError && _city == null
                              ? 'Please select your city'
                              : null,
                        ),
                        if (_pickerError) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Please select your country and city',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.error),
                          ),
                        ],
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _address1,
                          decoration: const InputDecoration(labelText: 'Address line 1'),
                          onChanged: (_) => setState(() {}),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _address2,
                          decoration: const InputDecoration(
                            labelText: 'Address line 2 (optional)',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _postalCode,
                          decoration: const InputDecoration(labelText: 'Postal Code'),
                          keyboardType: TextInputType.text,
                          onChanged: (_) => setState(() {}),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: CustomButton(
          text: 'Continue',
          onPressed: _submit,
          width: double.infinity,
          borderRadius: 16,
          isDisabled: !_canSubmit,
        ),
      ),
    );
  }
}
