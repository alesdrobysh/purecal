import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/food_product.dart';

class USDAApiService {
  static const String baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  // API key is loaded at compile time from .env.json
  // To build with API key: flutter run --dart-define-from-file=.env.json
  static const String _apiKey = String.fromEnvironment(
    'USDA_API_KEY',
    defaultValue: 'DEMO_KEY',
  );

  USDAApiService();

  /// Search for foods in the USDA database
  ///
  /// [query] - search term
  /// [page] - page number (1-indexed)
  /// [pageSize] - number of results per page
  /// [dataType] - filter by data type (e.g., 'SR Legacy' for Standard Reference)
  Future<List<FoodProduct>> searchFoods(
    String query, {
    int page = 1,
    int pageSize = 20,
    List<String>? dataType,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final queryParams = {
        'query': query,
        'pageSize': pageSize.toString(),
        'pageNumber': (page - 1).toString(), // API uses 0-indexed pages
        'api_key': _apiKey,
        if (dataType != null && dataType.isNotEmpty)
          'dataType': dataType.join(','),
      };

      final uri = Uri.parse('$baseUrl/foods/search')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final foods = data['foods'] as List<dynamic>?;

        if (foods != null) {
          return foods
              .map((food) => _parseUSDAFood(food))
              .where((product) => product != null)
              .cast<FoodProduct>()
              .toList();
        }
      } else if (response.statusCode == 403) {
        throw Exception(
            'USDA API access denied. You may need to set an API key or have exceeded rate limits.');
      } else if (response.statusCode == 404) {
        throw Exception(
            'USDA API endpoint not found. URL: $uri\nResponse: ${response.body}');
      } else {
        throw Exception(
            'USDA API error: ${response.statusCode}\nURL: $uri\nResponse: ${response.body}');
      }

      return [];
    } catch (e) {
      debugPrint('Error searching USDA: $e');
      return [];
    }
  }

  /// Get detailed information about a specific food by FDC ID
  Future<FoodProduct?> getFoodById(String fdcId) async {
    try {
      final queryParams = {
        'api_key': _apiKey,
      };

      final uri = Uri.parse('$baseUrl/food/$fdcId')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseUSDAFood(data);
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching USDA food by ID: $e');
      return null;
    }
  }

  /// Parse USDA food data into FoodProduct model
  FoodProduct? _parseUSDAFood(Map<String, dynamic> food) {
    try {
      final fdcId = food['fdcId']?.toString() ?? '';
      final description = food['description']?.toString() ?? 'Unknown';
      final brandOwner = food['brandOwner']?.toString();
      final nutrients = food['foodNutrients'] as List<dynamic>?;

      if (nutrients == null) {
        return null;
      }

      // Extract nutrition data per 100g
      double? calories;
      double? proteins;
      double? fat;
      double? carbs;

      for (var nutrient in nutrients) {
        final nutrientNumber = nutrient['nutrientNumber']?.toString();
        final value = nutrient['value'];

        if (value == null) continue;

        // USDA nutrient numbers:
        // 208 = Energy (kcal)
        // 203 = Protein
        // 204 = Total lipid (fat)
        // 205 = Carbohydrate, by difference
        switch (nutrientNumber) {
          case '208':
            calories = value.toDouble();
            break;
          case '203':
            proteins = value.toDouble();
            break;
          case '204':
            fat = value.toDouble();
            break;
          case '205':
            carbs = value.toDouble();
            break;
        }
      }

      if (calories == null ||
          proteins == null ||
          fat == null ||
          carbs == null) {
        return null;
      }

      return FoodProduct(
        barcode: fdcId, // Use FDC ID as barcode
        name: description,
        brand: brandOwner,
        caloriesPer100g: calories,
        proteinsPer100g: proteins,
        fatPer100g: fat,
        carbsPer100g: carbs,
        servingSize: 100.0, // USDA data is typically per 100g
        sourceType: 'usda',
      );
    } catch (e) {
      debugPrint('Error parsing USDA food: $e');
      return null;
    }
  }
}
