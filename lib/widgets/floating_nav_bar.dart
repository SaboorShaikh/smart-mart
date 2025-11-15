import 'package:flutter/material.dart';
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
        // Equal horizontal padding on both sides
        const double sidePadding = 8.0;
        final double innerWidth = (constraints.maxWidth - (sidePadding * 2))
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
        // Last item takes remaining space minus epsilon to avoid RenderFlex overflow by 1-2px
        const double epsilon = 2.0;
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

        return Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.90),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 10,
                spreadRadius: 0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: GestureDetector(
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
                // Sliding capsule indicator (iOS-style)
                _isDragging || _isPressing
                    ? Positioned(
                        left: capsuleLeft,
                        top: -6,
                        width: capsuleWidth * 1.2, // Make it wider when pressed
                        height: 72,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.alphaBlend(
                              theme.colorScheme.primary.withOpacity(
                                  0.15), // Slightly more opaque when pressed
                              Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      )
                    : AnimatedPositioned(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        left: capsuleLeft,
                        top: 8,
                        width: capsuleWidth,
                        height: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.alphaBlend(
                              theme.colorScheme.primary.withOpacity(0.10),
                              Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: width,
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            data.iconAsset != null
                ? CustomIcon(
                    assetPath: data.iconAsset!,
                    size: isSelected ? 33 : 23,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : const Color(0xB3000000),
                  )
                : Icon(
                    data.icon,
                    size: isSelected ? 33 : 23,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : const Color(0xB3000000),
                  ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: isSelected
                  ? Padding(
                      key: const ValueKey('label'),
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        data.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }
}
