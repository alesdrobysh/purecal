import 'package:flutter/material.dart';
import '../config/decorations.dart';
import 'product_image.dart';

class FrequentProductCard extends StatelessWidget {
  final String barcode;
  final String productName;
  final String? imageUrl;
  final int usageCount;
  final VoidCallback onTap;

  const FrequentProductCard({
    super.key,
    required this.barcode,
    required this.productName,
    this.imageUrl,
    required this.usageCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            ProductImage(
              imageUrl: imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              cacheWidth: 120,
              cacheHeight: 120,
              errorWidget: Container(
                width: 60,
                height: 60,
                decoration: AppShapes.greenContainer(context),
                child: Center(
                  child: Icon(
                    Icons.fastfood,
                    color: iconColor,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              productName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
