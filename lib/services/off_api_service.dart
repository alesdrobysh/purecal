import 'package:openfoodfacts/openfoodfacts.dart';
import '../models/food_product.dart';

class OFFApiService {
  static const String userAgent = 'FoodieApp/0.1.0 (Development)';

  static void initialize() {
    OpenFoodAPIConfiguration.userAgent = UserAgent(name: userAgent);
  }

  Future<FoodProduct?> getProductByBarcode(String barcode) async {
    try {
      final ProductResultV3 result = await OpenFoodAPIClient.getProductV3(
        ProductQueryConfiguration(
          barcode,
          version: ProductQueryVersion.v3,
        ),
      );

      if (result.status == ProductResultV3.statusSuccess) {
        return FoodProduct.fromOFF(result.product!);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  Future<List<FoodProduct>> searchProducts(String query,
      {int page = 1, int pageSize = 20}) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final SearchResult result = await OpenFoodAPIClient.searchProducts(
        const User(userId: '', password: ''),
        ProductSearchQueryConfiguration(
          parametersList: [
            SearchTerms(terms: [query]),
            PageNumber(page: page),
            PageSize(size: pageSize),
          ],
          version: ProductQueryVersion.v3,
        ),
      );

      if (result.products != null) {
        return result.products!
            .map((product) => FoodProduct.fromOFF(product))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }
}
