import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'database_service.dart';
import '../models/food_product.dart';

enum ConflictResolution {
  skip,
  replace,
  keepAll,
  replaceAll,
}

class ImportResult {
  final int imported;
  final int skipped;
  final int errors;
  final List<String> errorMessages;

  ImportResult({
    required this.imported,
    required this.skipped,
    required this.errors,
    this.errorMessages = const [],
  });
}

class ProductConflict {
  final FoodProduct existingProduct;
  final FoodProduct importedProduct;

  ProductConflict({
    required this.existingProduct,
    required this.importedProduct,
  });
}

class ProductImportService {
  final DatabaseService _db = DatabaseService();

  /// Import products from a JSON file
  /// Returns ImportResult with counts and error messages
  /// onConflict callback is called for each duplicate barcode (if user hasn't chosen Keep All / Replace All)
  /// onProgress callback is called for each product processed with (currentIndex, totalProducts)
  Future<ImportResult> importProductsFromJSON(
    String filePath, {
    required Future<ConflictResolution> Function(ProductConflict) onConflict,
    Function(int currentIndex, int totalProducts)? onProgress,
  }) async {
    int imported = 0;
    int skipped = 0;
    int errors = 0;
    final List<String> errorMessages = [];

    ConflictResolution? batchResolution;

    try {
      // Read and parse JSON file
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      final jsonString = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // Validate JSON structure
      if (!_validateImportData(data)) {
        throw Exception('Invalid JSON structure');
      }

      final List<dynamic> productsData = data['products'] as List<dynamic>;
      final appDir = await getApplicationDocumentsDirectory();
      final productImagesDir = Directory('${appDir.path}/product_images');

      // Ensure product_images directory exists
      if (!await productImagesDir.exists()) {
        await productImagesDir.create(recursive: true);
      }

      // Get all existing local products for conflict detection
      final existingProducts = await _db.getAllLocalProducts();
      final Map<String, FoodProduct> existingByBarcode = {
        for (var p in existingProducts)
          if (p.barcode.isNotEmpty) p.barcode: p
      };

      // Process each product
      for (int i = 0; i < productsData.length; i++) {
        // Report progress
        onProgress?.call(i + 1, productsData.length);

        try {
          final productData = productsData[i] as Map<String, dynamic>;
          final barcode = productData['barcode']?.toString() ?? '';

          // Create FoodProduct from imported data
          final importedProduct = _createProductFromImportData(productData);

          // Check for conflicts (duplicate barcode)
          final existingProduct =
              barcode.isNotEmpty ? existingByBarcode[barcode] : null;

          if (existingProduct != null) {
            // Handle conflict
            ConflictResolution resolution;

            if (batchResolution != null) {
              resolution = batchResolution;
            } else {
              final conflict = ProductConflict(
                existingProduct: existingProduct,
                importedProduct: importedProduct,
              );
              resolution = await onConflict(conflict);

              // If user chose Keep All or Replace All, remember for subsequent conflicts
              if (resolution == ConflictResolution.keepAll ||
                  resolution == ConflictResolution.replaceAll) {
                batchResolution = resolution;
              }
            }

            // Apply resolution
            switch (resolution) {
              case ConflictResolution.skip:
              case ConflictResolution.keepAll:
                skipped++;
                continue;

              case ConflictResolution.replace:
              case ConflictResolution.replaceAll:
                // Delete old product image if different
                if (existingProduct.imageUrl != null &&
                    existingProduct.imageUrl!.isNotEmpty &&
                    !existingProduct.imageUrl!.startsWith('http')) {
                  try {
                    final oldImagePath =
                        '${appDir.path}/${existingProduct.imageUrl}';
                    final oldImageFile = File(oldImagePath);
                    if (await oldImageFile.exists()) {
                      await oldImageFile.delete();
                    }
                  } catch (e) {
                    // Continue even if old image deletion fails
                  }
                }

                // Update existing product
                final updatedProduct = FoodProduct(
                  barcode: importedProduct.barcode,
                  name: importedProduct.name,
                  brand: importedProduct.brand,
                  caloriesPer100g: importedProduct.caloriesPer100g,
                  proteinsPer100g: importedProduct.proteinsPer100g,
                  fatPer100g: importedProduct.fatPer100g,
                  carbsPer100g: importedProduct.carbsPer100g,
                  servingSize: importedProduct.servingSize,
                  imageUrl: await _saveImageFromBase64(
                    productData['image_base64'],
                    productData['image_filename'],
                    appDir,
                  ),
                  isLocal: true,
                  localId: existingProduct.localId,
                  notes: importedProduct.notes,
                  sourceType: importedProduct.sourceType ?? 'local',
                  createdAt: existingProduct.createdAt,
                  updatedAt: DateTime.now(),
                );

                await _db.updateLocalProduct(updatedProduct);

                // Update the in-memory map to reflect the latest state
                if (barcode.isNotEmpty) {
                  existingByBarcode[barcode] = updatedProduct;
                }

                imported++;
                break;
            }
          } else {
            // No conflict, import new product
            final imagePath = await _saveImageFromBase64(
              productData['image_base64'],
              productData['image_filename'],
              appDir,
            );

            final newProduct = FoodProduct(
              barcode: importedProduct.barcode,
              name: importedProduct.name,
              brand: importedProduct.brand,
              caloriesPer100g: importedProduct.caloriesPer100g,
              proteinsPer100g: importedProduct.proteinsPer100g,
              fatPer100g: importedProduct.fatPer100g,
              carbsPer100g: importedProduct.carbsPer100g,
              servingSize: importedProduct.servingSize,
              imageUrl: imagePath,
              isLocal: true,
              notes: importedProduct.notes,
              sourceType: importedProduct.sourceType ?? 'local',
              createdAt: importedProduct.createdAt ?? DateTime.now(),
              updatedAt: DateTime.now(),
            );

            final insertedId = await _db.insertLocalProduct(newProduct);

            // Update the in-memory map to reflect the newly inserted product
            if (barcode.isNotEmpty) {
              existingByBarcode[barcode] = FoodProduct(
                barcode: newProduct.barcode,
                name: newProduct.name,
                brand: newProduct.brand,
                caloriesPer100g: newProduct.caloriesPer100g,
                proteinsPer100g: newProduct.proteinsPer100g,
                fatPer100g: newProduct.fatPer100g,
                carbsPer100g: newProduct.carbsPer100g,
                servingSize: newProduct.servingSize,
                imageUrl: newProduct.imageUrl,
                isLocal: true,
                localId: insertedId,
                notes: newProduct.notes,
                sourceType: newProduct.sourceType,
                createdAt: newProduct.createdAt,
                updatedAt: newProduct.updatedAt,
              );
            }

            imported++;
          }
        } catch (e) {
          errors++;
          errorMessages.add('Product ${i + 1}: ${e.toString()}');
        }
      }
    } catch (e) {
      errors++;
      errorMessages.add('Import failed: ${e.toString()}');
    }

    return ImportResult(
      imported: imported,
      skipped: skipped,
      errors: errors,
      errorMessages: errorMessages,
    );
  }

  /// Validate the structure of imported JSON data
  bool _validateImportData(Map<String, dynamic> data) {
    if (!data.containsKey('version') ||
        !data.containsKey('exportDate') ||
        !data.containsKey('productCount') ||
        !data.containsKey('products')) {
      return false;
    }

    if (data['products'] is! List) {
      return false;
    }

    return true;
  }

  /// Safely parse a numeric value to double, handling both num and String types
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Create a FoodProduct instance from imported data
  FoodProduct _createProductFromImportData(Map<String, dynamic> data) {
    return FoodProduct(
      barcode: data['barcode']?.toString() ?? '',
      name: data['product_name']?.toString() ?? 'Unknown Product',
      brand: data['brand']?.toString(),
      caloriesPer100g: _parseDouble(data['calories_per_100g']),
      proteinsPer100g: _parseDouble(data['proteins_per_100g']),
      fatPer100g: _parseDouble(data['fat_per_100g']),
      carbsPer100g: _parseDouble(data['carbs_per_100g']),
      servingSize: data['serving_size'] != null
          ? double.tryParse(data['serving_size'].toString())
          : null,
      notes: data['notes']?.toString(),
      sourceType: data['source_type']?.toString(),
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString())
          : null,
      updatedAt: data['updated_at'] != null
          ? DateTime.tryParse(data['updated_at'].toString())
          : null,
      isLocal: true,
    );
  }

  /// Save base64-encoded image to product_images directory
  /// Returns the relative path (e.g., "product_images/product_123456.jpg")
  Future<String?> _saveImageFromBase64(
    String? base64Image,
    String? originalFilename,
    Directory appDir,
  ) async {
    if (base64Image == null || base64Image.isEmpty) {
      return null;
    }

    try {
      final imageBytes = base64Decode(base64Image);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = originalFilename?.split('.').last ?? 'jpg';
      final filename = 'product_$timestamp.$extension';
      final filePath = '${appDir.path}/product_images/$filename';

      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      return 'product_images/$filename';
    } catch (e) {
      debugPrint('Warning: Could not save image: $e');
      return null;
    }
  }
}
