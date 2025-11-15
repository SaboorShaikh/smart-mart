import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../services/location_data_service.dart';

class DynamicStatePicker extends StatefulWidget {
  final String? selectedCountry;
  final String? selectedState;
  final Function(String state) onStateSelected;

  const DynamicStatePicker({
    super.key,
    required this.selectedCountry,
    this.selectedState,
    required this.onStateSelected,
  });

  @override
  State<DynamicStatePicker> createState() => _DynamicStatePickerState();
}

class _DynamicStatePickerState extends State<DynamicStatePicker> {
  List<String> _states = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.selectedCountry != null) {
      _loadStates();
    }
  }

  @override
  void didUpdateWidget(DynamicStatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCountry != oldWidget.selectedCountry) {
      _loadStates();
    }
  }

  Future<void> _loadStates() async {
    if (widget.selectedCountry == null) {
      setState(() {
        _states = [];
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

      final states = await LocationDataService.getStatesForCountry(countryCode);

      if (mounted) {
        setState(() {
          _states = states;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load states';
          _isLoading = false;
          // Fallback to basic list
          _states = ['State/Region'];
        });
      }
    }
  }

  void _showStatePicker() {
    showDialog(
      context: context,
      builder: (context) => _StatePickerDialog(
        title: 'Select State/Region in ${widget.selectedCountry ?? "Country"}',
        states: _states,
        selectedState: widget.selectedState,
        isLoading: _isLoading,
        onStateSelected: widget.onStateSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'State/Region',
        errorText: _error,
        suffixIcon: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
      controller: TextEditingController(text: widget.selectedState ?? ''),
      onTap: widget.selectedCountry != null && !_isLoading
          ? _showStatePicker
          : null,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please select a state/region';
        }
        return null;
      },
    );
  }
}

class _StatePickerDialog extends StatefulWidget {
  final String title;
  final List<String> states;
  final String? selectedState;
  final bool isLoading;
  final Function(String) onStateSelected;

  const _StatePickerDialog({
    required this.title,
    required this.states,
    required this.selectedState,
    required this.isLoading,
    required this.onStateSelected,
  });

  @override
  State<_StatePickerDialog> createState() => _StatePickerDialogState();
}

class _StatePickerDialogState extends State<_StatePickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customStateController = TextEditingController();
  List<String> _filteredStates = [];
  bool _showCustomInput = false;

  @override
  void initState() {
    super.initState();
    _filteredStates = widget.states;
    _searchController.addListener(_filterStates);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customStateController.dispose();
    super.dispose();
  }

  void _filterStates() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredStates = widget.states;
      } else {
        _filteredStates = widget.states
            .where((state) => state.toLowerCase().contains(query))
            .toList();
      }
      _showCustomInput = _filteredStates.isEmpty && query.isNotEmpty;
    });
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  void _selectState(String state) {
    widget.onStateSelected(state);
    Navigator.of(context).pop();
  }

  void _saveCustomState() {
    final customState = _customStateController.text.trim();
    if (customState.isNotEmpty) {
      final capitalizedState = _capitalizeFirstLetter(customState);
      _selectState(capitalizedState);
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
                hintText: 'Search states or enter custom...',
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
                      : _buildStatesList(),
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
            onPressed: _saveCustomState,
            child: const Text('Save'),
          ),
      ],
    );
  }

  Widget _buildStatesList() {
    if (_filteredStates.isEmpty) {
      return const Center(
        child: Text('No states found. Try entering a custom state above.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _filteredStates.length,
      itemBuilder: (context, index) {
        final state = _filteredStates[index];
        return ListTile(
          title: Text(state),
          selected: state == widget.selectedState,
          onTap: () => _selectState(state),
        );
      },
    );
  }

  Widget _buildCustomInputView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'No matching states found. Enter a custom state:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _customStateController,
          decoration: const InputDecoration(
            labelText: 'Custom State/Region',
            hintText: 'Enter state name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          onSubmitted: (_) => _saveCustomState(),
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
