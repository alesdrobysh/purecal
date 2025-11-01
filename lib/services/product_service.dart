import '../models/food_product.dart';
import 'database_service.dart';
import 'off_api_service.dart';

/// Unified product service that searches local products first, then falls back to OFF API
class ProductService {
  final DatabaseService _dbService;
  final OFFApiService _offApiService;

  ProductService({
    DatabaseService? dbService,
    OFFApiService? offApiService,
  })  : _dbService = dbService ?? DatabaseService(),
        _offApiService = offApiService ?? OFFApiService();

  /// Get product by barcode - checks local DB first, then OFF API
  Future<FoodProduct?> getProductByBarcode(String barcode) async {
    if (barcode.isEmpty) return null;

    try {
      // Check local products first
      final localProduct = await _dbService.getLocalProductByBarcode(barcode);
      if (localProduct != null) {
        return localProduct;
      }

      // Fall back to OFF API
      return await _offApiService.getProductByBarcode(barcode);
    } catch (e) {
      // If OFF API fails, return null
      return null;
    }
  }

  /// Search products - searches local products only
  /// OFF free text search is way too slow
  Future<List<FoodProduct>> searchProducts(
    String query, {
    int page = 1,
    int pageSize = 20,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      // Search local products
      final localProducts = await _dbService.searchLocalProducts(query);

      return localProducts;
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  /// Get all local products only
  Future<List<FoodProduct>> getLocalProducts(
      {bool includeDeleted = false}) async {
    return await _dbService.getAllLocalProducts(includeDeleted: includeDeleted);
  }

  /// Create a new local product
  Future<int> createLocalProduct(FoodProduct product) async {
    return await _dbService.insertLocalProduct(product);
  }

  /// Update an existing local product
  Future<int> updateLocalProduct(FoodProduct product) async {
    return await _dbService.updateLocalProduct(product);
  }

  /// Soft delete a local product
  Future<int> deleteLocalProduct(int id) async {
    return await _dbService.softDeleteLocalProduct(id);
  }

  /// Get local product by ID
  Future<FoodProduct?> getLocalProductById(int id) async {
    return await _dbService.getLocalProductById(id);
  }
}
