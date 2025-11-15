import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/dynamic_city_picker.dart';
import '../../widgets/dynamic_state_picker.dart';

class CustomerLocationScreen extends StatefulWidget {
  const CustomerLocationScreen({super.key});

  @override
  State<CustomerLocationScreen> createState() => _CustomerLocationScreenState();
}

class _CustomerLocationScreenState extends State<CustomerLocationScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _country;
  String? _state;
  String? _city;
  final TextEditingController _address1 = TextEditingController();
  final TextEditingController _address2 = TextEditingController();
  final TextEditingController _postalCode = TextEditingController();
  bool _pickerError = false;

  @override
  void dispose() {
    _address1.dispose();
    _address2.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Location'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with map icon
              Center(
                child: Image.asset(
                  'assets/icons/map_icon.png',
                  width: 64,
                  height: 64,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Country'),
                controller: TextEditingController(text: _country ?? ''),
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: false,
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
              const SizedBox(height: 12),
              DynamicStatePicker(
                selectedCountry: _country,
                selectedState: _state,
                onStateSelected: (state) => setState(() {
                  _state = state;
                  _city = null; // Reset city when state changes
                  _pickerError = false;
                }),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _address1,
                decoration: const InputDecoration(labelText: 'Address line 1'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address2,
                decoration: const InputDecoration(
                    labelText: 'Address line 2 (optional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _postalCode,
                decoration: const InputDecoration(labelText: 'Postal Code'),
                keyboardType: TextInputType.text,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Continue',
                onPressed: () {
                  final validForm = _formKey.currentState!.validate();
                  final validPicker =
                      _country != null && _state != null && _city != null;
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
                  Get.toNamed('/auth/register/customer/account',
                      arguments: data);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
