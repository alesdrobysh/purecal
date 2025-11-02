import 'dart:io';
import 'package:flutter/material.dart';
import '../models/food_product.dart';
import '../services/product_service.dart';
import 'create_local_product_screen.dart';

class LocalProductsListScreen extends StatefulWidget {
  const LocalProductsListScreen({super.key});

  @override
  State<LocalProductsListScreen> createState() =>
      _LocalProductsListScreenState();
}

class _LocalProductsListScreenState extends State<LocalProductsListScreen> {
  final _productService = ProductService();
  List<FoodProduct> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _productService.getLocalProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    }
  }

  Future<void> _editProduct(FoodProduct product) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateLocalProductScreen(product: product),
      ),
    );

    if (result == true) {
      _loadProducts();
    }
  }

  Future<void> _createProduct() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateLocalProductScreen(),
      ),
    );

    if (result == true) {
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No custom products yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to create one',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Dismissible(
                        key: Key(product.localId.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Product'),
                              content: Text(
                                  'Are you sure you want to delete "${product.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await _productService
                                .deleteLocalProduct(product.localId!);
                            if (mounted) {
                              messenger.showSnackBar(
                                const SnackBar(
                                    content: Text('Product deleted')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Error deleting product: $e')),
                              );
                              _loadProducts();
                            }
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: product.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(product.imageUrl!),
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 56,
                                          height: 56,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                              Icons.image_not_supported),
                                        );
                                      },
                                    ),
                                  )
                                : Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.fastfood),
                                  ),
                            title: Text(
                              product.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product.brand != null) Text(product.brand!),
                                const SizedBox(height: 4),
                                Text(
                                  '${product.caloriesPer100g.toStringAsFixed(0)} kcal per 100g',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Custom',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                            onTap: () => _editProduct(product),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}
