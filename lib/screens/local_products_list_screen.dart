import 'package:flutter/material.dart';
import '../models/food_product.dart';
import '../services/product_service.dart';
import '../widgets/product_image.dart';
import 'create_local_product_screen.dart';
import 'product_detail_screen.dart';
import '../config/decorations.dart';
import '../config/custom_colors.dart';
import '../l10n/app_localizations.dart';

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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorLoadingProducts(e.toString()))),
      );
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

  Future<void> _viewProductDetails(FoodProduct product) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );

    // Reload if the product was edited (result will be null if just viewing)
    if (result == true) {
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brandGreen,
        foregroundColor: Colors.white,
        title: Text(l10n.myProducts),
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noCustomProductsYet,
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.tapPlusToAdd,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                          color: context.customColors.dangerColor,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.deleteProduct),
                              content: Text(
                                  l10n.deleteProductConfirmation(product.name)),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: context.customColors.dangerColor,
                                  ),
                                  child: Text(l10n.delete),
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
                                SnackBar(
                                    content: Text(l10n.productDeleted)),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                    content:
                                        Text(l10n.errorDeletingProduct(e.toString()))),
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
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ProductImage(
                                imageUrl: product.imageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorWidget: Builder(
                                  builder: (context) => Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.fastfood,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
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
                                  l10n.kcalPer100g(product.caloriesPer100g.toStringAsFixed(0)),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                                  decoration: AppShapes.greenBadge(context),
                                  child: Text(
                                    l10n.custom,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                            onTap: () => _viewProductDetails(product),
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
