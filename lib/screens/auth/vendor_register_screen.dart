import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../services/image_upload_service.dart';
// Removed: not needed in step 1

class VendorRegisterScreen extends StatefulWidget {
  const VendorRegisterScreen({super.key});

  @override
  State<VendorRegisterScreen> createState() => _VendorRegisterScreenState();
}

class _VendorRegisterScreenState extends State<VendorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _shopName = TextEditingController();
  final TextEditingController _ownerName = TextEditingController();

  bool _submitting = false;
  String? _shopLogo;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final current = auth.user;
    if (current == null) {
      Get.offAllNamed('/auth/login');
      return;
    }

    setState(() => _submitting = true);
    try {
      final payload = {
        'shopName': _shopName.text.trim(),
        'ownerName': _ownerName.text.trim().isEmpty
            ? current.name
            : _ownerName.text.trim(),
        if (_shopLogo != null) 'shopLogo': _shopLogo,
      };
      Get.toNamed('/auth/register/vendor/location', arguments: payload);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register vendor: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickStoreLogo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _submitting = true);

        final auth = Provider.of<AuthProvider>(context, listen: false);
        final current = auth.user;

        if (current != null) {
          print('Starting store logo upload for user: ${current.id}');
          final imageFile = File(image.path);
          final imageUrl = await ImageUploadService.uploadStoreLogo(
            imageFile: imageFile,
            storeId: current.id,
          );

          if (imageUrl != null) {
            print('Store logo uploaded successfully: $imageUrl');
            if (mounted) {
              setState(() {
                _shopLogo = imageUrl;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Store logo uploaded successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            print('Store logo upload failed');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Failed to upload store logo. Please check your Supabase RLS policies for the "store-logos" bucket.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error in _pickStoreLogo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final current = auth.user;

    // If not authenticated, force login first to ensure we skip account creation flow
    if (current == null) {
      Future.microtask(() => Get.offAllNamed('/auth/login'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mart Info'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.10),
                    theme.colorScheme.secondary.withOpacity(0.08),
                  ],
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.store, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hi ${current?.name.split(' ').first ?? ''}, use your existing account. We just need your shop details.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Store Logo Section
                  _buildStoreLogoSection(theme),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _shopName,
                    decoration: const InputDecoration(labelText: 'Shop name'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ownerName,
                    decoration: const InputDecoration(
                        labelText: 'Owner name (optional)'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Next: Set Location'),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreLogoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Store Logo (Optional)',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _submitting ? null : _pickStoreLogo,
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _shopLogo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _shopLogo!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildLogoPlaceholder(theme);
                      },
                    ),
                  )
                : _buildLogoPlaceholder(theme),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to upload your store logo',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
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
            size: 28,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 4),
          Text(
            'Upload Store Logo',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
