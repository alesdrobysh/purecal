import 'package:flutter/material.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? Colors.green[900] : Colors.green[50];
    final borderColor = isDark ? Colors.green[600] : Colors.green[300];
    final iconColor = isDark ? Colors.green[300] : Colors.green[700];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            imageUrl == null
                ? Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor!, width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.fastfood,
                        color: iconColor,
                        size: 30,
                      ),
                    ),
                  )
                : Image.network(
                    imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    cacheWidth: 120,
                    cacheHeight: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor!, width: 2),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.fastfood,
                            color: iconColor,
                            size: 30,
                          ),
                        ),
                      );
                    },
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
