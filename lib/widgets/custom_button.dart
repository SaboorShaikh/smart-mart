import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Widget? icon;
  final bool isDisabled;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 12.0,
    this.icon,
    this.isDisabled = false,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading && !widget.isDisabled;
    
    final effectiveBackgroundColor = widget.isOutlined
        ? Colors.transparent
        : (widget.backgroundColor ?? theme.colorScheme.primary);
    
    final effectiveTextColor = widget.isOutlined
        ? (widget.textColor ?? theme.colorScheme.primary)
        : (widget.textColor ?? Colors.white);

    final buttonWidget = widget.isOutlined
        ? _buildOutlinedButton(isEnabled, effectiveTextColor, theme)
        : _buildFilledButton(isEnabled, effectiveBackgroundColor, effectiveTextColor);
    
    return SizedBox(
      width: widget.width,
      height: widget.height ?? 48,
      child: buttonWidget,
    );
  }

  Widget _buildOutlinedButton(bool isEnabled, Color effectiveTextColor, ThemeData theme) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: isEnabled
                  ? (widget.backgroundColor ?? theme.colorScheme.primary)
                  : theme.colorScheme.outline,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment(_shimmerAnimation.value - 1, 0),
                  end: Alignment(_shimmerAnimation.value, 0),
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.overlay,
              child: OutlinedButton(
                onPressed: isEnabled ? widget.onPressed : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: effectiveTextColor,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: _buildButtonContent(effectiveTextColor),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilledButton(bool isEnabled, Color effectiveBackgroundColor, Color effectiveTextColor) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: isEnabled ? effectiveBackgroundColor : effectiveBackgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: effectiveBackgroundColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled
                  ? () {
                      debugPrint('CustomButton tapped, onPressed: ${widget.onPressed}');
                      widget.onPressed?.call();
                    }
                  : null,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Stack(
                children: [
                  // Full button shimmer overlay (ignoring pointer events)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment(_shimmerAnimation.value - 1, 0),
                            end: Alignment(_shimmerAnimation.value, 0),
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.4),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.overlay,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(widget.borderRadius),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Button content with text shimmer
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    alignment: Alignment.center,
                    child: _buildButtonContentWithShimmer(effectiveTextColor),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContentWithShimmer(Color textColor) {
    if (widget.isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    final content = widget.icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.icon!,
              const SizedBox(width: 8),
              Text(
                widget.text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        : Text(
            widget.text,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          );

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment(_shimmerAnimation.value - 1, 0),
          end: Alignment(_shimmerAnimation.value, 0),
          colors: [
            textColor,
            Colors.white,
            textColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: content,
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (widget.isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.icon!,
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
