import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/food_product.dart';
import '../models/meal_type.dart';
import '../services/diary_provider.dart';
import 'custom_input_decoration.dart';
import 'product_image.dart';
import '../config/decorations.dart';

class AddProductDialog extends StatefulWidget {
  final FoodProduct product;
  final MealType? mealType;

  const AddProductDialog({
    super.key,
    required this.product,
    this.mealType,
  });

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  late TextEditingController _portionController;
  late double _currentPortion;
  late MealType _selectedMealType;

  @override
  void initState() {
    super.initState();
    _currentPortion = widget.product.servingSize ?? 100;
    _portionController =
        TextEditingController(text: _currentPortion.toStringAsFixed(0));
    _selectedMealType = widget.mealType ?? MealType.fromTime(DateTime.now());
  }

  @override
  void dispose() {
    _portionController.dispose();
    super.dispose();
  }

  void _updatePortion(String value) {
    final portion = double.tryParse(value);
    if (portion != null && portion > 0) {
      setState(() {
        _currentPortion = portion;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nutrition = widget.product.calculateNutrition(_currentPortion);

    return AlertDialog(
      title: Text(l10n.addToDiary),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.product.imageUrl != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ProductImage(
                    imageUrl: widget.product.imageUrl,
                    height: 120,
                    fit: BoxFit.cover,
                    errorWidget: const Icon(Icons.fastfood, size: 60),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.product.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.product.brand != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.product.brand!,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              l10n.nutritionPer100g,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildNutritionRow(
                l10n.calories, '${widget.product.caloriesPer100g} ${l10n.kcal}'),
            _buildNutritionRow(l10n.protein, '${widget.product.proteinsPer100g}${l10n.grams}'),
            _buildNutritionRow(l10n.fat, '${widget.product.fatPer100g}${l10n.grams}'),
            _buildNutritionRow(l10n.carbs, '${widget.product.carbsPer100g}${l10n.grams}'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              l10n.mealType,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<MealType>(
              initialValue: _selectedMealType,
              decoration: customInputDecoration(context).copyWith(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: MealType.values.map((mealType) {
                return DropdownMenuItem(
                  value: mealType,
                  child: Row(
                    children: [
                      Text(mealType.emoji,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(mealType.displayName(context)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMealType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portionController,
              keyboardType: TextInputType.number,
              decoration: customInputDecoration(context).copyWith(
                labelText: l10n.portionSize,
                suffixText: l10n.gramsUnit,
              ),
              onChanged: _updatePortion,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: AppShapes.greenInfoBox(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.yourPortion,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildNutritionRow(l10n.calories,
                      '${nutrition.calories.toStringAsFixed(1)} ${l10n.kcal}'),
                  _buildNutritionRow(
                      l10n.protein, '${nutrition.proteins.toStringAsFixed(1)}${l10n.grams}'),
                  _buildNutritionRow(
                      l10n.fat, '${nutrition.fat.toStringAsFixed(1)}${l10n.grams}'),
                  _buildNutritionRow(
                      l10n.carbs, '${nutrition.carbs.toStringAsFixed(1)}${l10n.grams}'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final provider = Provider.of<DiaryProvider>(context, listen: false);
            provider.addProductEntry(
                widget.product, _currentPortion, _selectedMealType);
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    l10n.addedProductToMeal(widget.product.name, _selectedMealType.displayName(context))),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: Text(l10n.add),
        ),
      ],
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
