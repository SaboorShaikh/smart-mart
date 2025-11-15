import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';

import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/user.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/dynamic_city_picker.dart';
import '../../widgets/dynamic_state_picker.dart';

class CustomerEditProfileScreen extends StatefulWidget {
  const CustomerEditProfileScreen({super.key});

  @override
  State<CustomerEditProfileScreen> createState() =>
      _CustomerEditProfileScreenState();
}

class _CustomerEditProfileScreenState extends State<CustomerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;
  late final TextEditingController _postalCodeController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _avatarPath;
  bool _didSyncAvatarFromUser = false;

  // Store parsed location data to avoid repeated parsing
  String _parsedCity = '';
  String _parsedState = '';
  String _parsedCountry = '';
  String _parsedPostalCode = '';
  bool _isSaving = false;

  // Dropdown selection state
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    // First, try to get data from individual fields (from cloud)
    _parsedCity = user?.city ?? '';
    _parsedState = user?.state ?? '';
    _parsedCountry = user?.country ?? '';
    _parsedPostalCode = user?.postalCode ?? '';

    // Debug individual fields from cloud
    debugPrint('Edit Profile - Individual fields from cloud:');
    debugPrint('Edit Profile - Cloud city: "${user?.city}"');
    debugPrint('Edit Profile - Cloud state: "${user?.state}"');
    debugPrint('Edit Profile - Cloud country: "${user?.country}"');
    debugPrint('Edit Profile - Cloud postalCode: "${user?.postalCode}"');

    // If individual fields are empty but address exists, try to extract from address
    if (_parsedCity.isEmpty &&
        _parsedState.isEmpty &&
        _parsedCountry.isEmpty &&
        user?.address?.isNotEmpty == true) {
      debugPrint('Edit Profile - Individual fields empty, parsing address...');
      final addressParts = _extractLocationFromAddress(user?.address ?? '');
      _parsedCity = addressParts['city'] ?? '';
      _parsedState = addressParts['state'] ?? '';
      _parsedCountry = addressParts['country'] ?? '';
      _parsedPostalCode = addressParts['postalCode'] ?? '';
    }

    // If still empty, try to set some defaults based on common patterns
    if (_parsedCountry.isEmpty && user?.address?.isNotEmpty == true) {
      final address = user!.address!.toLowerCase();
      if (address.contains('pakistan')) {
        _parsedCountry = 'Pakistan';
      } else if (address.contains('usa') || address.contains('united states')) {
        _parsedCountry = 'United States';
      } else if (address.contains('canada')) {
        _parsedCountry = 'Canada';
      } else if (address.contains('uk') || address.contains('united kingdom')) {
        _parsedCountry = 'United Kingdom';
      }
    }

    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _cityController = TextEditingController(text: _parsedCity);
    _stateController = TextEditingController(text: _parsedState);
    _countryController = TextEditingController(text: _parsedCountry);
    _postalCodeController = TextEditingController(text: _parsedPostalCode);
    _avatarPath = user?.avatar;

    // Set dropdown selections
    _selectedCountry = _parsedCountry.isNotEmpty ? _parsedCountry : null;
    _selectedState = _parsedState.isNotEmpty ? _parsedState : null;
    _selectedCity = _parsedCity.isNotEmpty ? _parsedCity : null;

    // Debug dropdown selections
    debugPrint('Edit Profile - Dropdown selections set:');
    debugPrint('Edit Profile - Selected Country: "$_selectedCountry"');
    debugPrint('Edit Profile - Selected State: "$_selectedState"');
    debugPrint('Edit Profile - Selected City: "$_selectedCity"');
    debugPrint('Edit Profile - Parsed values:');
    debugPrint('Edit Profile - _parsedCountry: "$_parsedCountry"');
    debugPrint('Edit Profile - _parsedState: "$_parsedState"');
    debugPrint('Edit Profile - _parsedCity: "$_parsedCity"');

    // Debug user data
    debugPrint('Edit Profile - User data: $user');
    debugPrint('Edit Profile - User name: ${user?.name}');
    debugPrint('Edit Profile - User address: ${user?.address}');
    debugPrint('Edit Profile - User city: ${user?.city}');
    debugPrint('Edit Profile - User state: ${user?.state}');
    debugPrint('Edit Profile - User country: ${user?.country}');
    debugPrint('Edit Profile - User postalCode: ${user?.postalCode}');
    debugPrint('Edit Profile - Extracted city: $_parsedCity');
    debugPrint('Edit Profile - Extracted state: $_parsedState');
    debugPrint('Edit Profile - Extracted country: $_parsedCountry');
    debugPrint('Edit Profile - Extracted postalCode: $_parsedPostalCode');
    debugPrint('Edit Profile - User avatar: ${user?.avatar}');
    debugPrint('Edit Profile - Avatar path set to: $_avatarPath');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didSyncAvatarFromUser) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null && user.avatar != null && user.avatar!.isNotEmpty) {
        _avatarPath = user.avatar;
      }
      _didSyncAvatarFromUser = true;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      debugPrint('Edit Profile - Starting image picker with source: $source');
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, imageQuality: 85);
      if (file != null && mounted) {
        debugPrint('Edit Profile - Image selected: ${file.path}');
        debugPrint('Edit Profile - File name: ${file.name}');
        debugPrint('Edit Profile - File size: ${await file.length()} bytes');

        // Verify the file exists before setting it
        final imageFile = File(file.path);
        if (await imageFile.exists()) {
          debugPrint('Edit Profile - File exists, setting avatar path');
          setState(() {
            _avatarPath = file.path;
          });
          debugPrint('Edit Profile - Avatar path set to: $_avatarPath');
          debugPrint('Edit Profile - setState called, UI should rebuild now');

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image selected successfully!')),
            );
          }
        } else {
          debugPrint(
              'Edit Profile - Selected image file does not exist: ${file.path}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Selected image file not found')),
            );
          }
        }
      } else {
        debugPrint('Edit Profile - No image selected or widget not mounted');
      }
    } catch (e) {
      debugPrint('Edit Profile - Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    }
  }

  Future<void> _showImagePickerSheet() async {
    final theme = Theme.of(context);
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Take a photo'),
                  onTap: () async {
                    Get.back();
                    await _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from gallery'),
                  onTap: () async {
                    Get.back();
                    await _pickImage(ImageSource.gallery);
                  },
                ),
                if (_avatarPath != null)
                  ListTile(
                    leading: Icon(Icons.delete_outline,
                        color: theme.colorScheme.error),
                    title: const Text('Remove photo'),
                    onTap: () async {
                      Get.back();
                      final auth =
                          Provider.of<AuthProvider>(context, listen: false);
                      final user = auth.user;
                      if (user != null &&
                          user.avatar != null &&
                          user.avatar!.startsWith('http')) {
                        await FirestoreService.deleteProfileImage(user.avatar!);
                        await FirestoreService.updateUser(
                            user.id, {'avatar': null});
                        // Refresh current user so UI updates immediately
                        await auth.loadCurrentUser();
                      }
                      setState(() {
                        _avatarPath = null;
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Photo removed')),
                        );
                      }
                    },
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Cancel',
                      style: TextStyle(color: theme.colorScheme.primary)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final updates = <String, dynamic>{
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      'address': _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      'city':
          _selectedCity?.trim().isEmpty == true ? null : _selectedCity?.trim(),
      'state': _selectedState?.trim().isEmpty == true
          ? null
          : _selectedState?.trim(),
      'country': _selectedCountry?.trim().isEmpty == true
          ? null
          : _selectedCountry?.trim(),
      'postalCode': _postalCodeController.text.trim().isEmpty
          ? null
          : _postalCodeController.text.trim(),
      'avatar': _avatarPath,
    };
    if (_passwordController.text.isNotEmpty) {
      updates['password'] = _passwordController.text;
      debugPrint('Edit Profile - Password will be updated');
    } else {
      debugPrint('Edit Profile - No password change requested');
    }

    // Debug what we're saving
    debugPrint('Edit Profile - Saving updates: $updates');
    debugPrint('Edit Profile - Location fields being saved:');
    debugPrint('Edit Profile - City: "${updates['city']}"');
    debugPrint('Edit Profile - State: "${updates['state']}"');
    debugPrint('Edit Profile - Country: "${updates['country']}"');
    debugPrint('Edit Profile - Postal Code: "${updates['postalCode']}"');
    debugPrint('Edit Profile - Address: "${updates['address']}"');
    debugPrint('Edit Profile - Avatar being saved: ${updates['avatar']}');
    debugPrint(
        'Edit Profile - Avatar path type: ${updates['avatar'].runtimeType}');
    debugPrint(
        'Edit Profile - Avatar path starts with /: ${updates['avatar'].toString().startsWith('/')}');

    try {
      debugPrint('Edit Profile - Calling updateProfile...');
      final result = await auth.updateProfile(updates);
      setState(() => _isSaving = false);

      debugPrint(
          'Edit Profile - Update result: success=${result.success}, error=${result.error}');

      if (!mounted) return;
      if (result.success) {
        debugPrint(
            'Edit Profile - Profile updated successfully, getting updated user data...');
        final updatedUser = auth.user;
        debugPrint('Edit Profile - Updated user location data:');
        debugPrint('Edit Profile - Updated city: "${updatedUser?.city}"');
        debugPrint('Edit Profile - Updated state: "${updatedUser?.state}"');
        debugPrint('Edit Profile - Updated country: "${updatedUser?.country}"');
        debugPrint(
            'Edit Profile - Updated postalCode: "${updatedUser?.postalCode}"');
        debugPrint('Edit Profile - Updated address: "${updatedUser?.address}"');
        debugPrint(
            'Edit Profile - Updated user avatar: ${updatedUser?.avatar}');
        debugPrint(
            'Edit Profile - Updated user avatar type: ${updatedUser?.avatar.runtimeType}');
        debugPrint(
            'Edit Profile - Updated user avatar is null: ${updatedUser?.avatar == null}');
        debugPrint(
            'Edit Profile - Updated user avatar is empty: ${updatedUser?.avatar?.isEmpty}');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Get.back();
      } else {
        debugPrint('Edit Profile - Profile update failed: ${result.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.error ?? 'Failed to update profile')),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      debugPrint('Edit Profile - Profile update error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }
  }

  String _getCacheBustedUrl(String avatarUrl) {
    // Use a more stable cache busting approach
    // Only add cache busting if the URL doesn't already have parameters
    if (avatarUrl.contains('?')) {
      return avatarUrl;
    } else {
      // Add a simple cache busting parameter
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '$avatarUrl?t=$timestamp';
    }
  }

  Map<String, String> _extractLocationFromAddress(String address) {
    // Try to extract city, state, country, and postal code from address string
    // This parser works with common address formats
    final result = <String, String>{};

    debugPrint('Edit Profile - Parsing address: "$address"');

    // Handle different address formats
    if (address.contains(' - ')) {
      // Format: "City, Country - Address" (from customer registration)
      final mainParts = address.split(' - ');
      if (mainParts.length >= 2) {
        final locationPart = mainParts[0].trim();
        final locationParts =
            locationPart.split(',').map((e) => e.trim()).toList();

        if (locationParts.length >= 2) {
          result['city'] = locationParts[0];
          result['country'] = locationParts[1];

          // Try to extract state and postal code from the address part
          final addressPart = mainParts[1].trim();

          // For Pakistan, try to determine state based on city
          if (result['country']?.toLowerCase() == 'pakistan') {
            final cityName = result['city']?.toLowerCase() ?? '';
            if (cityName.contains('sukkur') ||
                cityName.contains('karachi') ||
                cityName.contains('hyderabad') ||
                cityName.contains('larkana')) {
              result['state'] = 'Sindh';
              // Set default postal codes for Sindh cities
              if (cityName.contains('sukkur')) {
                result['postalCode'] = '65200';
              } else if (cityName.contains('karachi')) {
                result['postalCode'] = '75000';
              } else if (cityName.contains('hyderabad')) {
                result['postalCode'] = '71000';
              }
            } else if (cityName.contains('lahore') ||
                cityName.contains('faisalabad') ||
                cityName.contains('rawalpindi') ||
                cityName.contains('multan')) {
              result['state'] = 'Punjab';
              // Set default postal codes for Punjab cities
              if (cityName.contains('lahore')) {
                result['postalCode'] = '54000';
              } else if (cityName.contains('faisalabad')) {
                result['postalCode'] = '38000';
              }
            } else if (cityName.contains('quetta') ||
                cityName.contains('turbat') ||
                cityName.contains('chaman')) {
              result['state'] = 'Balochistan';
              if (cityName.contains('quetta')) {
                result['postalCode'] = '87300';
              }
            } else if (cityName.contains('peshawar') ||
                cityName.contains('mardan') ||
                cityName.contains('swat')) {
              result['state'] = 'Khyber Pakhtunkhwa';
              if (cityName.contains('peshawar')) {
                result['postalCode'] = '25000';
              }
            }
          }

          // Look for state in the address (common patterns)
          final statePatterns = [
            RegExp(
                r'\b(Sindh|Punjab|Balochistan|Khyber Pakhtunkhwa|KP|Balochistan|Gilgit-Baltistan|GB|Azad Kashmir|AJK)\b',
                caseSensitive: false),
            RegExp(
                r'\b(California|Texas|New York|Florida|Illinois|Pennsylvania|Ohio|Georgia|North Carolina|Michigan)\b',
                caseSensitive: false),
            RegExp(
                r'\b(ON|QC|BC|AB|MB|SK|NS|NB|NL|PE|YT|NT|NU)\b'), // Canadian provinces
          ];

          for (final pattern in statePatterns) {
            final stateMatch = pattern.firstMatch(addressPart);
            if (stateMatch != null) {
              result['state'] = stateMatch.group(0)!;
              break;
            }
          }

          // Extract postal code - try different patterns
          final postalCodePatterns = [
            RegExp(r'\b\d{5}\b'), // 5 digit postal codes
            RegExp(r'\b\d{4}\b'), // 4 digit postal codes
            RegExp(r'\b\d{6}\b'), // 6 digit postal codes
          ];

          for (final pattern in postalCodePatterns) {
            final postalCodeMatch = pattern.firstMatch(addressPart);
            if (postalCodeMatch != null) {
              result['postalCode'] = postalCodeMatch.group(0)!;
              break;
            }
          }
        }
      }
    } else {
      // Format: "City, State, Country PostalCode" or "City, Country"
      final parts = address.split(',').map((e) => e.trim()).toList();

      if (parts.length >= 2) {
        result['city'] = parts[0];

        if (parts.length >= 3) {
          result['state'] = parts[1];
          final lastPart = parts.last;

          // Check if last part contains postal code
          final postalCodeMatch = RegExp(r'\b\d{4,6}\b').firstMatch(lastPart);
          if (postalCodeMatch != null) {
            result['postalCode'] = postalCodeMatch.group(0)!;
            result['country'] =
                lastPart.replaceAll(postalCodeMatch.group(0)!, '').trim();
          } else {
            result['country'] = lastPart;
          }
        } else {
          // Format: "City, Country"
          result['country'] = parts[1];
        }
      }
    }

    debugPrint('Edit Profile - Extracted location data: $result');
    return result;
  }

  String _getLocationDisplayText(User? user) {
    if (user == null) return 'Location not set';

    final parts = <String>[];

    if (user.address?.isNotEmpty == true) {
      parts.add(user.address!);
    }

    if (user.city?.isNotEmpty == true) {
      parts.add(user.city!);
    }

    if (user.state?.isNotEmpty == true) {
      parts.add(user.state!);
    }

    if (user.country?.isNotEmpty == true) {
      parts.add(user.country!);
    }

    if (user.postalCode?.isNotEmpty == true) {
      parts.add(user.postalCode!);
    }

    if (parts.isEmpty) {
      return 'Location not set';
    }

    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<AuthProvider>(context).user;

    // Controllers are initialized in initState; avatar sync handled in didChangeDependencies

    // Debug current dropdown values
    debugPrint('Edit Profile - Build method - Current dropdown values:');
    debugPrint('Edit Profile - _selectedCountry: $_selectedCountry');
    debugPrint('Edit Profile - _selectedState: $_selectedState');
    debugPrint('Edit Profile - _selectedCity: $_selectedCity');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Builder(
        builder: (context) {
          return SizedBox(
            width: MediaQuery.of(context).size.width - 32,
            child: CustomButton(
              text: 'Save Changes',
              onPressed: _save,
              isLoading: _isSaving,
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomCard(
                color: Colors.grey[100],
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerSheet,
                      child: Builder(
                        builder: (context) {
                          return Stack(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: theme.colorScheme.primary,
                                child: _avatarPath != null &&
                                        _avatarPath!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          _getCacheBustedUrl(_avatarPath!),
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                          headers: {
                                            'Cache-Control': 'max-age=0',
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            debugPrint(
                                                'Edit Profile - Image load error: $error');
                                            return Text(
                                              (user?.name.isNotEmpty == true)
                                                  ? user!.name
                                                      .substring(0, 1)
                                                      .toUpperCase()
                                                  : 'U',
                                              style: theme.textTheme.titleLarge
                                                  ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            );
                                          },
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Container(
                                              width: 64,
                                              height: 64,
                                              color: theme.colorScheme.primary,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Text(
                                        (user?.name.isNotEmpty == true)
                                            ? user!.name
                                                .substring(0, 1)
                                                .toUpperCase()
                                            : 'U',
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                              // Removed per request: delete icon moved to bottom sheet
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name.isNotEmpty == true
                                ? user!.name
                                : 'Your name',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getLocationDisplayText(user),
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomCard(
                color: Colors.grey[100],
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: user?.email ?? '',
                      enabled: false,
                      decoration: const InputDecoration(
                          labelText: 'Email (not editable)'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration:
                          const InputDecoration(labelText: 'Phone Number'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    // Country Dropdown
                    Text(
                      'Country',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: false,
                          onSelect: (c) => setState(() {
                            _selectedCountry = c.name;
                            _selectedState =
                                null; // Reset state when country changes
                            _selectedCity =
                                null; // Reset city when country changes
                          }),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.public,
                              color: theme.colorScheme.onSurface,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedCountry ?? 'Select Country',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: _selectedCountry == null
                                      ? theme.colorScheme.onSurfaceVariant
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // State Dropdown (Dynamic)
                    DynamicStatePicker(
                      selectedCountry: _selectedCountry,
                      selectedState: _selectedState,
                      onStateSelected: (state) => setState(() {
                        _selectedState = state;
                        _selectedCity = null; // Reset city when state changes
                      }),
                    ),
                    const SizedBox(height: 12),
                    // City Dropdown (Dynamic)
                    Builder(
                      builder: (context) {
                        print(
                            'EditProfile: Passing to DynamicCityPicker - selectedCountry: $_selectedCountry, selectedState: $_selectedState');
                        return DynamicCityPicker(
                          selectedCountry: _selectedCountry,
                          selectedState: _selectedState,
                          selectedCity: _selectedCity,
                          onCitySelected: (city, state, countryCode) =>
                              setState(() {
                            _selectedCity = city;
                            // Update state if it wasn't set
                            if (_selectedState == null && state != null) {
                              _selectedState = state;
                            }
                          }),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _postalCodeController,
                      decoration:
                          const InputDecoration(labelText: 'Postal Code'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomCard(
                color: Colors.grey[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Change Password', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration:
                          const InputDecoration(labelText: 'New Password'),
                      obscureText: true,
                      validator: (value) {
                        if (_passwordController.text.isNotEmpty) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration:
                          const InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: (value) {
                        if (_passwordController.text.isNotEmpty) {
                          if (value == null ||
                              value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
