import 'package:flutter/material.dart';
import '../data/cities_data.dart';

class CityPicker extends StatelessWidget {
  final String? selectedCountry;
  final String? selectedState;
  final String? selectedCity;
  final ValueChanged<String?> onCitySelected;
  final String? errorText;

  const CityPicker({
    super.key,
    required this.selectedCountry,
    this.selectedState,
    required this.selectedCity,
    required this.onCitySelected,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cities = selectedCountry != null
        ? CitiesData.getCitiesForCountryAndState(
            selectedCountry!, selectedState)
        : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'City',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: selectedCountry == null || selectedState == null
              ? null
              : () => _showCityPicker(context, cities),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_city,
                  color: selectedCountry == null || selectedState == null
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedCity ??
                        (selectedCountry == null
                            ? 'Select country first'
                            : selectedState == null
                                ? 'Select state first'
                                : 'Select your city'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: selectedCity == null
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (selectedCountry != null && selectedState != null)
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  void _showCityPicker(BuildContext context, List<String> cities) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CityPickerModal(
        cities: cities,
        selectedCity: selectedCity,
        onCitySelected: onCitySelected,
      ),
    );
  }
}

class _CityPickerModal extends StatefulWidget {
  final List<String> cities;
  final String? selectedCity;
  final ValueChanged<String?> onCitySelected;

  const _CityPickerModal({
    required this.cities,
    required this.selectedCity,
    required this.onCitySelected,
  });

  @override
  State<_CityPickerModal> createState() => _CityPickerModalState();
}

class _CityPickerModalState extends State<_CityPickerModal> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCities = [];
  bool _hasSearchQuery = false;

  @override
  void initState() {
    super.initState();
    _filteredCities = widget.cities;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _hasSearchQuery = _searchController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCities = widget.cities;
      } else {
        _filteredCities = widget.cities
            .where((city) => city.toLowerCase().contains(query.toLowerCase()))
            .toList();

        // Sort by relevance (exact matches first, then partial matches)
        _filteredCities.sort((a, b) {
          final aLower = a.toLowerCase();
          final bLower = b.toLowerCase();
          final queryLower = query.toLowerCase();

          // Exact match gets highest priority
          if (aLower == queryLower) return -1;
          if (bLower == queryLower) return 1;

          // Starts with query gets second priority
          if (aLower.startsWith(queryLower) && !bLower.startsWith(queryLower)) {
            return -1;
          }
          if (bLower.startsWith(queryLower) && !aLower.startsWith(queryLower)) {
            return 1;
          }

          // Alphabetical order for other matches
          return a.compareTo(b);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Text(
            'Select City',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search cities...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: _hasSearchQuery
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterCities('');
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              debugPrint('Search query: "$value"');
              _filterCities(value);
            },
          ),
          const SizedBox(height: 16),
          // Results count
          if (_hasSearchQuery)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${_filteredCities.length} cities found',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          // Cities list
          Expanded(
            child: _filteredCities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No cities found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = _filteredCities[index];
                      final isSelected = city == widget.selectedCity;

                      return ListTile(
                        title: Text(city),
                        leading: Icon(
                          Icons.location_city,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        selected: isSelected,
                        onTap: () {
                          debugPrint('City selected: $city');
                          widget.onCitySelected(city);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
