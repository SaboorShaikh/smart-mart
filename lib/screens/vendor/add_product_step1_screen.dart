import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../widgets/custom_input.dart';

class AddProductStep1Screen extends StatefulWidget {
  final List<File> selectedImages;
  final List<String> existingImageUrls;
  final String productName;
  final String description;
  final bool isEditMode;
  final Function(List<File>, String, String) onDataChanged;
  final Function(List<String>)? onExistingImagesChanged;

  const AddProductStep1Screen({
    super.key,
    required this.selectedImages,
    this.existingImageUrls = const [],
    required this.productName,
    required this.description,
    this.isEditMode = false,
    required this.onDataChanged,
    this.onExistingImagesChanged,
  });

  @override
  State<AddProductStep1Screen> createState() => _AddProductStep1ScreenState();
}

class _AddProductStep1ScreenState extends State<AddProductStep1Screen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late List<String> _existingUrls;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.productName;
    _descriptionController.text = widget.description;
    _existingUrls = List<String>.from(widget.existingImageUrls);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside text fields
        FocusScope.of(context).unfocus();
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.image,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Step 1: Basic Information',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Add product images, name and description',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Product Images Section
              _buildImageSection(theme),
              const SizedBox(height: 24),

              // Product Name
              CustomInput(
                value: _nameController.text,
                label: 'Product Name *',
                hint: 'e.g., Naturel Red Apple',
                onChanged: (value) {
                  _nameController.text = value;
                  _notifyDataChanged();
                },
              ),
              const SizedBox(height: 16),

              // Product Description
              CustomInput(
                value: _descriptionController.text,
                label: 'Short Description *',
                hint: 'Brief description of the product',
                maxLines: 3,
                onChanged: (value) {
                  _descriptionController.text = value;
                  _notifyDataChanged();
                },
              ),
              const SizedBox(height: 24),

              // Help text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.info,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'The first image will be used as the main display image. You can add up to 5 images.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    final totalImages = _existingUrls.length + widget.selectedImages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Images *',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add up to 5 images. First image will be the main display image.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (widget.isEditMode && _existingUrls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Existing images: ${_existingUrls.length}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: totalImages + 1,
            itemBuilder: (context, index) {
              // Existing images from URLs come first
              if (index < _existingUrls.length) {
                return _buildExistingImagePreview(
                    _existingUrls[index], index, theme);
              }

              // Then new File images
              final fileIndex = index - _existingUrls.length;
              if (fileIndex < widget.selectedImages.length) {
                return _buildImagePreview(
                    widget.selectedImages[fileIndex], fileIndex, theme);
              }

              // Add button at the end
              return _buildAddImageButton(theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExistingImagePreview(
      String imageUrl, int index, ThemeData theme) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeExistingImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.x,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          // Badge to indicate it's an existing image
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Saved',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton(ThemeData theme) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _showImagePicker,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.camera,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              'Add Image',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(File image, int index, ThemeData theme) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.x,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          if (index == 0)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Main',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Take Photo'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    debugPrint('Step1 - _pickImage called with source: $source');
    debugPrint('Step1 - Current images count: ${widget.selectedImages.length}');

    if (widget.selectedImages.length >= 5) {
      debugPrint('Step1 - Maximum images reached');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    debugPrint('Step1 - Picked file: ${pickedFile?.path}');

    if (pickedFile != null) {
      final newImages = List<File>.from(widget.selectedImages);
      newImages.add(File(pickedFile.path));
      debugPrint('Step1 - New images count: ${newImages.length}');
      _notifyDataChanged(newImages);
    } else {
      debugPrint('Step1 - No file picked');
    }
  }

  void _removeImage(int index) {
    final newImages = List<File>.from(widget.selectedImages);
    newImages.removeAt(index);
    _notifyDataChanged(newImages);
  }

  void _removeExistingImage(int index) {
    debugPrint('Step1 - Removing existing image at index: $index');
    setState(() {
      _existingUrls.removeAt(index);
    });
    // Notify parent about the change
    widget.onExistingImagesChanged?.call(_existingUrls);
  }

  void _notifyDataChanged([List<File>? images]) {
    // Always use the current widget.selectedImages if no specific images provided
    // This ensures we don't lose images when just typing text
    final imagesToSend = images ?? List<File>.from(widget.selectedImages);
    debugPrint(
        'Step1 - _notifyDataChanged called with ${imagesToSend.length} images');
    debugPrint(
        'Step1 - Current widget.selectedImages length: ${widget.selectedImages.length}');
    widget.onDataChanged(
      imagesToSend,
      _nameController.text,
      _descriptionController.text,
    );
  }
}
