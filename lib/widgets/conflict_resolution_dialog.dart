import 'package:flutter/material.dart';
import '../models/food_product.dart';
import '../services/product_import_service.dart';
import '../l10n/app_localizations.dart';
import 'product_image.dart';

class ConflictResolutionDialog extends StatelessWidget {
  final FoodProduct existingProduct;
  final FoodProduct importedProduct;

  const ConflictResolutionDialog({
    super.key,
    required this.existingProduct,
    required this.importedProduct,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.productConflictTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.productConflictMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildProductComparison(context, l10n),
          ],
        ),
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Individual actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(ConflictResolution.skip);
                    },
                    child: Text(l10n.keepExisting),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(ConflictResolution.replace);
                    },
                    child: Text(l10n.replaceWithImport),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            // Batch actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(ConflictResolution.keepAll);
                    },
                    child: Text(l10n.keepAllRemaining),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(ConflictResolution.replaceAll);
                    },
                    child: Text(l10n.replaceAllRemaining),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductComparison(BuildContext context, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildProductCard(
            context,
            l10n.existingProduct,
            existingProduct,
            Colors.blue.shade50,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: _buildProductCard(
            context,
            l10n.importedProduct,
            importedProduct,
            Colors.green.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    String title,
    FoodProduct product,
    Color backgroundColor,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ProductImage(
                    imageUrl: product.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (product.brand != null && product.brand!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                product.brand!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            _buildMacroRow(
              context,
              '${l10n.calories}:',
              '${product.caloriesPer100g.toStringAsFixed(0)} kcal',
            ),
            _buildMacroRow(
              context,
              '${l10n.protein}:',
              '${product.proteinsPer100g.toStringAsFixed(1)}g',
            ),
            _buildMacroRow(
              context,
              '${l10n.fat}:',
              '${product.fatPer100g.toStringAsFixed(1)}g',
            ),
            _buildMacroRow(
              context,
              '${l10n.carbs}:',
              '${product.carbsPer100g.toStringAsFixed(1)}g',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
