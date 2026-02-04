import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import '../l10n/app_localizations.dart';
import '../models/meal_type.dart';
import '../services/product_service.dart';
import 'product_detail_screen.dart';
import 'create_local_product_screen.dart';
import '../widgets/branded_app_bar.dart';

class ScannerScreen extends StatefulWidget {
  final MealType? mealType;

  const ScannerScreen({super.key, this.mealType});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ProductService _productService = ProductService();
  bool _isScannerActive = true;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleBarcode(Code result) async {
    if (!result.isValid) return;

    final String? code = result.text;
    if (code == null || code.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isScannerActive = false;
    });

    try {
      final product = await _productService.getProductByBarcode(code);

      if (!mounted) return;

      if (product != null) {
        final navigator = Navigator.of(context);
        final result = await navigator.push<bool>(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: product,
              mealType: widget.mealType,
            ),
          ),
        );

        if (!mounted) return;

        // If product was added, return true to parent screen
        if (result == true) {
          navigator.pop(true);
        } else {
          // User cancelled, resume scanning
          setState(() {
            _isScannerActive = true;
          });
        }
      } else {
        // Product not found - offer to create custom product
        _showCreateProductDialog(code);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(l10n.networkErrorTitle, l10n.networkErrorMessage);
      setState(() {
        _isScannerActive = true;
      });
    }
  }

  void _showCreateProductDialog(String barcode) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.productNotFoundDialog),
        content: Text(
          '${l10n.noProductFoundWithBarcode(barcode)}\n\n${l10n.createCustomProductPrompt}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isScannerActive = true;
              });
            },
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              final result = await navigator.push<bool>(
                MaterialPageRoute(
                  builder: (context) => CreateLocalProductScreen(
                    initialBarcode: barcode,
                  ),
                ),
              );

              if (result == true && mounted) {
                // Product created, return to parent
                navigator.pop(true);
              } else {
                // Resume scanning
                setState(() {
                  _isScannerActive = true;
                });
              }
            },
            child: Text(l10n.createProductButton),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = widget.mealType != null
        ? l10n.scanForMeal(widget.mealType!.displayName(context))
        : l10n.scanBarcode;

    return Scaffold(
      appBar: BrandedAppBar(
        title: title,
      ),
      body: Stack(
        children: [
          if (_isScannerActive)
            ReaderWidget(
              onScan: _handleBarcode,
              scanDelay: const Duration(milliseconds: 250),
              codeFormat: Format.any,
              tryHarder: true,
              tryInverted: true,
              resolution: ResolutionPreset.high,
              showFlashlight: true,
              showToggleCamera: false,
              showGallery: false,
            ),
          if (!_isScannerActive)
            Container(
              color:
                  Theme.of(context).colorScheme.scrim.withValues(alpha: 0.54),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.loadingProduct,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color:
                  Theme.of(context).colorScheme.scrim.withValues(alpha: 0.54),
              child: Text(
                l10n.pointCameraAtBarcode,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
