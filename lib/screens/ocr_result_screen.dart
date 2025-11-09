import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../models/nutrition_extraction.dart';
import '../models/food_product.dart';
import '../models/meal_type.dart';
import 'create_local_product_screen.dart';

/// Screen for reviewing and editing OCR extraction results
class OcrResultScreen extends StatefulWidget {
  final NutritionExtraction extraction;
  final String imagePath;
  final MealType? mealType;

  const OcrResultScreen({
    super.key,
    required this.extraction,
    required this.imagePath,
    this.mealType,
  });

  @override
  State<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends State<OcrResultScreen> {
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbsController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with extracted values
    _caloriesController = TextEditingController(
      text: widget.extraction.calories?.toStringAsFixed(1) ?? '',
    );
    _proteinController = TextEditingController(
      text: widget.extraction.protein?.toStringAsFixed(1) ?? '',
    );
    _fatController = TextEditingController(
      text: widget.extraction.fat?.toStringAsFixed(1) ?? '',
    );
    _carbsController = TextEditingController(
      text: widget.extraction.carbs?.toStringAsFixed(1) ?? '',
    );
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  /// Navigate to create product screen with pre-filled nutrition data
  void _createProduct() {
    final calories = double.tryParse(_caloriesController.text) ?? 0;
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;

    // Create a food product with the extracted/edited values
    final product = FoodProduct(
      barcode: 'ocr_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Scanned Product',
      brand: null,
      caloriesPer100g: calories,
      proteinsPer100g: protein,
      fatPer100g: fat,
      carbsPer100g: carbs,
      servingSize: null,
      imageUrl: null,
      isLocal: true,
      notes: 'Created from OCR scan',
    );

    // Navigate to create local product screen for final details
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CreateLocalProductScreen(
          product: product,
          imagePath: widget.imagePath,
          mealType: widget.mealType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Nutrition Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overall confidence indicator
            _buildConfidenceCard(widget.extraction.confidenceLevel),

            const SizedBox(height: 24),

            // Captured image preview
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Image.file(
                    File(widget.imagePath),
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Scanned nutrition label',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Extracted Nutrition (per 100g)',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Please verify and correct if needed',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            // Editable nutrition fields
            _buildNutritionField(
              label: 'Calories (kcal)',
              controller: _caloriesController,
              confidence: widget.extraction.caloriesConfidence,
              icon: Icons.local_fire_department,
            ),
            const SizedBox(height: 16),

            _buildNutritionField(
              label: 'Protein (g)',
              controller: _proteinController,
              confidence: widget.extraction.proteinConfidence,
              icon: Icons.fitness_center,
            ),
            const SizedBox(height: 16),

            _buildNutritionField(
              label: 'Fat (g)',
              controller: _fatController,
              confidence: widget.extraction.fatConfidence,
              icon: Icons.water_drop,
            ),
            const SizedBox(height: 16),

            _buildNutritionField(
              label: 'Carbohydrates (g)',
              controller: _carbsController,
              confidence: widget.extraction.carbsConfidence,
              icon: Icons.bakery_dining,
            ),

            const SizedBox(height: 24),

            // Missing fields warning
            if (!widget.extraction.isComplete)
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Missing fields: ${widget.extraction.missingFields.join(", ")}',
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Action buttons
            FilledButton.icon(
              onPressed: _createProduct,
              icon: const Icon(Icons.add_circle),
              label: const Text('Create Product'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceCard(ConfidenceLevel level) {
    final theme = Theme.of(context);
    Color cardColor;
    Color textColor;

    switch (level) {
      case ConfidenceLevel.high:
        cardColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        break;
      case ConfidenceLevel.medium:
        cardColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        break;
      case ConfidenceLevel.low:
        cardColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        break;
    }

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              level.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(widget.extraction.overallConfidence * 100).toStringAsFixed(0)}% overall confidence',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionField({
    required String label,
    required TextEditingController controller,
    required double confidence,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    // Determine confidence color
    Color confidenceColor;
    if (confidence >= 0.9) {
      confidenceColor = Colors.green;
    } else if (confidence >= 0.7) {
      confidenceColor = Colors.orange;
    } else {
      confidenceColor = Colors.red;
    }

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Confidence indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: confidenceColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(confidence * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: confidenceColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
