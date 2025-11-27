import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

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
    final isDark = theme.brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 8),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Back Button, Indicators, and Spacer
                  Row(
                    children: [
                      // Back Button
                      IconButton(
                        icon: Icon(
                          LucideIcons.arrowLeft,
                          color: isDark ? Colors.white : const Color(0xFF18181B),
                        ),
                        onPressed: () => Get.back(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      // Page Indicators (6 dots)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            final isActive = index <= 0; // Stage 1 is index 0
                            final isCurrent = index == 0;
                            return Container(
                              width: isCurrent ? 12 : 8,
                              height: isCurrent ? 12 : 8,
                              margin: EdgeInsets.only(
                                right: index < 5 ? 8 : 0,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF225FEC)
                                    : (isDark
                                        ? const Color(0xFF3F3F46)
                                        : const Color(0xFFD4D4D8)),
                                shape: BoxShape.circle,
                                boxShadow: isCurrent
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF225FEC)
                                              .withOpacity(0.2),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          }),
                        ),
                      ),
                      // Spacer
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    'Basic Information',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF18181B),
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // Progress Bar Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    'Stage 1 of 6',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFA1A1AA)
                          : const Color(0xFF71717A),
                    ),
                  ),
                ),
                // Progress bar with equal padding on both sides
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF27272A)
                          : const Color(0xFFE4E4E7),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 1 / 6, // 16.7% for stage 1
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF225FEC),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Images Section
                    _buildProductImagesSection(theme, isDark),
                    const SizedBox(height: 24),

                    // Product Details Section
                    _buildProductDetailsSection(theme, isDark),
                    const SizedBox(height: 100), // Space for fixed bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImagesSection(ThemeData theme, bool isDark) {
    final totalImages = _existingUrls.length + widget.selectedImages.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Images',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF18181B),
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add up to 5 images. The first image will be the primary one.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: isDark
                  ? const Color(0xFFA1A1AA)
                  : const Color(0xFF71717A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 128,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: totalImages + 1,
              itemBuilder: (context, index) {
                // Existing images from URLs come first
                if (index < _existingUrls.length) {
                  return _buildExistingImageThumbnail(
                      _existingUrls[index], index, isDark);
                }

                // Then new File images
                final fileIndex = index - _existingUrls.length;
                if (fileIndex < widget.selectedImages.length) {
                  return _buildImageThumbnail(
                      widget.selectedImages[fileIndex], fileIndex, isDark);
                }

                // Add button at the end
                return _buildAddImageButton(isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton(bool isDark) {
    return Container(
      width: 128,
      height: 128,
      margin: const EdgeInsets.only(right: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: totalImages < 5 ? _showImagePicker : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF27272A).withOpacity(0.2),
                        const Color(0xFF27272A).withOpacity(0.1),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFFAFAFA),
                      ],
              ),
            ),
            child: CustomPaint(
              painter: DashedBorderPainter(
                color: isDark
                    ? const Color(0xFF3F3F46)
                    : const Color(0xFFD4D4D8),
                strokeWidth: 2,
                gap: 4,
                dash: 6,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF225FEC),
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/icons/add_image.png',
                        width: 48,
                        height: 48,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add Image',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF225FEC),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(File image, int index, bool isDark) {
    final isPrimary = index == 0 && _existingUrls.isEmpty;

    return Container(
      width: 128,
      height: 128,
      margin: const EdgeInsets.only(right: 16),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              image,
              width: 128,
              height: 128,
              fit: BoxFit.cover,
            ),
          ),
          // Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Primary Badge
          if (isPrimary)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF225FEC),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Primary',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          // More Options Button (on hover/tap)
          Positioned(
            bottom: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showImageOptions(index, false),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (isDark
                            ? const Color(0xFF18181B)
                            : Colors.white)
                        .withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    LucideIcons.moreVertical,
                    size: 18,
                    color: isDark ? Colors.white : const Color(0xFF18181B),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingImageThumbnail(
      String imageUrl, int index, bool isDark) {
    final isPrimary = index == 0;

    return Container(
      width: 128,
      height: 128,
      margin: const EdgeInsets.only(right: 16),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 128,
              height: 128,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: isDark
                    ? const Color(0xFF27272A)
                    : const Color(0xFFF4F4F5),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: isDark
                    ? const Color(0xFF27272A)
                    : const Color(0xFFF4F4F5),
                child: Icon(
                  LucideIcons.imageOff,
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFFA1A1AA),
                ),
              ),
            ),
          ),
          // Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Primary Badge
          if (isPrimary)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF225FEC),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Primary',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          // More Options Button
          Positioned(
            bottom: 8,
            right: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showImageOptions(index, true),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (isDark
                            ? const Color(0xFF18181B)
                            : Colors.white)
                        .withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    LucideIcons.moreVertical,
                    size: 18,
                    color: isDark ? Colors.white : const Color(0xFF18181B),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailsSection(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF18181B),
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Product Name Input
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Name',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFFD4D4D8)
                      : const Color(0xFF3F3F46),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                onChanged: (value) => _notifyDataChanged(),
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF18181B),
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., Vintage Leather Jacket',
                  hintStyle: TextStyle(
                    color: isDark
                        ? const Color(0xFF71717A)
                        : const Color(0xFFA1A1AA),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF27272A).withOpacity(0.5)
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF3F3F46)
                          : const Color(0xFFD4D4D8),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF3F3F46)
                          : const Color(0xFFD4D4D8),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF225FEC),
                      width: 2,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Short Description Input
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Short Description',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFFD4D4D8)
                      : const Color(0xFF3F3F46),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _descriptionController,
                onChanged: (value) => _notifyDataChanged(),
                maxLines: 4,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF18181B),
                ),
                decoration: InputDecoration(
                  hintText: 'Describe the key features of your item',
                  hintStyle: TextStyle(
                    color: isDark
                        ? const Color(0xFF71717A)
                        : const Color(0xFFA1A1AA),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF27272A).withOpacity(0.5)
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF3F3F46)
                          : const Color(0xFFD4D4D8),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF3F3F46)
                          : const Color(0xFFD4D4D8),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF225FEC),
                      width: 2,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showImagePicker() {
    final totalImages = _existingUrls.length + widget.selectedImages.length;
    if (totalImages >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed')),
      );
      return;
    }

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

  void _showImageOptions(int index, bool isExisting) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            if (isExisting && index == 0)
              ListTile(
                leading: const Icon(LucideIcons.star),
                title: const Text('Set as Primary'),
                onTap: () {
                  Get.back();
                  // Move to first position
                  final url = _existingUrls.removeAt(index);
                  _existingUrls.insert(0, url);
                  setState(() {});
                  widget.onExistingImagesChanged?.call(_existingUrls);
                },
              ),
            ListTile(
              leading: const Icon(LucideIcons.trash2, color: Colors.red),
              title: const Text('Remove', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                if (isExisting) {
                  _removeExistingImage(index);
                } else {
                  _removeImage(index);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final totalImages = _existingUrls.length + widget.selectedImages.length;
    if (totalImages >= 5) {
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

    if (pickedFile != null) {
      final newImages = List<File>.from(widget.selectedImages);
      newImages.add(File(pickedFile.path));
      _notifyDataChanged(newImages);
    }
  }

  void _removeImage(int index) {
    final newImages = List<File>.from(widget.selectedImages);
    newImages.removeAt(index);
    _notifyDataChanged(newImages);
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingUrls.removeAt(index);
    });
    widget.onExistingImagesChanged?.call(_existingUrls);
  }

  void _notifyDataChanged([List<File>? images]) {
    final imagesToSend = images ?? List<File>.from(widget.selectedImages);
    widget.onDataChanged(
      imagesToSend,
      _nameController.text,
      _descriptionController.text,
    );
  }

  int get totalImages => _existingUrls.length + widget.selectedImages.length;
}

// Custom painter for dashed border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.gap = 4.0,
    this.dash = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final radius = 12.0;

    // Top border
    _drawDashedLine(
      canvas,
      paint,
      Offset(radius, 0),
      Offset(size.width - radius, 0),
    );

    // Top-right corner
    _drawDashedArc(
      canvas,
      paint,
      Offset(size.width - radius, radius),
      radius,
      -90 * (3.14159 / 180),
      90 * (3.14159 / 180),
    );

    // Right border
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width, radius),
      Offset(size.width, size.height - radius),
    );

    // Bottom-right corner
    _drawDashedArc(
      canvas,
      paint,
      Offset(size.width - radius, size.height - radius),
      radius,
      0,
      90 * (3.14159 / 180),
    );

    // Bottom border
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width - radius, size.height),
      Offset(radius, size.height),
    );

    // Bottom-left corner
    _drawDashedArc(
      canvas,
      paint,
      Offset(radius, size.height - radius),
      radius,
      90 * (3.14159 / 180),
      90 * (3.14159 / 180),
    );

    // Left border
    _drawDashedLine(
      canvas,
      paint,
      Offset(0, size.height - radius),
      Offset(0, radius),
    );

    // Top-left corner
    _drawDashedArc(
      canvas,
      paint,
      Offset(radius, radius),
      radius,
      180 * (3.14159 / 180),
      90 * (3.14159 / 180),
    );
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Offset start, Offset end) {
    final path = Path();
    final distance = (end - start).distance;
    final dashLength = dash;
    final gapLength = gap;

    double currentDistance = 0;
    bool draw = true;

    while (currentDistance < distance) {
      final remaining = distance - currentDistance;
      final segmentLength = draw
          ? (remaining < dashLength ? remaining : dashLength)
          : (remaining < gapLength ? remaining : gapLength);

      if (draw) {
        final t1 = currentDistance / distance;
        final t2 = (currentDistance + segmentLength) / distance;
        final p1 = Offset.lerp(start, end, t1)!;
        final p2 = Offset.lerp(start, end, t2)!;
        path.moveTo(p1.dx, p1.dy);
        path.lineTo(p2.dx, p2.dy);
      }

      currentDistance += segmentLength;
      draw = !draw;
    }

    canvas.drawPath(path, paint);
  }

  void _drawDashedArc(Canvas canvas, Paint paint, Offset center, double radius,
      double startAngle, double sweepAngle) {
    final path = Path();
    final circumference = radius * sweepAngle;
    final dashLength = dash;
    final gapLength = gap;
    final totalLength = dashLength + gapLength;
    final numDashes = (circumference / totalLength).ceil();

    for (int i = 0; i < numDashes; i++) {
      final dashStart = startAngle + (i * totalLength / radius);
      final dashEnd = dashStart + (dashLength / radius);
      if (dashEnd > startAngle + sweepAngle) {
        path.addArc(
          Rect.fromCircle(center: center, radius: radius),
          dashStart,
          (startAngle + sweepAngle) - dashStart,
        );
        break;
      }
      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        dashStart,
        dashLength / radius,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
