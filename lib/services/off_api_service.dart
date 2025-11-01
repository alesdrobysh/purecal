import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_product.dart';

class OFFApiService {
  static const String baseUrl = 'https://world.openfoodfacts.org/api/v2';
  static const String userAgent = 'FoodieApp/0.1.0 (Development)';

  Future<FoodProduct?> getProductByBarcode(String barcode) async {
    try {
      final url = Uri.parse('$baseUrl/product/$barcode.json');
      final response = await http.get(
        url,
        headers: {'User-Agent': userAgent},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 1) {
          return FoodProduct.fromJson(data);
        } else {
          return null;
        }
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  Future<bool> isProductAvailable(String barcode) async {
    try {
      final product = await getProductByBarcode(barcode);
      return product != null;
    } catch (e) {
      return false;
    }
  }

  Future<List<FoodProduct>> searchProducts(String query, {int page = 1, int pageSize = 20}) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final url = Uri.parse(
        'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&json=1&page=$page&page_size=$pageSize',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': userAgent},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List?;

        if (products == null || products.isEmpty) {
          return [];
        }

        return products
            .map((productData) {
              try {
                // Wrap in the expected format for FoodProduct.fromJson
                return FoodProduct.fromJson({
                  'code': productData['code'] ?? productData['_id'],
                  'product': productData,
                });
              } catch (e) {
                return null;
              }
            })
            .whereType<FoodProduct>()
            .toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }
}
