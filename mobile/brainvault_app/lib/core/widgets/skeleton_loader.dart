import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A base component for creating shimmer loading effects
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final ShapeBorder? shape;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 4.0,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    // Using specific grey shades for standard skeleton look regardless of theme for now,
    // or deriving from theme surface variant if preferred.
    // Sticking to blueprint spec: Base color: grey[300], highlight: grey[100]
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: baseColor,
          shape:
              shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
        ),
      ),
    );
  }
}

/// Skeleton loading state for a list of Document Cards
class DocumentCardSkeleton extends StatelessWidget {
  const DocumentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon placeholder
            const SkeletonLoader(width: 40, height: 40, borderRadius: 8),
            const SizedBox(width: 16),
            // Text content placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title line
                  const SkeletonLoader(
                    width: double.infinity,
                    height: 16,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 8),
                  // Metadata line (shorter)
                  SkeletonLoader(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 12,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loading state for Chat Messages
class ChatMessageSkeleton extends StatelessWidget {
  final bool isUser;

  const ChatMessageSkeleton({super.key, this.isUser = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const SkeletonLoader(
              width: 32,
              height: 32,
              borderRadius: 16, // Circle
            ),
            const SizedBox(width: 8),
          ],

          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200], // Placeholder container color
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 180, height: 14),
                const SizedBox(height: 6),
                const SkeletonLoader(width: 120, height: 14),
                if (!isUser) ...[
                  const SizedBox(height: 6),
                  const SkeletonLoader(width: 200, height: 14),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
