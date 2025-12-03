import 'package:flutter/material.dart';
import 'dart:ui';
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

class _FloatingNavBarState extends State<FloatingNavBar> {
  double? _dragX; // x within inner width
  bool _isDragging = false;
  bool _isPressing = false;
  int? _hoveredIndex;

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

        // Theme-aware colors - improved UI
        final bool isDark = theme.brightness == Brightness.dark;
        final Color baseColor = isDark 
            ? const Color(0xFF1E293B).withOpacity(0.9)
            : Colors.white.withOpacity(0.9);
        final Color borderColor = isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.06);
        
        return Container(
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? Colors.black.withOpacity(0.5)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: borderColor,
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (details) {
                        final double panX = details.localPosition.dx - sidePadding;
                        final int panIndex = nearestIndex(panX);
                        setState(() {
                          _isPressing = true;
                          _isDragging = false;
                          _dragX = panX;
                          _hoveredIndex = panIndex;
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          _isDragging = true;
                          _dragX = details.localPosition.dx - sidePadding;
                          final int idx = nearestIndex(_dragX!);
                          if (idx != _hoveredIndex) {
                            _hoveredIndex = idx;
                            if (_hoveredIndex != widget.currentIndex) {
                              widget.onTap(_hoveredIndex!);
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
                          // Clean capsule indicator with smooth animation
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            left: capsuleLeft,
                            top: 8,
                            width: capsuleWidth,
                            height: 52,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.2),
                                    theme.colorScheme.primary.withOpacity(0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
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

