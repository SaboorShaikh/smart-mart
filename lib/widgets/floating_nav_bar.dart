import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'custom_icon.dart';

class NavItemData {
  final IconData? icon;
  final String? iconAsset;
  final String label;
  const NavItemData({this.icon, this.iconAsset, required this.label});
}

class FloatingNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItemData> items;

  const FloatingNavBar(
      {super.key,
      required this.currentIndex,
      required this.onTap,
      required this.items});

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar>
    with TickerProviderStateMixin {
  double? _dragX; // x within inner width
  bool _isDragging = false;
  bool _isPressing = false;
  int? _hoveredIndex;
  late AnimationController _liquidController;
  late Animation<double> _liquidAnimation;

  @override
  void initState() {
    super.initState();
    _liquidController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _liquidAnimation = CurvedAnimation(
      parent: _liquidController,
      curve: Curves.easeOutCubic,
    );
    // Start animation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _liquidController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(FloatingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      if (mounted && _liquidController.isAnimating) {
        _liquidController.stop();
      }
      if (mounted) {
        _liquidController.reset();
        _liquidController.forward();
      }
    }
  }

  @override
  void dispose() {
    _liquidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Weighted widths: selected gets more space; unselected tighter
        const double selectedWeight = 1.8;
        const double unselectedWeight = 0.5;
        final int count = widget.items.length;
        final double totalWeight =
            selectedWeight + (count - 1) * unselectedWeight;
        // Equal horizontal padding on both sides - increased to prevent overflow
        const double sidePadding = 8.0;
        const double rowPadding = 8.0; // Padding inside the Row
        final double innerWidth = (constraints.maxWidth - (sidePadding * 2) - (rowPadding * 2))
            .clamp(0.0, double.infinity);
        final double base = innerWidth / totalWeight;
        final double selectedWidth = base * selectedWeight;
        final double unselectedWidth = base * unselectedWeight;

        // Build widths so their sum is slightly under innerWidth to avoid rounding overflow
        final List<double> itemWidths = List<double>.filled(count, 0);
        double used = 0;
        for (int i = 0; i < count - 1; i++) {
          final double w =
              (i == widget.currentIndex) ? selectedWidth : unselectedWidth;
          itemWidths[i] = w;
          used += w;
        }
        // Last item takes remaining space minus epsilon to avoid RenderFlex overflow
        // Increased epsilon to prevent 5.1px overflow
        const double epsilon = 6.0;
        itemWidths[count - 1] =
            (innerWidth - used - epsilon).clamp(0.0, innerWidth);

        final List<double> cumulativeLeft = <double>[0];
        for (int i = 1; i < count; i++) {
          cumulativeLeft.add(cumulativeLeft[i - 1] + itemWidths[i - 1]);
        }

        double clampInner(double x) => x.clamp(0.0, innerWidth).toDouble();
        int nearestIndex(double x) {
          final double ix = clampInner(x);
          int nearest = 0;
          double best = double.infinity;
          for (int i = 0; i < count; i++) {
            final double c = cumulativeLeft[i] + itemWidths[i] / 2;
            final double d = (ix - c).abs();
            if (d < best) {
              best = d;
              nearest = i;
            }
          }
          return nearest;
        }

        // Determine active index during drag (live preview)
        final bool isInteracting = _isDragging || _isPressing;
        final int activeIndex = isInteracting && _hoveredIndex != null
            ? _hoveredIndex!
            : widget.currentIndex;

        // Measure label widths for content-based capsule sizing
        TextStyle labelStyle = DefaultTextStyle.of(context).style.copyWith(
              fontWeight: FontWeight.w700,
            );
        double measureLabel(String text) {
          final TextPainter tp = TextPainter(
            text: TextSpan(text: text, style: labelStyle),
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout(minWidth: 0, maxWidth: double.infinity);
          return tp.size.width;
        }

        // Content-based capsule width: icon + spacing + label when active
        double contentWidthForIndex(int index) {
          final bool active = index == activeIndex;
          final double iconSize = active ? 33 : 23;
          final double labelWidth =
              active ? measureLabel(widget.items[index].label) : 0;
          final double spacing = active && labelWidth > 0 ? 6 : 0;
          return iconSize + spacing + labelWidth;
        }

        // Capsule from drag or current index
        double capsuleLeft;
        double capsuleWidth;
        final double contentW = contentWidthForIndex(activeIndex);
        // Add internal pill padding
        const double pillHPadding = 12;
        capsuleWidth =
            (contentW + pillHPadding).clamp(0.0, itemWidths[activeIndex] - 4);

        if (isInteracting && _dragX != null) {
          final double ix = clampInner(_dragX!);
          // Center capsule on finger x while keeping within inner bounds
          final double minLeft = 0.0 + (capsuleWidth / 2);
          final double maxLeft = innerWidth - (capsuleWidth / 2);
          final double centerX = ix.clamp(minLeft, maxLeft);
          capsuleLeft = sidePadding + centerX - (capsuleWidth / 2);
        } else {
          capsuleLeft = sidePadding +
              cumulativeLeft[activeIndex] +
              (itemWidths[activeIndex] - capsuleWidth) / 2;
        }

        // Theme-aware colors
        final bool isDark = theme.brightness == Brightness.dark;
        final Color baseColor = isDark 
            ? Colors.white.withOpacity(0.08)
            : Colors.grey.withOpacity(0.05);
        final Color borderColor = isDark
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.3);
        
        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedBuilder(
              animation: _liquidAnimation,
              builder: (context, child) {
                // Enhanced liquid wave effect on full navbar background
                final double waveIntensity = _liquidAnimation.value.isFinite 
                    ? (1 - _liquidAnimation.value) * 0.5 
                    : 0.0;
                
                return Container(
                  height: 68,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: borderColor,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark 
                            ? Colors.black.withOpacity(0.4)
                            : Colors.black.withOpacity(0.08),
                        blurRadius: 20 + (waveIntensity * 5),
                        spreadRadius: waveIntensity * 2,
                        offset: Offset(0, 8 + (waveIntensity * 2)),
                      ),
                      BoxShadow(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white.withOpacity(0.5),
                        blurRadius: 1,
                        spreadRadius: 0,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      children: [
                        // Full navbar liquid background effect
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _FullNavbarLiquidPainter(
                              animation: _liquidAnimation,
                              theme: theme,
                              isDark: isDark,
                              currentIndex: widget.currentIndex,
                              itemCount: widget.items.length,
                            ),
                            child: Container(),
                          ),
                        ),
                        GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) {
              final double panX = details.localPosition.dx - sidePadding;
              final int panIndex = nearestIndex(panX);
              print('Touch detected! _isPressing will be true');
              setState(() {
                _isPressing = true;
                _isDragging =
                    false; // Start with false, will be true when actually dragging
                _dragX = panX;
                _hoveredIndex = panIndex;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _isDragging = true; // Set to true when actually moving
                _dragX = details.localPosition.dx - sidePadding;
                final int idx = nearestIndex(_dragX!);
                if (idx != _hoveredIndex) {
                  _hoveredIndex = idx;
                  if (_hoveredIndex != widget.currentIndex) {
                    widget.onTap(_hoveredIndex!); // live switch
                  }
                }
              });
            },
            onPanEnd: (details) {
              setState(() {
                _isPressing = false;
                _isDragging = false;
              });
              if (_dragX != null) {
                final int target = nearestIndex(_dragX!);
                if (target != widget.currentIndex) {
                  widget.onTap(target);
                }
              }
              setState(() {
                _dragX = null;
                _hoveredIndex = null;
              });
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Liquid effect capsule indicator with morphing animation
                AnimatedBuilder(
                  animation: _liquidAnimation,
                  builder: (context, child) {
                    // Safety check for animation value
                    final double animValue = _liquidAnimation.value.isFinite 
                        ? _liquidAnimation.value 
                        : 1.0;
                    
                    // Liquid morphing effect - creates wave-like deformation
                    final double liquidOffset = 
                        (1 - animValue) * 8.0; // Bounce effect
                    final double liquidScale = 
                        0.95 + (animValue * 0.05); // Scale animation
                    final double morphFactor = 
                        (1 - animValue) * 0.3; // Morphing factor
                    
                    // Calculate liquid position with elastic bounce
                    final double currentLeft = _isDragging || _isPressing
                        ? capsuleLeft
                        : capsuleLeft + (liquidOffset * (1 - animValue));
                    
                    final double currentWidth = _isDragging || _isPressing
                        ? capsuleWidth * 1.15
                        : capsuleWidth * liquidScale;
                    
                    final double currentTop = _isDragging || _isPressing
                        ? 6.0
                        : 10.0 - (liquidOffset * 0.3);
                    
                    final double currentHeight = _isDragging || _isPressing
                        ? 56.0
                        : 48.0 + (liquidOffset * 0.5);
                    
                    // Create morphing border radius for liquid effect
                    final double borderRadius = 20.0 - (morphFactor * 4.0);
                    
                    return Positioned(
                      left: currentLeft,
                      top: currentTop,
                      width: currentWidth,
                      height: currentHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary.withOpacity(
                                  _isDragging || _isPressing ? 0.25 : 0.18),
                              theme.colorScheme.primary.withOpacity(
                                  _isDragging || _isPressing ? 0.18 : 0.12),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(borderRadius),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(
                                  _isDragging || _isPressing ? 0.2 : 0.15),
                              blurRadius: _isDragging || _isPressing ? 8 : 6,
                              spreadRadius: 0,
                              offset: Offset(0, 2 + (morphFactor * 2)),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(borderRadius),
                          child: CustomPaint(
                            painter: _LiquidWavePainter(
                              animation: _liquidAnimation,
                              color: theme.colorScheme.primary,
                            ),
                            child: Container(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: rowPadding),
                  child: Row(
                    children: [
                      for (int i = 0; i < widget.items.length; i++)
                        _NavItem(
                          width: itemWidths[i],
                          isSelected: i == widget.currentIndex,
                          data: widget.items[i],
                          onTap: () => widget.onTap(i),
                        ),
                    ],
                  ),
                ),
              ],
            ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final double width;
  final bool isSelected;
  final NavItemData data;
  final VoidCallback onTap;

  const _NavItem(
      {required this.width,
      required this.isSelected,
      required this.data,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    
    // Theme-aware colors for unselected items
    final Color unselectedColor = isDark
        ? Colors.white.withOpacity(0.6)
        : Colors.black.withOpacity(0.5);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        child: SizedBox(
          width: width,
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: data.iconAsset != null
                    ? CustomIcon(
                        assetPath: data.iconAsset!,
                        size: isSelected ? 28 : 22,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : unselectedColor,
                      )
                    : Icon(
                        data.icon,
                        size: isSelected ? 28 : 22,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : unselectedColor,
                      ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-0.2, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                child: isSelected
                    ? Padding(
                        key: const ValueKey('label'),
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          data.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.2,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for liquid wave effect
class _LiquidWavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _LiquidWavePainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (!animation.value.isFinite || size.width <= 0 || size.height <= 0) {
      return;
    }
    
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final animValue = animation.value.clamp(0.0, 1.0);
    final waveHeight = 3.0 * (1 - animValue);
    final waveFrequency = 2.0;

    // Create wave effect at the top
    path.moveTo(0, size.height * 0.1);
    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.1 +
          waveHeight *
              math.sin((x / size.width * waveFrequency * math.pi * 2) +
                  (animValue * math.pi * 2));
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    // Create wave effect at the bottom
    final bottomPath = Path();
    bottomPath.moveTo(0, size.height * 0.9);
    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.9 +
          waveHeight *
              math.sin((x / size.width * waveFrequency * math.pi * 2) +
                  (animValue * math.pi * 2) + math.pi);
      if (x == 0) {
        bottomPath.moveTo(x, y);
      } else {
        bottomPath.lineTo(x, y);
      }
    }
    bottomPath.lineTo(size.width, size.height);
    bottomPath.lineTo(0, size.height);
    bottomPath.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(bottomPath, paint);
  }

  @override
  bool shouldRepaint(_LiquidWavePainter oldDelegate) {
    return oldDelegate.animation.value != animation.value;
  }
}

// Custom painter for full navbar liquid background effect
class _FullNavbarLiquidPainter extends CustomPainter {
  final Animation<double> animation;
  final ThemeData theme;
  final bool isDark;
  final int currentIndex;
  final int itemCount;

  _FullNavbarLiquidPainter({
    required this.animation,
    required this.theme,
    required this.isDark,
    required this.currentIndex,
    required this.itemCount,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (!animation.value.isFinite || size.width <= 0 || size.height <= 0) {
      return;
    }
    
    final animValue = animation.value.clamp(0.0, 1.0);
    final waveIntensity = (1 - animValue) * 0.4;
    
    // Calculate approximate position of selected item for liquid flow
    final double itemWidth = size.width / itemCount;
    final double selectedCenterX = (currentIndex * itemWidth) + (itemWidth / 2);
    
    // Create liquid gradient effect
    final gradient = RadialGradient(
      center: Alignment(
        ((selectedCenterX / size.width) * 2 - 1),
        0.0,
      ),
      radius: 1.5,
      colors: [
        theme.colorScheme.primary.withOpacity(0.15 * (1 - animValue)),
        theme.colorScheme.primary.withOpacity(0.08 * (1 - animValue)),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Create multiple liquid waves across the full navbar
    final path = Path();
    final waveHeight = 4.0 * waveIntensity;
    final waveFrequency = 1.2;
    final waveSpeed = animValue * math.pi * 2;

    // Top liquid wave
    path.moveTo(0, size.height * 0.15);
    for (double x = 0; x <= size.width; x += 1) {
      final normalizedX = x / size.width;
      final distanceFromCenter = (normalizedX - (selectedCenterX / size.width)).abs();
      final waveAmplitude = waveHeight * (1 - distanceFromCenter * 0.5);
      
      final y = size.height * 0.15 +
          waveAmplitude *
              math.sin((normalizedX * waveFrequency * math.pi * 2) + waveSpeed);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    // Middle liquid wave
    final middlePath = Path();
    middlePath.moveTo(0, size.height * 0.5);
    for (double x = 0; x <= size.width; x += 1) {
      final normalizedX = x / size.width;
      final distanceFromCenter = (normalizedX - (selectedCenterX / size.width)).abs();
      final waveAmplitude = waveHeight * 0.6 * (1 - distanceFromCenter * 0.7);
      
      final y = size.height * 0.5 +
          waveAmplitude *
              math.sin((normalizedX * waveFrequency * math.pi * 2) + waveSpeed + math.pi / 3);
      if (x == 0) {
        middlePath.moveTo(x, y);
      } else {
        middlePath.lineTo(x, y);
      }
    }
    middlePath.lineTo(size.width, size.height);
    middlePath.lineTo(0, size.height);
    middlePath.close();

    // Bottom liquid wave
    final bottomPath = Path();
    bottomPath.moveTo(0, size.height * 0.85);
    for (double x = 0; x <= size.width; x += 1) {
      final normalizedX = x / size.width;
      final distanceFromCenter = (normalizedX - (selectedCenterX / size.width)).abs();
      final waveAmplitude = waveHeight * 0.8 * (1 - distanceFromCenter * 0.6);
      
      final y = size.height * 0.85 +
          waveAmplitude *
              math.sin((normalizedX * waveFrequency * math.pi * 2) + waveSpeed + math.pi);
      if (x == 0) {
        bottomPath.moveTo(x, y);
      } else {
        bottomPath.lineTo(x, y);
      }
    }
    bottomPath.lineTo(size.width, size.height);
    bottomPath.lineTo(0, size.height);
    bottomPath.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(middlePath, paint);
    canvas.drawPath(bottomPath, paint);
  }

  @override
  bool shouldRepaint(_FullNavbarLiquidPainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
        oldDelegate.currentIndex != currentIndex;
  }
}
