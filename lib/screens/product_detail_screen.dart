import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/food_product.dart';
import '../models/meal_type.dart';
import '../services/diary_provider.dart';
import '../widgets/custom_input_decoration.dart';
import '../widgets/product_image.dart';
import '../config/decorations.dart';
import 'create_local_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final FoodProduct product;
  final MealType? mealType;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.mealType,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
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

  void _editProduct() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateLocalProductScreen(
          sourceOffProduct: widget.product.isLocal ? null : widget.product,
          product: widget.product.isLocal ? widget.product : null,
        ),
      ),
    );

    if (result == true && mounted) {
      // Product was saved, go back to previous screen
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nutrition = widget.product.calculateNutrition(_currentPortion);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(l10n.productDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l10n.editProduct,
            onPressed: _editProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            if (widget.product.imageUrl != null)
              Center(
                child: Container(
                  width: double.infinity,
                  height: 250,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: ProductImage(
                    imageUrl: widget.product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Brand
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.product.brand != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.product.brand!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (widget.product.isLocal)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.custom,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Barcode
                  if (widget.product.barcode.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.barcode}: ${widget.product.barcode}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],

                  // Source Type
                  if (widget.product.sourceType == 'edited_off') ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.basedOnOffProduct,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  // Notes
                  if (widget.product.notes != null &&
                      widget.product.notes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.notes,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.product.notes!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Nutrition per 100g
                  Text(
                    l10n.nutritionPer100g,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionRow(l10n.calories,
                      '${widget.product.caloriesPer100g} ${l10n.kcal}'),
                  _buildNutritionRow(l10n.protein,
                      '${widget.product.proteinsPer100g}${l10n.grams}'),
                  _buildNutritionRow(
                      l10n.fat, '${widget.product.fatPer100g}${l10n.grams}'),
                  _buildNutritionRow(l10n.carbs,
                      '${widget.product.carbsPer100g}${l10n.grams}'),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Meal Type Selection
                  Text(
                    l10n.mealType,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<MealType>(
                    value: _selectedMealType,
                    decoration: customInputDecoration(context).copyWith(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
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

                  // Portion Size Input
                  TextField(
                    controller: _portionController,
                    keyboardType: TextInputType.number,
                    decoration: customInputDecoration(context).copyWith(
                      labelText: l10n.portionSize,
                      suffixText: l10n.gramsUnit,
                    ),
                    onChanged: _updatePortion,
                  ),

                  const SizedBox(height: 24),

                  // Your Portion Summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: AppShapes.greenInfoBox(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.yourPortion,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildNutritionRow(l10n.calories,
                            '${nutrition.calories.toStringAsFixed(1)} ${l10n.kcal}'),
                        _buildNutritionRow(l10n.protein,
                            '${nutrition.proteins.toStringAsFixed(1)}${l10n.grams}'),
                        _buildNutritionRow(l10n.fat,
                            '${nutrition.fat.toStringAsFixed(1)}${l10n.grams}'),
                        _buildNutritionRow(l10n.carbs,
                            '${nutrition.carbs.toStringAsFixed(1)}${l10n.grams}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Add to Diary Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final provider =
                            Provider.of<DiaryProvider>(context, listen: false);
                        provider.addProductEntry(
                            widget.product, _currentPortion, _selectedMealType);
                        Navigator.of(context).pop(true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.addedProductToMeal(
                                widget.product.name,
                                _selectedMealType.displayName(context))),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: Text(
                        l10n.addToDiary,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
