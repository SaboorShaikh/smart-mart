import 'dart:ui';

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
    final mediaQuery = MediaQuery.of(context);

    showGeneralDialog(
      context: context,
      barrierLabel: 'City Picker',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, _, __) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.08),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta != null &&
                      details.primaryDelta! > 12) {
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  height: mediaQuery.size.height * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: _CityPickerDialog(
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
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position:
              Tween(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        'DynamicCityPicker: build - selectedCountry: ${widget.selectedCountry}, selectedState: ${widget.selectedState}, cities: ${_cities.length}, isLoading: $_isLoading, error: $_error');
    final isEnabled =
        widget.selectedCountry != null && widget.selectedState != null;

    return TextFormField(
      readOnly: true,
      enabled: isEnabled,
      decoration: InputDecoration(
        labelText: 'City',
        hintText: isEnabled ? null : 'Select state/region first',
        errorText: isEnabled
            ? widget.errorText ?? _error
            : 'Select state/region first',
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
      onTap: isEnabled && !_isLoading ? _showCityPicker : null,
      validator: (value) {
        if (!isEnabled) {
          return 'Select state/region first';
        }
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
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 0,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search cities or enter custom...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xFFF7F8FA),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 1.2,
                            ),
                          ),
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: constraints.maxHeight - 150,
                        child: widget.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _showCustomInput
                                ? _buildCustomInputView(theme)
                                : _buildCitiesList(),
                      ),
                      const SizedBox(height: 8),
                      if (_showCustomInput)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _saveCustomCity,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Save'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCitiesList() {
    if (_filteredCities.isEmpty) {
      return const Center(
        child: Text('No cities found. Try entering a custom city above.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 12),
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: _filteredCities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final city = _filteredCities[index];
        final isSelected = city == widget.selectedCity;
        return Material(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF9FAFB),
          elevation: isSelected ? 1 : 0,
          shadowColor: Colors.black.withOpacity(0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? const Color(0xFFBFDBFE) : const Color(0xFFE5E7EB),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _selectCity(city),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      city,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF111827),
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomInputView(ThemeData theme) {
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
          decoration: InputDecoration(
            labelText: 'Custom City',
            hintText: 'Enter city name',
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.2,
              ),
            ),
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
