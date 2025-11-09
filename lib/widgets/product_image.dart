import 'dart:io';
import 'package:flutter/material.dart';

/// A reusable widget for displaying images with smart source detection.
///
/// Automatically handles:
/// - Local file images (path doesn't start with http/https)
/// - Network images (URLs starting with http/https)
/// - Error states with fallback widget
/// - Null/empty path handling
class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;
  final int? cacheWidth;
  final int? cacheHeight;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorWidget,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorWidget();
    }

    final isLocalFile = !imageUrl!.startsWith('http');

    if (isLocalFile) {
      return Image.file(
        File(imageUrl!),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }

    return Image.network(
      imageUrl!,
      fit: fit,
      width: width,
      height: height,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) {
      return errorWidget!;
    }

    // Default fallback: neutral container with icon that respects dimensions
    // If width/height are specified, use them; otherwise expand to fill parent
    return Builder(
      builder: (context) {
        final Widget errorIcon = Icon(
          Icons.image_not_supported_outlined,
          size: _calculateDefaultIconSize(),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

        if (width != null || height != null) {
          return Container(
            width: width,
            height: height,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Center(child: errorIcon),
          );
        }

        // No dimensions specified - expand to fill parent container
        return Container(
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Center(child: errorIcon),
        );
      },
    );
  }

  double _calculateDefaultIconSize() {
    // Use smaller dimension if both are specified
    if (width != null && height != null) {
      return (width! < height! ? width! : height!) * 0.4;
    } else if (width != null) {
      return width! * 0.4;
    } else if (height != null) {
      return height! * 0.4;
    }
    // Default size for when no dimensions are specified
    return 48.0;
  }
}
