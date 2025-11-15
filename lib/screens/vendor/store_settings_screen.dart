import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:country_picker/country_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/user.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/city_picker.dart';
import '../../services/image_upload_service.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isLoadingData = true;
  bool _isHandlingError = false;

  // Store information
  String _shopName = '';
  String _shopPhone = '';
  String _shopDescription = '';
  String? _shopLogo;

  // Owner information
  String _ownerName = '';
  String _ownerPhone = '';
  String _ownerEmail = '';

  // Location information
  String _address = '';
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;
  String _postalCode = '';

  // Business information
  String _taxId = '';
  String _bankAccount = '';

  // Delivery options
  bool _deliveryEnabled = true;
  bool _pickupEnabled = true;

  // Delivery range
  String? _deliveryMode;
  String? _deliveryCountry;
  String? _deliveryCity;
  double? _deliveryRadiusKm;

  // Location data
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Always reload data when screen becomes visible to ensure logo is loaded
    if (_isInitialized) {
      debugPrint(
          'StoreSettings - Screen became visible again, reloading data...');
      _loadData();
    } else {
      debugPrint('StoreSettings - First time loading, initializing...');
    }
    _isInitialized = true;
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Reload user from Firestore to get latest data
    debugPrint('StoreSettings - Reloading user from Firestore...');
    await authProvider.loadCurrentUser();

    final vendor = authProvider.user;

    if (vendor is Vendor) {
      setState(() {
        // Store information
        _shopName = vendor.shopName;
        _shopPhone = vendor.shopPhone;
        _shopLogo = vendor.shopLogo;
        _isHandlingError = false; // Reset error handling flag

        debugPrint(
            'StoreSettings - Loaded shop logo from database: $_shopLogo');
        debugPrint('StoreSettings - Logo is null: ${_shopLogo == null}');
        debugPrint(
            'StoreSettings - Logo is empty: ${_shopLogo?.isEmpty ?? true}');

        // Clean up any orphaned logos (optional - runs in background)
        _cleanupOrphanedLogos(vendor.id);

        // Check if logo URL is valid
        if (_shopLogo != null && _shopLogo!.isNotEmpty) {
          debugPrint('StoreSettings - Logo URL is valid, checking format...');
          if (!_shopLogo!.startsWith('http')) {
            debugPrint(
                'StoreSettings - Invalid logo URL format, clearing: $_shopLogo');
            _shopLogo = null;
          } else {
            debugPrint(
                'StoreSettings - Logo URL format is valid, keeping: $_shopLogo');
          }
        } else {
          debugPrint('StoreSettings - No logo found in database');
        }

        // Owner information
        _ownerName = vendor.name;
        _ownerPhone = vendor.phone ?? '';
        _ownerEmail = vendor.email;

        // Location information
        _address = vendor.address ?? '';
        _selectedCountry = vendor.country;
        _selectedState = vendor.state;
        _selectedCity = vendor.city;
        _postalCode = vendor.postalCode ?? '';

        debugPrint('StoreSettings - Loaded store location:');
        debugPrint('  Address: $_address');
        debugPrint('  City: $_selectedCity');
        debugPrint('  State: $_selectedState');
        debugPrint('  Country: $_selectedCountry');
        debugPrint('  Postal Code: $_postalCode');

        // Business information
        _taxId = vendor.taxId ?? '';
        _bankAccount = vendor.bankAccount ?? '';

        // Delivery options
        _deliveryEnabled = vendor.deliveryEnabled;
        _pickupEnabled = vendor.pickupEnabled;

        // Delivery range
        _deliveryMode = vendor.deliveryMode;
        _deliveryCountry = vendor.deliveryCountry;
        _deliveryCity = vendor.deliveryCity;
        _deliveryRadiusKm = vendor.deliveryRadiusKm;

        debugPrint('StoreSettings - Loaded delivery range:');
        debugPrint('  Mode: $_deliveryMode');
        debugPrint('  Country: $_deliveryCountry');
        debugPrint('  City: $_deliveryCity');
        debugPrint('  Radius: $_deliveryRadiusKm km');

        // Location data
        _latitude = vendor.location?.latitude;
        _longitude = vendor.location?.longitude;

        _isLoadingData = false;
      });

      // Force refresh logo after loading data
      _refreshLogoFromDatabase();
    } else {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _clearInvalidLogoFromDatabase() async {
    try {
      debugPrint('StoreSettings - Clearing invalid logo from database');

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final updates = {
        'shopLogo': null,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final result = await authProvider.updateProfile(updates);

      if (result.success) {
        debugPrint('StoreSettings - Invalid logo cleared from database');
        await authProvider.loadCurrentUser();
      } else {
        debugPrint(
            'StoreSettings - Failed to clear invalid logo: ${result.error}');
      }
    } catch (e) {
      debugPrint('StoreSettings - Error clearing invalid logo: $e');
    }
  }

  void _showLogoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Store Logo Options',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(LucideIcons.image,
                    color: Theme.of(context).colorScheme.primary),
                title: const Text('Change Logo'),
                subtitle: const Text('Upload a new store logo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickStoreLogo();
                },
              ),
              ListTile(
                leading: Icon(LucideIcons.trash2,
                    color: Theme.of(context).colorScheme.error),
                title: const Text('Delete Logo'),
                subtitle: const Text('Remove current logo'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Store Logo'),
          content: const Text(
              'Are you sure you want to delete the current store logo? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteStoreLogo();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStoreLogo() async {
    try {
      debugPrint('StoreSettings - Deleting store logo...');
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final vendor = authProvider.user;

      if (vendor is Vendor) {
        // Delete from Supabase Storage
        if (_shopLogo != null && _shopLogo!.isNotEmpty) {
          debugPrint('StoreSettings - Deleting logo from Supabase: $_shopLogo');
          await _deleteLogoFromStorage(_shopLogo!);
        }

        // Clear from database
        await _clearLogoFromDatabase();

        // Update UI
        setState(() {
          _shopLogo = null;
          _isLoading = false;
        });

        _showSuccess('Store logo deleted successfully');
        debugPrint('StoreSettings - Logo deleted successfully');
      } else {
        setState(() => _isLoading = false);
        _showError('User is not a vendor');
      }
    } catch (e) {
      debugPrint('StoreSettings - Error deleting logo: $e');
      setState(() => _isLoading = false);
      _showError('Error deleting logo: $e');
    }
  }

  Future<void> _deleteLogoFromStorage(String logoUrl) async {
    try {
      debugPrint('StoreSettings - Deleting logo from storage: $logoUrl');

      // Extract the file path from the signed URL
      final uri = Uri.parse(logoUrl);
      final pathSegments = uri.pathSegments;

      // Find the store ID and file name from the path
      // Expected format: /storage/v1/object/sign/store-logos/storeId/filename
      final storeLogosIndex = pathSegments.indexOf('store-logos');
      if (storeLogosIndex != -1 && storeLogosIndex + 2 < pathSegments.length) {
        final storeId = pathSegments[storeLogosIndex + 1];
        final fileName = pathSegments[storeLogosIndex + 2];
        final filePath = '$storeId/$fileName';

        debugPrint('StoreSettings - Deleting file path: $filePath');

        final supabase = Supabase.instance.client;
        await supabase.storage.from('store-logos').remove([filePath]);

        debugPrint('StoreSettings - Logo deleted from storage successfully');
      } else {
        debugPrint('StoreSettings - Could not parse logo URL for deletion');
      }
    } catch (e) {
      debugPrint('StoreSettings - Error deleting from storage: $e');
      // Don't throw error, just log it - the database update is more important
    }
  }

  Future<void> _clearLogoFromDatabase() async {
    try {
      debugPrint('StoreSettings - Clearing logo from database');

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final vendor = authProvider.user;

      if (vendor is Vendor) {
        final updates = {
          'shopLogo': null,
          'updatedAt': DateTime.now().toIso8601String(),
        };

        await FirestoreService.updateUser(vendor.id, updates);
        debugPrint('StoreSettings - Logo cleared from database');

        // Reload user data to reflect changes
        await authProvider.loadCurrentUser();
      }
    } catch (e) {
      debugPrint('StoreSettings - Error clearing logo from database: $e');
      rethrow;
    }
  }

  Future<void> _cleanupOrphanedLogos(String storeId) async {
    try {
      debugPrint(
          'StoreSettings - Cleaning up orphaned logos for store: $storeId');

      final supabase = Supabase.instance.client;
      final files = await supabase.storage.from('store-logos').list();

      // Find files that belong to this store but are not the current logo
      final currentLogoPath =
          _shopLogo != null ? _extractFilePathFromUrl(_shopLogo!) : null;

      for (final file in files) {
        final filePath = file.name;
        if (filePath.startsWith('$storeId/') && filePath != currentLogoPath) {
          debugPrint('StoreSettings - Deleting orphaned logo: $filePath');
          try {
            await supabase.storage.from('store-logos').remove([filePath]);
            debugPrint('StoreSettings - Orphaned logo deleted: $filePath');
          } catch (e) {
            debugPrint(
                'StoreSettings - Error deleting orphaned logo $filePath: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('StoreSettings - Error during orphaned logo cleanup: $e');
      // Don't throw error - this is cleanup, not critical
    }
  }

  String? _extractFilePathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final storeLogosIndex = pathSegments.indexOf('store-logos');
      if (storeLogosIndex != -1 && storeLogosIndex + 2 < pathSegments.length) {
        final storeId = pathSegments[storeLogosIndex + 1];
        final fileName = pathSegments[storeLogosIndex + 2];
        return '$storeId/$fileName';
      }
    } catch (e) {
      debugPrint('StoreSettings - Error extracting file path from URL: $e');
    }
    return null;
  }

  Future<void> _refreshLogoFromDatabase() async {
    try {
      debugPrint('StoreSettings - Refreshing logo from database');
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.loadCurrentUser();

      final vendor = authProvider.user;
      if (vendor is Vendor && mounted) {
        debugPrint('StoreSettings - Vendor found, checking logo...');
        debugPrint(
            'StoreSettings - Current logo in database: ${vendor.shopLogo}');

        setState(() {
          _shopLogo = vendor.shopLogo;
        });
        debugPrint('StoreSettings - Logo refreshed from database: $_shopLogo');
        debugPrint('StoreSettings - Logo is null: ${_shopLogo == null}');
        debugPrint(
            'StoreSettings - Logo is empty: ${_shopLogo?.isEmpty ?? true}');
      } else {
        debugPrint(
            'StoreSettings - User is not a vendor or widget not mounted');
      }
    } catch (e) {
      debugPrint('StoreSettings - Error refreshing logo from database: $e');
    }
  }

  Future<void> _saveSettings() async {
    // Validate required fields
    if (_shopName.trim().isEmpty) {
      _showError('Store name is required');
      return;
    }
    if (_shopPhone.trim().isEmpty) {
      _showError('Store phone is required');
      return;
    }
    if (_ownerName.trim().isEmpty) {
      _showError('Owner name is required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Build full shop address from detailed fields
      final fullShopAddress = [
        if (_address.trim().isNotEmpty) _address.trim(),
        if (_selectedCity != null && _selectedCity!.isNotEmpty) _selectedCity!,
        if (_selectedState != null && _selectedState!.isNotEmpty)
          _selectedState!,
        if (_selectedCountry != null && _selectedCountry!.isNotEmpty)
          _selectedCountry!,
        if (_postalCode.trim().isNotEmpty) _postalCode.trim(),
      ].join(', ');

      final updates = {
        // Store information
        'shopName': _shopName.trim(),
        'shopAddress':
            fullShopAddress.isNotEmpty ? fullShopAddress : 'Not specified',
        'shopPhone': _shopPhone.trim(),
        if (_shopLogo != null) 'shopLogo': _shopLogo,

        // Owner information
        'name': _ownerName.trim(),
        'phone': _ownerPhone.trim(),

        // Location information
        'address': _address.trim(),
        'city': _selectedCity ?? '',
        'state': _selectedState ?? '',
        'country': _selectedCountry ?? '',
        'postalCode': _postalCode.trim(),

        // Business information
        'taxId': _taxId.trim(),
        'bankAccount': _bankAccount.trim(),

        // Delivery options
        'deliveryEnabled': _deliveryEnabled,
        'pickupEnabled': _pickupEnabled,

        // Delivery range (set to disabled if delivery is turned off)
        'deliveryMode': _deliveryEnabled ? _deliveryMode : 'disabled',
        'deliveryCountry': _deliveryEnabled ? _deliveryCountry : null,
        'deliveryCity': _deliveryEnabled ? _deliveryCity : null,
        'deliveryRadiusKm': _deliveryEnabled ? _deliveryRadiusKm : null,

        // Location data - update if coordinates exist, otherwise keep address fields
        if (_latitude != null && _longitude != null)
          'location': {
            'latitude': _latitude,
            'longitude': _longitude,
            'address': _address.trim(),
            'city': _selectedCity ?? '',
            'state': _selectedState ?? '',
            'country': _selectedCountry ?? '',
            'postalCode': _postalCode.trim(),
          },

        'updatedAt': DateTime.now().toIso8601String(),
      };

      debugPrint('StoreSettings - Saving location to Firestore:');
      debugPrint('  Address: ${_address.trim()}');
      debugPrint('  City: ${_selectedCity ?? ""}');
      debugPrint('  State: ${_selectedState ?? ""}');
      debugPrint('  Country: ${_selectedCountry ?? ""}');
      debugPrint('  Postal Code: ${_postalCode.trim()}');

      debugPrint('StoreSettings - Saving to Firestore:');
      debugPrint('  Mode: $_deliveryMode');
      debugPrint('  Radius: $_deliveryRadiusKm km');

      final result = await authProvider.updateProfile(updates);

      if (result.success) {
        debugPrint(
            'StoreSettings - Save successful, reloading from Firestore...');
        // Reload user data from Firestore to ensure we have the latest
        await authProvider.loadCurrentUser();

        // Verify the data was saved correctly
        final reloadedVendor = authProvider.user;
        if (reloadedVendor is Vendor) {
          debugPrint('StoreSettings - Verification after save:');
          debugPrint('  deliveryMode: ${reloadedVendor.deliveryMode}');
          debugPrint('  deliveryRadiusKm: ${reloadedVendor.deliveryRadiusKm}');
          debugPrint('  deliveryCountry: ${reloadedVendor.deliveryCountry}');
          debugPrint('  deliveryCity: ${reloadedVendor.deliveryCity}');
        }

        _showSuccess('Store settings updated successfully!');
        setState(() {
          // Settings saved successfully
        });
        Get.back();
      } else {
        _showError(result.error ?? 'Failed to update store settings');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getStoreLocationText() {
    final locationParts = <String>[];

    if (_selectedCity != null && _selectedCity!.isNotEmpty) {
      locationParts.add(_selectedCity!);
    }

    if (_selectedState != null && _selectedState!.isNotEmpty) {
      locationParts.add(_selectedState!);
    }

    if (_selectedCountry != null && _selectedCountry!.isNotEmpty) {
      locationParts.add(_selectedCountry!);
    }

    if (locationParts.isEmpty) {
      return 'Location not set';
    }

    return locationParts.join(', ');
  }

  Future<void> _pickStoreLogo() async {
    try {
      // Check if we're already loading
      if (_isLoading) {
        return;
      }

      final ImagePicker picker = ImagePicker();

      // Try gallery first, then camera as fallback
      XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      // If gallery fails, try camera
      image ??= await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

      if (image != null) {
        debugPrint('StoreSettings - Image selected: ${image.path}');
        setState(() => _isLoading = true);

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final vendor = authProvider.user;

        if (vendor is Vendor) {
          debugPrint('StoreSettings - Vendor ID: ${vendor.id}');
          final imageFile = File(image.path);
          debugPrint('StoreSettings - Image file created: ${imageFile.path}');
          debugPrint(
              'StoreSettings - File exists: ${await imageFile.exists()}');

          // Delete previous logo if it exists
          if (_shopLogo != null && _shopLogo!.isNotEmpty) {
            debugPrint('StoreSettings - Deleting previous logo: $_shopLogo');
            try {
              await _deleteLogoFromStorage(_shopLogo!);
              debugPrint('StoreSettings - Previous logo deleted successfully');
            } catch (e) {
              debugPrint('StoreSettings - Error deleting previous logo: $e');
              // Continue with upload even if deletion fails
            }
          }

          debugPrint('StoreSettings - Starting upload...');
          debugPrint(
              'StoreSettings - Calling ImageUploadService.uploadStoreLogo');
          debugPrint('StoreSettings - Image file: ${imageFile.path}');
          debugPrint('StoreSettings - Store ID: ${vendor.id}');

          final imageUrl = await ImageUploadService.uploadStoreLogo(
            imageFile: imageFile,
            storeId: vendor.id,
          );

          debugPrint('StoreSettings - Upload completed');
          debugPrint('StoreSettings - Upload result: $imageUrl');
          debugPrint(
              'StoreSettings - Upload result is null: ${imageUrl == null}');

          if (imageUrl != null) {
            debugPrint(
                'StoreSettings - Image upload successful, updating UI state');
            debugPrint('StoreSettings - New logo URL: $imageUrl');

            if (mounted) {
              // Update state immediately
              setState(() {
                _shopLogo = imageUrl;
                _isHandlingError = false; // Reset error handling flag
              });

              debugPrint(
                  'StoreSettings - State updated, _shopLogo is now: $_shopLogo');

              // Force another rebuild to ensure UI updates
              setState(() {
                // Trigger rebuild
              });

              // Show success message immediately
              _showSuccess('Store logo updated successfully!');

              // Save to database in background
              _saveLogoToDatabase(imageUrl);
            } else {
              debugPrint(
                  'StoreSettings - Widget not mounted, cannot update state');
            }
          } else {
            if (mounted) {
              _showError(
                  'Failed to upload store logo. Please check your Supabase RLS policies for the "store-logos" bucket.');
            }
          }
        } else {
          if (mounted) {
            _showError('User is not a vendor');
          }
        }
      }
    } catch (e) {
      debugPrint('StoreSettings - Upload error: $e');
      debugPrint('StoreSettings - Error type: ${e.runtimeType}');
      if (mounted) {
        _showError('Error uploading image: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveLogoToDatabase(String logoUrl) async {
    try {
      debugPrint('StoreSettings - Saving logo to database: $logoUrl');

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final updates = {
        'shopLogo': logoUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final result = await authProvider.updateProfile(updates);

      if (result.success) {
        debugPrint('StoreSettings - Logo saved to database successfully');
        // Reload user data to ensure we have the latest
        await authProvider.loadCurrentUser();
        debugPrint('StoreSettings - User data reloaded from database');

        // Force UI rebuild after database save
        if (mounted) {
          setState(() {
            // Trigger rebuild to show updated logo
          });
          debugPrint('StoreSettings - UI rebuilt after database save');
        }
      } else {
        debugPrint(
            'StoreSettings - Failed to save logo to database: ${result.error}');
        _showError('Logo uploaded but failed to save to database');
      }
    } catch (e) {
      debugPrint('StoreSettings - Error saving logo to database: $e');
      _showError('Logo uploaded but failed to save to database: $e');
    }
  }

  Widget _buildDeliveryRangeInfo(ThemeData theme) {
    String rangeText = 'Not set';
    IconData rangeIcon = LucideIcons.mapPin;

    if (!_deliveryEnabled) {
      rangeText = 'Delivery is disabled';
      rangeIcon = LucideIcons.ban;
    } else if (_deliveryMode != null && _deliveryMode != 'disabled') {
      switch (_deliveryMode) {
        case 'country':
          rangeText =
              'Whole country${_deliveryCountry != null ? ": $_deliveryCountry" : ""}';
          rangeIcon = LucideIcons.globe;
          break;
        case 'city':
          rangeText =
              'Whole city${_deliveryCity != null ? ": $_deliveryCity" : ""}';
          rangeIcon = LucideIcons.building;
          break;
        case 'manual':
          rangeText = _deliveryRadiusKm != null
              ? 'Custom radius: ${_deliveryRadiusKm!.toStringAsFixed(1)} km'
              : 'Custom radius';
          rangeIcon = LucideIcons.circle;
          break;
      }
    }

    return Row(
      children: [
        Icon(
          rangeIcon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Delivery Range',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rangeText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _editDeliveryRange() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendor = authProvider.user;

    if (vendor is! Vendor) {
      _showError('User is not a vendor');
      return;
    }

    // Navigate to the delivery range screen with current data
    final result = await Get.toNamed(
      '/auth/register/vendor/delivery',
      arguments: {
        'lat': _latitude ?? 0.0,
        'lng': _longitude ?? 0.0,
        'country': _selectedCountry ?? vendor.country ?? 'Country',
        'city': _selectedCity ?? vendor.city ?? 'City',
        'state': _selectedState ?? vendor.state ?? '',
        'postalCode':
            _postalCode.isNotEmpty ? _postalCode : vendor.postalCode ?? '',
        'shopName': _shopName.isNotEmpty ? _shopName : vendor.shopName,
        'isEditMode': true, // Flag to indicate we're editing, not registering
        'currentMode': _deliveryMode,
        'currentRadius': _deliveryRadiusKm,
      },
    );

    // If result is returned, update the delivery range
    if (result != null && result is Map<String, dynamic>) {
      debugPrint('StoreSettings - Received delivery range from editor:');
      debugPrint('  Mode: ${result['deliveryMode']}');
      debugPrint('  Country: ${result['deliveryCountry']}');
      debugPrint('  City: ${result['deliveryCity']}');
      debugPrint('  Radius: ${result['deliveryRadiusKm']} km');

      setState(() {
        _deliveryMode = result['deliveryMode'];
        _deliveryCountry = result['deliveryCountry'];
        _deliveryCity = result['deliveryCity'];
        _deliveryRadiusKm = result['deliveryRadiusKm'];
        // Delivery settings updated
      });

      debugPrint('StoreSettings - Updated state with new delivery range');
      debugPrint('  New Radius: $_deliveryRadiusKm km');
      _showSuccess('Delivery range updated. Remember to save settings!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Store Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Information Section
                      _buildSectionHeader(
                          theme, 'Store Information', LucideIcons.store),
                      const SizedBox(height: 12),
                      CustomCard(
                        color: Colors.grey[100],
                        child: Column(
                          children: [
                            // Store Logo Section
                            _buildStoreLogoSection(theme),
                            const SizedBox(height: 16),
                            CustomInput(
                              label: 'Store Name *',
                              value: _shopName,
                              hint: 'Enter your store name',
                              prefixIcon: const Icon(LucideIcons.store),
                              onChanged: (value) =>
                                  setState(() => _shopName = value),
                            ),
                            const SizedBox(height: 16),
                            CustomInput(
                              label: 'Store Phone *',
                              value: _shopPhone,
                              hint: 'Enter store phone number',
                              prefixIcon: const Icon(LucideIcons.phone),
                              keyboardType: TextInputType.phone,
                              onChanged: (value) =>
                                  setState(() => _shopPhone = value),
                            ),
                            const SizedBox(height: 16),
                            CustomInput(
                              label: 'Store Description (Optional)',
                              value: _shopDescription,
                              hint: 'Describe your store',
                              prefixIcon: const Icon(LucideIcons.fileText),
                              maxLines: 3,
                              onChanged: (value) =>
                                  setState(() => _shopDescription = value),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Owner Information Section
                      _buildSectionHeader(
                          theme, 'Owner Information', LucideIcons.user),
                      const SizedBox(height: 12),
                      CustomCard(
                        color: Colors.grey[100],
                        child: Column(
                          children: [
                            CustomInput(
                              label: 'Owner Name *',
                              value: _ownerName,
                              hint: 'Enter owner name',
                              prefixIcon: const Icon(LucideIcons.user),
                              onChanged: (value) =>
                                  setState(() => _ownerName = value),
                            ),
                            const SizedBox(height: 16),
                            CustomInput(
                              label: 'Owner Phone',
                              value: _ownerPhone,
                              hint: 'Enter owner phone',
                              prefixIcon: const Icon(LucideIcons.phone),
                              keyboardType: TextInputType.phone,
                              onChanged: (value) =>
                                  setState(() => _ownerPhone = value),
                            ),
                            const SizedBox(height: 16),
                            CustomInput(
                              label: 'Owner Email',
                              value: _ownerEmail,
                              hint: 'Email address',
                              prefixIcon: const Icon(LucideIcons.mail),
                              enabled: false,
                              onChanged: (value) {},
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Store Location Section
                      _buildSectionHeader(
                          theme, 'Store Location', LucideIcons.mapPin),
                      const SizedBox(height: 12),
                      CustomCard(
                        color: Colors.grey[100],
                        child: Column(
                          children: [
                            CustomInput(
                              label: 'Address',
                              value: _address,
                              hint: 'Enter store address',
                              prefixIcon: const Icon(LucideIcons.mapPin),
                              maxLines: 2,
                              onChanged: (value) =>
                                  setState(() => _address = value),
                            ),
                            const SizedBox(height: 16),

                            // Country Picker
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
                                    _selectedState = null;
                                    _selectedCity = null;
                                  }),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: theme.colorScheme.outline),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      LucideIcons.globe,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedCountry ?? 'Select country',
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          color: _selectedCountry == null
                                              ? theme
                                                  .colorScheme.onSurfaceVariant
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
                            const SizedBox(height: 16),

                            // State Picker
                            Text(
                              'State',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectedCountry != null
                                  ? _showStatePicker
                                  : null,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: theme.colorScheme.outline),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      LucideIcons.map,
                                      color: _selectedCountry != null
                                          ? theme.colorScheme.onSurface
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedState ??
                                            (_selectedCountry == null
                                                ? 'Select country first'
                                                : 'Select state'),
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          color: _selectedState == null
                                              ? theme
                                                  .colorScheme.onSurfaceVariant
                                              : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    if (_selectedCountry != null)
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // City Picker
                            CityPicker(
                              selectedCountry: _selectedCountry,
                              selectedState: _selectedState,
                              selectedCity: _selectedCity,
                              onCitySelected: (city) => setState(() {
                                _selectedCity = city;
                              }),
                            ),
                            const SizedBox(height: 16),

                            CustomInput(
                              label: 'Postal Code',
                              value: _postalCode,
                              hint: 'Enter postal code',
                              prefixIcon: const Icon(LucideIcons.hash),
                              onChanged: (value) =>
                                  setState(() => _postalCode = value),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Delivery Options Section
                      _buildSectionHeader(
                          theme, 'Delivery Options', LucideIcons.truck),
                      const SizedBox(height: 12),
                      CustomCard(
                        color: Colors.grey[100],
                        child: Column(
                          children: [
                            SwitchListTile(
                              value: _deliveryEnabled,
                              onChanged: (value) {
                                setState(() => _deliveryEnabled = value);
                              },
                              title: Text(
                                'Delivery Enabled',
                                style: theme.textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                'Allow customers to order for delivery',
                                style: theme.textTheme.bodySmall,
                              ),
                              secondary: Icon(
                                LucideIcons.truck,
                                color: theme.colorScheme.primary,
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            const Divider(),
                            SwitchListTile(
                              value: _pickupEnabled,
                              onChanged: (value) {
                                setState(() => _pickupEnabled = value);
                              },
                              title: Text(
                                'Pickup Enabled',
                                style: theme.textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                'Allow customers to pick up orders',
                                style: theme.textTheme.bodySmall,
                              ),
                              secondary: Icon(
                                LucideIcons.shoppingBag,
                                color: theme.colorScheme.primary,
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Delivery Range Section
                      _buildSectionHeader(theme, 'Delivery Range & Location',
                          LucideIcons.mapPin),
                      const SizedBox(height: 12),
                      CustomCard(
                        color: Colors.grey[100],
                        child: Opacity(
                          opacity: _deliveryEnabled ? 1.0 : 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _deliveryEnabled
                                    ? 'Set your store location and delivery coverage area on the map'
                                    : 'Enable delivery to set your delivery coverage area',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildDeliveryRangeInfo(theme),
                              const SizedBox(height: 12),
                              CustomButton(
                                onPressed: _deliveryEnabled
                                    ? _editDeliveryRange
                                    : null,
                                text: 'Edit on Map',
                                isOutlined: true,
                                width: double.infinity,
                                icon: const Icon(LucideIcons.map, size: 18),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Business Information Section
                      _buildSectionHeader(
                          theme, 'Business Information', LucideIcons.briefcase),
                      const SizedBox(height: 12),
                      CustomCard(
                        color: Colors.grey[100],
                        child: Column(
                          children: [
                            CustomInput(
                              label: 'Tax ID (Optional)',
                              value: _taxId,
                              hint: 'Enter tax ID',
                              prefixIcon: const Icon(LucideIcons.fileText),
                              onChanged: (value) =>
                                  setState(() => _taxId = value),
                            ),
                            const SizedBox(height: 16),
                            CustomInput(
                              label: 'Bank Account (Optional)',
                              value: _bankAccount,
                              hint: 'Enter bank account',
                              prefixIcon: const Icon(LucideIcons.creditCard),
                              onChanged: (value) =>
                                  setState(() => _bankAccount = value),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Floating Save Button
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SafeArea(
                    top: false,
                    child: Opacity(
                      opacity: 0.95,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CustomButton(
                          onPressed: _isLoading ? null : _saveSettings,
                          text: _isLoading ? 'Saving...' : 'Save Settings',
                          width: double.infinity,
                          height: 56,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(LucideIcons.save,
                                  color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showStatePicker() {
    if (_selectedCountry == null) return;

    final states = _getStatesForCountry(_selectedCountry!);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select State in $_selectedCountry'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: states.length,
            itemBuilder: (context, index) {
              final state = states[index];
              return ListTile(
                title: Text(state),
                onTap: () {
                  setState(() {
                    _selectedState = state;
                    _selectedCity = null; // Reset city when state changes
                  });
                  Get.back();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  List<String> _getStatesForCountry(String country) {
    switch (country.toLowerCase()) {
      case 'pakistan':
        return [
          'Punjab',
          'Sindh',
          'Khyber Pakhtunkhwa (KPK)',
          'Balochistan',
          'Gilgit-Baltistan',
          'Azad Jammu and Kashmir',
          'Islamabad Capital Territory',
        ];
      case 'india':
        return [
          'Andhra Pradesh',
          'Arunachal Pradesh',
          'Assam',
          'Bihar',
          'Chhattisgarh',
          'Goa',
          'Gujarat',
          'Haryana',
          'Himachal Pradesh',
          'Jharkhand',
          'Karnataka',
          'Kerala',
          'Madhya Pradesh',
          'Maharashtra',
          'Manipur',
          'Meghalaya',
          'Mizoram',
          'Nagaland',
          'Odisha',
          'Punjab',
          'Rajasthan',
          'Sikkim',
          'Tamil Nadu',
          'Telangana',
          'Tripura',
          'Uttar Pradesh',
          'Uttarakhand',
          'West Bengal'
        ];
      case 'united states':
      case 'united states of america':
        return [
          'Alabama',
          'Alaska',
          'Arizona',
          'Arkansas',
          'California',
          'Colorado',
          'Connecticut',
          'Delaware',
          'Florida',
          'Georgia',
        ];
      case 'united kingdom':
        return [
          'England',
          'Scotland',
          'Wales',
          'Northern Ireland',
        ];
      default:
        return ['Other'];
    }
  }

  Widget _buildStoreLogoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Store Logo',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Square logo image
            InkWell(
              onTap: _isLoading ? null : _pickStoreLogo,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isLoading
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_shopLogo ?? 'no-logo'),
                  child: _buildLogoContent(theme),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Store information column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store name
                  Text(
                    _shopName.isNotEmpty ? _shopName : 'Store Name',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Store location
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _getStoreLocationText(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoContent(ThemeData theme) {
    debugPrint('StoreSettings - _buildLogoContent called');
    debugPrint('StoreSettings - _isLoading: $_isLoading');
    debugPrint('StoreSettings - _shopLogo: $_shopLogo');
    debugPrint('StoreSettings - _shopLogo is null: ${_shopLogo == null}');
    debugPrint(
        'StoreSettings - _shopLogo is empty: ${_shopLogo?.isEmpty ?? true}');

    // If we're currently uploading, show loading state
    if (_isLoading) {
      debugPrint('StoreSettings - Showing loading placeholder');
      return _buildLoadingPlaceholder(theme);
    }

    // If we have a logo URL, try to load it from the cloud
    if (_shopLogo != null && _shopLogo!.isNotEmpty) {
      debugPrint('StoreSettings - Showing logo from cloud: $_shopLogo');
      debugPrint(
          'StoreSettings - URL starts with http: ${_shopLogo!.startsWith('http')}');
      debugPrint(
          'StoreSettings - URL contains supabase: ${_shopLogo!.contains('supabase')}');
      debugPrint(
          'StoreSettings - URL contains store-logos: ${_shopLogo!.contains('store-logos')}');

      // Validate URL format
      if (!_shopLogo!.startsWith('http')) {
        debugPrint('StoreSettings - Invalid URL format: $_shopLogo');
        return _buildLogoPlaceholder(theme);
      }
      return GestureDetector(
        onTap: () => _showLogoOptions(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.colorScheme.outline),
            color:
                theme.colorScheme.primary.withOpacity(0.1), // Debug background
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Image.network(
                  _shopLogo!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.high,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      debugPrint('StoreSettings - Image loaded successfully');
                      return child;
                    }
                    return Container(
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Loading logo...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('StoreSettings - Error loading image: $error');
                    debugPrint('StoreSettings - Failed URL: $_shopLogo');

                    // Only handle error once
                    if (!_isHandlingError) {
                      _isHandlingError = true;

                      // Schedule the setState call for after the build
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _shopLogo = null;
                            _isHandlingError = false;
                          });
                          // Also clear from database
                          _clearInvalidLogoFromDatabase();
                        }
                      });
                    }

                    return Container(
                      color: theme.colorScheme.errorContainer,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.alertCircle,
                              color: theme.colorScheme.error,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image failed to load',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to upload new',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Overlay icon to indicate it's clickable
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      LucideIcons.moreHorizontal,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // No logo available, show upload placeholder
    return _buildLogoPlaceholder(theme);
  }

  Widget _buildLoadingPlaceholder(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
            strokeWidth: 2,
          ),
          const SizedBox(height: 8),
          Text(
            'Uploading...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPlaceholder(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.image,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload Store Logo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
