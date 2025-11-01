import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_product.dart';
import '../models/meal_type.dart';
import '../services/diary_provider.dart';

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
    final nutrition = widget.product.calculateNutrition(_currentPortion);

    return AlertDialog(
      title: const Text('Add to Diary'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.product.imageUrl != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.product.imageUrl!,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.fastfood, size: 60),
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
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Nutrition per 100g:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildNutritionRow(
                'Calories', '${widget.product.caloriesPer100g} kcal'),
            _buildNutritionRow(
                'Protein', '${widget.product.proteinsPer100g}g'),
            _buildNutritionRow('Fat', '${widget.product.fatPer100g}g'),
            _buildNutritionRow('Carbs', '${widget.product.carbsPer100g}g'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Meal Type:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<MealType>(
              initialValue: _selectedMealType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: MealType.values.map((mealType) {
                return DropdownMenuItem(
                  value: mealType,
                  child: Row(
                    children: [
                      Text(mealType.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(mealType.displayName),
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
              decoration: const InputDecoration(
                labelText: 'Portion Size',
                suffixText: 'grams',
                border: OutlineInputBorder(),
              ),
              onChanged: _updatePortion,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your portion:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildNutritionRow(
                      'Calories', '${nutrition.calories.toStringAsFixed(1)} kcal'),
                  _buildNutritionRow(
                      'Protein', '${nutrition.proteins.toStringAsFixed(1)}g'),
                  _buildNutritionRow(
                      'Fat', '${nutrition.fat.toStringAsFixed(1)}g'),
                  _buildNutritionRow(
                      'Carbs', '${nutrition.carbs.toStringAsFixed(1)}g'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final provider = Provider.of<DiaryProvider>(context, listen: false);
            provider.addProductEntry(widget.product, _currentPortion, _selectedMealType);
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${widget.product.name} to ${_selectedMealType.displayName}'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add'),
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
