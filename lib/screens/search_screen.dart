import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_product.dart';
import '../models/meal_type.dart';
import '../services/product_service.dart';
import '../services/diary_provider.dart';
import '../widgets/add_product_dialog.dart';
import '../widgets/frequent_product_card.dart';
import 'scanner_screen.dart';
import 'local_products_list_screen.dart';
import 'quick_add_screen.dart';
import '../widgets/custom_input_decoration.dart';
import '../config/decorations.dart';

class SearchScreen extends StatefulWidget {
  final MealType? preselectedMealType;

  const SearchScreen({super.key, this.preselectedMealType});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();

  List<FoodProduct> _searchResults = [];
  List<Map<String, dynamic>> _frequentProducts = [];
  bool _isSearching = false;
  String? _errorMessage;
  Timer? _debounceTimer;
  int _searchId = 0;

  @override
  void initState() {
    super.initState();
    _loadFrequentProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFrequentProducts() async {
    final provider = Provider.of<DiaryProvider>(context, listen: false);
    final products = await provider.getFrequentProducts(limit: 10);

    if (mounted) {
      setState(() {
        _frequentProducts = products;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchId++;
      _performSearch(query, _searchId);
    });
  }

  Future<void> _performSearch(String query, int searchId) async {
    try {
      final results = await _productService.searchProducts(query);

      if (mounted && searchId == _searchId) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
          if (results.isEmpty) {
            _errorMessage = 'No products found for "$query"';
          }
        });
      }
    } catch (e) {
      if (mounted && searchId == _searchId) {
        setState(() {
          _isSearching = false;
          _errorMessage = 'Error searching: ${e.toString()}';
          _searchResults = [];
        });
      }
    }
  }

  void _showAddDialog(FoodProduct product) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        product: product,
        mealType: widget.preselectedMealType,
      ),
    );

    // If product was added, pop back to home screen
    if (result == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _openScanner() async {
    final navigator = Navigator.of(context);
    final result = await navigator.push(
      MaterialPageRoute(
        builder: (context) =>
            ScannerScreen(mealType: widget.preselectedMealType),
      ),
    );

    // If product was added from scanner, pop back to home screen
    if (result == true && mounted) {
      navigator.pop();
    }
  }

  Future<void> _onFrequentProductTap(String barcode) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final product = await _productService.getProductByBarcode(barcode);

      if (mounted) {
        setState(() {
          _isSearching = false;
        });

        if (product != null) {
          _showAddDialog(product);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product not found'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading product: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _openMyProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocalProductsListScreen(),
      ),
    );
  }

  void _openQuickAdd() async {
    final navigator = Navigator.of(context);
    final result = await navigator.push(
      MaterialPageRoute(
        builder: (context) =>
            QuickAddScreen(mealType: widget.preselectedMealType),
      ),
    );

    if (result == true && mounted) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.preselectedMealType != null
            ? 'Add to ${widget.preselectedMealType!.displayName}'
            : 'Search Products'),
        backgroundColor: AppColors.green,
        actions: [
          IconButton(
            onPressed: _openMyProducts,
            icon: const Icon(Icons.inventory_2),
            tooltip: 'My Products',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textAlignVertical: TextAlignVertical.center,
              decoration: customInputDecoration(context).copyWith(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: _openScanner,
                  icon: const Icon(Icons.barcode_reader),
                  tooltip: 'Scan barcode',
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openQuickAdd,
        icon: const Icon(Icons.bolt),
        label: const Text('Quick Add'),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_searchController.text.trim().isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_frequentProducts.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.history, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Frequently Used',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 110,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _frequentProducts.length,
                itemBuilder: (context, index) {
                  final product = _frequentProducts[index];
                  return FrequentProductCard(
                    barcode: product['barcode'] as String,
                    productName: product['product_name'] as String,
                    usageCount: product['total_count'] as int,
                    imageUrl: product['image_url'] as String?,
                    onTap: () => _onFrequentProductTap(
                      product['barcode'] as String,
                    ),
                  );
                },
              ),
            ),
            const Divider(indent: 16, endIndent: 16, thickness: 0.5),
          ],
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Search for products by name',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try "yogurt", "bread", "apple"...',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(FoodProduct product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAddDialog(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (product.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.isLocal
                      ? Image.file(
                          File(product.imageUrl!),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                      : Image.network(
                          product.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        ),
                )
              else
                _buildPlaceholderImage(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.isLocal) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: AppShapes.greenBadge(context),
                            child: Text(
                              'Custom',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.badgeText(context),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (product.brand != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.brand!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '${product.caloriesPer100g.toStringAsFixed(0)} kcal / 100g',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'P: ${product.proteinsPer100g.toStringAsFixed(1)}g • '
                      'F: ${product.fatPer100g.toStringAsFixed(1)}g • '
                      'C: ${product.carbsPer100g.toStringAsFixed(1)}g',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.add_circle_outline, color: AppColors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.fastfood, color: Colors.grey[500]),
    );
  }
}
