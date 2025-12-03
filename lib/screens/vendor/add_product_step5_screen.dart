import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';

class AddProductStep5Screen extends StatefulWidget {
  final String nutritionInfo;
  final Function(String) onDataChanged;
  final VoidCallback? onStartOver;

  const AddProductStep5Screen({
    super.key,
    required this.nutritionInfo,
    required this.onDataChanged,
    this.onStartOver,
  });

  @override
  State<AddProductStep5Screen> createState() => _AddProductStep5ScreenState();
}

class _AddProductStep5ScreenState extends State<AddProductStep5Screen> {
  final _nutritionController = TextEditingController();
  final List<String> _nutrientsList = [];

  @override
  void initState() {
    super.initState();
    // Keep text field empty, parse existing nutrients into list
    _nutritionController.text = '';
    
    // Parse comma-separated nutrients into list
    if (widget.nutritionInfo.isNotEmpty) {
      _nutrientsList.addAll(
        widget.nutritionInfo.split(',').map((n) => n.trim()).where((n) => n.isNotEmpty),
      );
    }
  }

  @override
  void dispose() {
    _nutritionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF4F5F7), // Light gray background
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : Colors.white, // White background for light mode
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF1E293B).withOpacity(0.8)
                        : const Color(0xFFE2E8F0).withOpacity(0.8),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Back Button, Indicators, and Start Over
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
                            final isActive = index <= 4; // Stage 5 is index 4
                            final isCurrent = index == 4;
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
                      // Start Over button
                      if (widget.onStartOver != null)
                        TextButton(
                          onPressed: widget.onStartOver,
                          child: Text(
                            'Start Over',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    'Nutrition Information',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF18181B),
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress Bar Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stage 5 of 6',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFFA1A1AA)
                              : const Color(0xFF71717A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Progress bar with equal padding
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: 5 / 6, // 83.33% for stage 5
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
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Subtitle/Instructions
                    Text(
                      'Add nutritional details to help customers understand product value.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: isDark
                            ? const Color(0xFFA1A1AA)
                            : const Color(0xFF71717A),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Add Nutrients Section
                    _buildAddNutrientsSection(theme, isDark),
                    const SizedBox(height: 32),
                    // Quick Add Common Nutrients Section
                    _buildQuickAddSection(theme, isDark),
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

  Widget _buildAddNutrientsSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Nutrients',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFD4D4D8) : const Color(0xFF18181B),
          ),
        ),
        const SizedBox(height: 16),
        // Input field with circular button
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: _nutritionController,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  setState(() {
                    _nutrientsList.add(value.trim());
                    _nutritionController.clear();
                    _notifyDataChanged();
                  });
                }
              },
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF18181B),
              ),
              decoration: InputDecoration(
                hintText: 'e.g., Vitamin C, Protein...',
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? const Color(0xFF71717A)
                      : const Color(0xFFA1A1AA),
                ),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF1E293B)
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF225FEC),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            Positioned(
              right: 8,
              child: Material(
                color: const Color(0xFF225FEC),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    if (_nutritionController.text.trim().isNotEmpty) {
                      setState(() {
                        _nutrientsList.add(_nutritionController.text.trim());
                        _nutritionController.clear();
                        _notifyDataChanged();
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.chevronRight,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Dashed border container with white background showing added nutrients
        SizedBox(
          width: double.infinity,
          height: 96,
          child: CustomPaint(
            painter: DashedBorderPainter(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFF94A3B8),
              strokeWidth: 1.5,
              gap: 4,
              dash: 6,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _nutrientsList.isEmpty
                  ? Center(
                      child: Text(
                        'Added nutrients will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF71717A)
                              : const Color(0xFFA1A1AA),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: _nutrientsList.map((nutrient) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF225FEC).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                nutrient,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF225FEC),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _nutrientsList.remove(nutrient);
                                    _notifyDataChanged();
                                  });
                                },
                                child: Icon(
                                  LucideIcons.x,
                                  size: 16,
                                  color: const Color(0xFF225FEC),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddSection(ThemeData theme, bool isDark) {
    final commonNutrition = [
      'Vitamin C',
      'Fiber',
      'Sodium',
      'Potassium',
      'Vitamin D',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Add Common Nutrients',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFD4D4D8) : const Color(0xFF18181B),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonNutrition.map((nutrition) {
            return OutlinedButton(
              onPressed: () {
                setState(() {
                  if (!_nutrientsList.contains(nutrition)) {
                    _nutrientsList.add(nutrition);
                    _notifyDataChanged();
                  }
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                side: BorderSide(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                  width: 1,
                ),
                backgroundColor: isDark
                    ? const Color(0xFF1E293B)
                    : Colors.white,
              ),
              child: Text(
                nutrition,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFFD4D4D8)
                      : const Color(0xFF374151),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _notifyDataChanged() {
    widget.onDataChanged(_nutrientsList.join(', '));
  }
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
