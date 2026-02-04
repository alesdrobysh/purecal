import 'package:flutter/foundation.dart';
import '../models/food_product.dart';
import 'database_service.dart';
import 'off_api_service.dart';
import 'usda_api_service.dart';

/// Unified product service that searches local products, OFF API, and USDA database
class ProductService {
  static const List<String> _defaultUsdaDataType = ['Foundation'];

  final DatabaseService _dbService;
  final OFFApiService _offApiService;
  final USDAApiService _usdaApiService;

  ProductService({
    DatabaseService? dbService,
    OFFApiService? offApiService,
    USDAApiService? usdaApiService,
  })  : _dbService = dbService ?? DatabaseService(),
        _offApiService = offApiService ?? OFFApiService(),
        _usdaApiService = usdaApiService ?? USDAApiService();

  /// Get product by barcode - checks local DB first, then OFF API
  Future<FoodProduct?> getProductByBarcode(String barcode) async {
    if (barcode.isEmpty) return null;

    // Check local products first
    final localProduct = await _dbService.getLocalProductByBarcode(barcode);
    if (localProduct != null) {
      return localProduct;
    }

    // Fall back to OFF API (exceptions propagate to caller)
    return await _offApiService.getProductByBarcode(barcode);
  }

  /// Search products - searches local, OFF, and USDA databases
  /// If [onPartialResult] callback is provided, results are delivered progressively as each source completes
  Future<List<FoodProduct>> searchProducts(
    String query, {
    int page = 1,
    int pageSize = 20,
    void Function(List<FoodProduct> results, DataSource source)? onPartialResult,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final localFuture = _dbService.searchLocalProducts(query).catchError((e) {
      debugPrint('Local search error: $e');
      return <FoodProduct>[];
    });

    final offFuture = _offApiService
        .searchProducts(query, page: page, pageSize: pageSize)
        .catchError((e) {
      debugPrint('OpenFoodFacts search error: $e');
      return <FoodProduct>[];
    });

    final usdaFuture = _usdaApiService
        .searchFoods(query,
            page: page, pageSize: pageSize, dataType: _defaultUsdaDataType)
        .catchError((e) {
      debugPrint('USDA search error: $e');
      return <FoodProduct>[];
    });

    if (onPartialResult != null) {
      localFuture.then((results) => onPartialResult(results, DataSource.local));
      offFuture
          .then((results) => onPartialResult(results, DataSource.openFoodFacts));
      usdaFuture.then((results) => onPartialResult(results, DataSource.usda));
    }

    final combined = await Future.wait([localFuture, offFuture, usdaFuture]);
    final merged = [...combined[0], ...combined[1], ...combined[2]];
    return merged.take(pageSize).toList();
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
