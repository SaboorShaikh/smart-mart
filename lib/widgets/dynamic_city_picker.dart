import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../services/location_data_service.dart';

class DynamicCityPicker extends StatefulWidget {
  final String? selectedCountry;
  final String? selectedState;
  final String? selectedCity;
  final Function(String city, String? state, String countryCode) onCitySelected;
  final String? errorText;

  const DynamicCityPicker({
    super.key,
    required this.selectedCountry,
    this.selectedState,
    this.selectedCity,
    required this.onCitySelected,
    this.errorText,
  });

  @override
  State<DynamicCityPicker> createState() => _DynamicCityPickerState();
}

class _DynamicCityPickerState extends State<DynamicCityPicker> {
  List<String> _cities = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    print(
        'DynamicCityPicker: initState - selectedCountry: ${widget.selectedCountry}, selectedState: ${widget.selectedState}');
    if (widget.selectedCountry != null) {
      _loadCities();
    }
  }

  @override
  void didUpdateWidget(DynamicCityPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(
        'DynamicCityPicker: didUpdateWidget - old: ${oldWidget.selectedCountry}/${oldWidget.selectedState}, new: ${widget.selectedCountry}/${widget.selectedState}');
    if (widget.selectedCountry != oldWidget.selectedCountry ||
        widget.selectedState != oldWidget.selectedState) {
      print('DynamicCityPicker: Country or state changed, reloading cities');
      _loadCities();
    }
  }

  Future<void> _loadCities() async {
    if (widget.selectedCountry == null) {
      setState(() {
        _cities = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final country = CountryParser.parseCountryName(widget.selectedCountry!);
      final countryCode = country.countryCode;

      print(
          'DynamicCityPicker: Loading cities for country: ${country.name} ($countryCode)');
      print('DynamicCityPicker: Selected state: ${widget.selectedState}');

      // Try to get cities for specific state first
      List<CityData> cities = [];

      if (widget.selectedState != null && widget.selectedState!.isNotEmpty) {
        try {
          print(
              'DynamicCityPicker: Trying to get cities for state: ${widget.selectedState}');
          cities = await LocationDataService.getCitiesInState(
            widget.selectedState!,
            countryCode,
          );
          print('DynamicCityPicker: Got ${cities.length} cities for state');
        } catch (stateError) {
          print(
              'DynamicCityPicker: Failed to get cities for state: $stateError');
          // Fallback: Get all cities for country
          print('DynamicCityPicker: Falling back to all cities for country');
          cities = await LocationDataService.searchCities(
            '',
            countryCode: countryCode,
            limit: 1000,
          );
          print(
              'DynamicCityPicker: Got ${cities.length} total cities for country');
        }
      } else {
        // No state selected, get all cities for country
        print('DynamicCityPicker: No state selected, getting all cities');
        cities = await LocationDataService.searchCities(
          '',
          countryCode: countryCode,
          limit: 1000,
        );
      }

      if (mounted) {
        setState(() {
          _cities = cities.map((city) => city.name).toList()..sort();
          _isLoading = false;
          print('DynamicCityPicker: Loaded ${_cities.length} cities');
        });
      }
    } catch (e) {
      print('DynamicCityPicker: Error loading cities: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load cities';
          _isLoading = false;
          _cities = [];
        });
      }
    }
  }

  void _showCityPicker() {
    showDialog(
      context: context,
      builder: (context) => _CityPickerDialog(
        title: widget.selectedState != null
            ? 'Select City in ${widget.selectedState}'
            : 'Select City',
        cities: _cities,
        selectedCity: widget.selectedCity,
        isLoading: _isLoading,
        onCitySelected: (city) {
          final country =
              CountryParser.parseCountryName(widget.selectedCountry!);
          widget.onCitySelected(
            city,
            widget.selectedState,
            country.countryCode,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        'DynamicCityPicker: build - selectedCountry: ${widget.selectedCountry}, selectedState: ${widget.selectedState}, cities: ${_cities.length}, isLoading: $_isLoading, error: $_error');
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'City',
        errorText: widget.errorText ?? _error,
        suffixIcon: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : const Icon(Icons.arrow_drop_down),
      ),
      controller: TextEditingController(text: widget.selectedCity ?? ''),
      onTap: widget.selectedCountry != null && !_isLoading
          ? _showCityPicker
          : null,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please select a city';
        }
        return null;
      },
    );
  }
}

class _CityPickerDialog extends StatefulWidget {
  final String title;
  final List<String> cities;
  final String? selectedCity;
  final bool isLoading;
  final Function(String) onCitySelected;

  const _CityPickerDialog({
    required this.title,
    required this.cities,
    required this.selectedCity,
    required this.isLoading,
    required this.onCitySelected,
  });

  @override
  State<_CityPickerDialog> createState() => _CityPickerDialogState();
}

class _CityPickerDialogState extends State<_CityPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customCityController = TextEditingController();
  List<String> _filteredCities = [];
  bool _showCustomInput = false;

  @override
  void initState() {
    super.initState();
    _filteredCities = widget.cities;
    _searchController.addListener(_filterCities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customCityController.dispose();
    super.dispose();
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCities = widget.cities;
      } else {
        _filteredCities = widget.cities
            .where((city) => city.toLowerCase().contains(query))
            .toList();
      }
      _showCustomInput = _filteredCities.isEmpty && query.isNotEmpty;
    });
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  void _selectCity(String city) {
    widget.onCitySelected(city);
    Navigator.of(context).pop();
  }

  void _saveCustomCity() {
    final customCity = _customCityController.text.trim();
    if (customCity.isNotEmpty) {
      final capitalizedCity = _capitalizeFirstLetter(customCity);
      _selectCity(capitalizedCity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            // Search field
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search cities or enter custom...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),

            // Content area
            Expanded(
              child: widget.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _showCustomInput
                      ? _buildCustomInputView()
                      : _buildCitiesList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (_showCustomInput)
          TextButton(
            onPressed: _saveCustomCity,
            child: const Text('Save'),
          ),
      ],
    );
  }

  Widget _buildCitiesList() {
    if (_filteredCities.isEmpty) {
      return const Center(
        child: Text('No cities found. Try entering a custom city above.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _filteredCities.length,
      itemBuilder: (context, index) {
        final city = _filteredCities[index];
        return ListTile(
          title: Text(city),
          selected: city == widget.selectedCity,
          onTap: () => _selectCity(city),
        );
      },
    );
  }

  Widget _buildCustomInputView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'No matching cities found. Enter a custom city:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _customCityController,
          decoration: const InputDecoration(
            labelText: 'Custom City',
            hintText: 'Enter city name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) => _saveCustomCity(),
        ),
        const SizedBox(height: 12),
        const Text(
          'Note: The first letter will be capitalized automatically.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
