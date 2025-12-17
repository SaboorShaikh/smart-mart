import 'dart:ui';

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
    final mediaQuery = MediaQuery.of(context);
    showGeneralDialog(
      context: context,
      barrierLabel: 'State Picker',
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
                  child: _StatePickerDialog(
                    title:
                        'Select State/Region in ${widget.selectedCountry ?? "Country"}',
                    states: _states,
                    selectedState: widget.selectedState,
                    isLoading: _isLoading,
                    onStateSelected: widget.onStateSelected,
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
    final isEnabled = widget.selectedCountry != null;

    return TextFormField(
      readOnly: true,
      enabled: isEnabled,
      decoration: InputDecoration(
        labelText: 'State/Region',
        hintText: isEnabled ? null : 'Select country first',
        errorText: isEnabled ? _error : 'Select country first',
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
      onTap: isEnabled && !_isLoading ? _showStatePicker : null,
      validator: (value) {
        if (!isEnabled) {
          return 'Select country first';
        }
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
                          hintText: 'Search states or enter custom...',
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
                                : _buildStatesList(),
                      ),
                      const SizedBox(height: 8),
                      if (_showCustomInput)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _saveCustomState,
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

  Widget _buildStatesList() {
    if (_filteredStates.isEmpty) {
      return const Center(
        child: Text('No states found. Try entering a custom state above.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 12),
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: _filteredStates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final state = _filteredStates[index];
        final isSelected = state == widget.selectedState;
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
            onTap: () => _selectState(state),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      state,
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
          'No matching states found. Enter a custom state:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _customStateController,
          decoration: InputDecoration(
            labelText: 'Custom State/Region',
            hintText: 'Enter state name',
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
