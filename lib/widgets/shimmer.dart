import 'package:flutter/material.dart';

/// YouTube-style shimmer effect widget with diagonal gradient moving right to left
class YouTubeShimmer extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color baseColor;
  final Color highlightColor;
  final Duration period;

  const YouTubeShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor = const Color(0xFFEBEBEB),
    this.highlightColor = const Color(0xFFFFFFFF),
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  State<YouTubeShimmer> createState() => _YouTubeShimmerState();
}

class _YouTubeShimmerState extends State<YouTubeShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.period,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.baseColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            child: CustomPaint(
              painter: _ShimmerPainter(
                progress: _controller.value,
                baseColor: widget.baseColor,
                highlightColor: widget.highlightColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  final Color highlightColor;

  _ShimmerPainter({
    required this.progress,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate shimmer position moving from right to left
    // Progress: 0 = right side, 1 = left side (moved completely)
    final shimmerWidth = size.width * 0.5;
    final startX = size.width + shimmerWidth - (progress * (size.width + shimmerWidth * 2));
    
    // Center of shimmer at current position
    final centerY = size.height / 2;
    final halfWidth = shimmerWidth;
    final halfHeight = size.height * 0.6;
    
    // Create diagonal gradient
    final gradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        baseColor,
        baseColor,
        highlightColor,
        baseColor,
        baseColor,
      ],
      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
    );

    // Apply gradient shader
    final gradientShader = gradient.createShader(
      Rect.fromLTWH(
        startX - halfWidth,
        centerY - halfHeight,
        shimmerWidth * 2,
        halfHeight * 2,
      ),
    );

    final paint = Paint()
      ..shader = gradientShader
      ..blendMode = BlendMode.srcATop;

    // Draw the shimmer effect
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.highlightColor != highlightColor;
  }
}

/// A shimmer effect widget that creates a YouTube-like skeleton loading animation
/// Wraps any child widget with shimmer effect
class Shimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration period;

  const Shimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFEBEBEB),
    this.highlightColor = const Color(0xFFFFFFFF),
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.period,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate shimmer position moving from right to left
        // Progress: 0 = right side, 1 = left side
        final progress = _controller.value;
        final shimmerWidth = 0.5; // Width of shimmer as fraction of container
        
        // Position moves from right (1.5) to left (-0.5)
        final shimmerPosition = 1.5 - (progress * 2.0);

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            // Diagonal gradient similar to YouTube (top-right to bottom-left)
            return LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                widget.baseColor,
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
                widget.baseColor,
              ],
              stops: [
                0.0,
                (shimmerPosition - shimmerWidth * 0.6).clamp(0.0, 1.0),
                shimmerPosition.clamp(0.0, 1.0),
                (shimmerPosition + shimmerWidth * 0.6).clamp(0.0, 1.0),
                1.0,
              ],
            ).createShader(
              Rect.fromLTWH(
                -bounds.width * 0.2,
                -bounds.height * 0.2,
                bounds.width * 1.4,
                bounds.height * 1.4,
              ),
            );
          },
          child: widget.child,
        );
      },
    );
  }
}

/// A simple shimmer container that can be used for skeleton loading
/// Uses YouTube-style shimmer effect (right to left diagonal movement)
class ShimmerContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor = const Color(0xFFEBEBEB),
    this.highlightColor = const Color(0xFFFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return YouTubeShimmer(
      width: width,
      height: height,
      borderRadius: borderRadius,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }
}
