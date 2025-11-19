import 'package:flutter/material.dart';
import 'shimmer.dart';

/// Skeleton loader for product cards
class ProductCardSkeleton extends StatelessWidget {
  final double? width;
  final EdgeInsetsGeometry? imagePadding;

  const ProductCardSkeleton({
    super.key,
    this.width,
    this.imagePadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          Padding(
            padding: imagePadding ?? const EdgeInsets.all(12),
            child: ShimmerContainer(
              height: 135,
              width: double.infinity,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          // Content padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name skeleton
                ShimmerContainer(
                  height: 16,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                // Vendor name skeleton
                ShimmerContainer(
                  height: 12,
                  width: 120,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
                // Price skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerContainer(
                      height: 20,
                      width: 80,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    ShimmerContainer(
                      height: 32,
                      width: 32,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for mart cards
class MartCardSkeleton extends StatelessWidget {
  const MartCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo skeleton
          ShimmerContainer(
            height: 100,
            width: double.infinity,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 10),
          // Store name skeleton
          ShimmerContainer(
            height: 16,
            width: double.infinity,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 6),
          // Distance skeleton
          ShimmerContainer(
            height: 12,
            width: 80,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 6),
          // Rating skeleton
          ShimmerContainer(
            height: 16,
            width: 60,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loader for section header
class SectionHeaderSkeleton extends StatelessWidget {
  const SectionHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ShimmerContainer(
          height: 24,
          width: 150,
          borderRadius: BorderRadius.circular(4),
        ),
        ShimmerContainer(
          height: 16,
          width: 60,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

/// Skeleton loader for promo carousel
class PromoCarouselSkeleton extends StatelessWidget {
  const PromoCarouselSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerContainer(
          height: 190,
          width: double.infinity,
          borderRadius: BorderRadius.circular(24),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Skeleton loader for search bar
class SearchBarSkeleton extends StatelessWidget {
  const SearchBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerContainer(
      height: 56,
      width: double.infinity,
      borderRadius: BorderRadius.circular(16),
    );
  }
}

/// Skeleton loader for top bar location
class TopBarSkeleton extends StatelessWidget {
  const TopBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              ShimmerContainer(
                width: 28,
                height: 28,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerContainer(
                      height: 12,
                      width: 60,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    ShimmerContainer(
                      height: 18,
                      width: 150,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ShimmerContainer(
          width: 36,
          height: 36,
          borderRadius: BorderRadius.circular(18),
        ),
        const SizedBox(width: 12),
        ShimmerContainer(
          width: 36,
          height: 36,
          borderRadius: BorderRadius.circular(18),
        ),
      ],
    );
  }
}

