import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'database_service.dart';
import '../models/food_product.dart';
import '../exceptions/export_exceptions.dart';

class ProductExportService {
  /// Export all local products to JSON with base64-encoded images
  Future<void> exportProductsToJSON() async {
    // Get all non-deleted local products
    final products = await DatabaseService().getAllLocalProducts();

    if (products.isEmpty) {
      throw NoProductsToExportException();
    }

    // Convert products to JSON-serializable format with base64 images
    final productsData = await _convertProductsToExportFormat(products);

    // Create export metadata
    final exportData = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'productCount': products.length,
      'products': productsData,
    };

    // Convert to JSON string
    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

    final file = await _saveToTempFile(jsonString);
    final params = ShareParams(
      text: 'PureCal Products Export',
      files: [XFile(file.path)],
    );

    await SharePlus.instance.share(params);
  }

  /// Convert products to export format with base64-encoded images
  Future<List<Map<String, dynamic>>> _convertProductsToExportFormat(
      List<FoodProduct> products) async {
    final appDir = await getApplicationDocumentsDirectory();
    final List<Map<String, dynamic>> productsData = [];

    for (final product in products) {
      final productData = {
        'barcode': product.barcode,
        'product_name': product.name,
        'brand': product.brand,
        'calories_per_100g': product.caloriesPer100g,
        'proteins_per_100g': product.proteinsPer100g,
        'fat_per_100g': product.fatPer100g,
        'carbs_per_100g': product.carbsPer100g,
        'serving_size': product.servingSize,
        'notes': product.notes,
        'source_type': product.sourceType,
        'created_at': product.createdAt?.toIso8601String(),
        'updated_at': product.updatedAt?.toIso8601String(),
      };

      // Handle image if present
      if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
        try {
          // Check if it's a local file path (not a URL)
          if (!product.imageUrl!.startsWith('http')) {
            final imagePath = '${appDir.path}/${product.imageUrl}';
            final imageFile = File(imagePath);

            if (await imageFile.exists()) {
              final imageBytes = await imageFile.readAsBytes();
              final base64Image = base64Encode(imageBytes);
              productData['image_base64'] = base64Image;
              productData['image_filename'] = product.imageUrl!.split('/').last;
            }
          }
        } catch (e) {
          // If image cannot be read, skip it but continue with product export
          debugPrint(
              'Warning: Could not read image for product ${product.name}: $e');
        }
      }

      productsData.add(productData);
    }

    return productsData;
  }

  /// Save JSON content to a temporary file
  Future<File> _saveToTempFile(String jsonContent) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
    final fileName = 'purecal_products_$timestamp.json';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsString(jsonContent);

    return file;
  }
}
