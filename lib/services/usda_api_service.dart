import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_product.dart';

class USDAApiService {
  static const String baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  // API key is optional - the API allows limited requests without it
  // Users can set their own API key by getting one from https://fdc.nal.usda.gov/api-key-signup.html
  String? _apiKey;

  USDAApiService({String? apiKey}) : _apiKey = apiKey;

  void setApiKey(String? apiKey) {
    _apiKey = apiKey;
  }

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
        if (_apiKey != null) 'api_key': _apiKey!,
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
      } else {
        throw Exception('USDA API error: ${response.statusCode}');
      }

      return [];
    } catch (e) {
      // Return empty list instead of throwing to allow graceful degradation
      print('Error searching USDA: $e');
      return [];
    }
  }

  /// Get detailed information about a specific food by FDC ID
  Future<FoodProduct?> getFoodById(String fdcId) async {
    try {
      final queryParams = {
        if (_apiKey != null) 'api_key': _apiKey!,
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
      print('Error fetching USDA food by ID: $e');
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
      double calories = 0;
      double proteins = 0;
      double fat = 0;
      double carbs = 0;

      for (var nutrient in nutrients) {
        final nutrientNumber = nutrient['nutrientNumber']?.toString();
        final nutrientName = nutrient['nutrientName']?.toString() ?? '';
        final value = (nutrient['value'] ?? 0).toDouble();

        // USDA nutrient numbers:
        // 208 = Energy (kcal)
        // 203 = Protein
        // 204 = Total lipid (fat)
        // 205 = Carbohydrate, by difference
        switch (nutrientNumber) {
          case '208':
            calories = value;
            break;
          case '203':
            proteins = value;
            break;
          case '204':
            fat = value;
            break;
          case '205':
            carbs = value;
            break;
        }
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
      print('Error parsing USDA food: $e');
      return null;
    }
  }
}
