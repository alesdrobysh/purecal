import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../l10n/app_localizations.dart';
import '../models/meal_type.dart';
import '../services/product_service.dart';
import 'product_detail_screen.dart';
import 'create_local_product_screen.dart';
import '../config/decorations.dart';

class ScannerScreen extends StatefulWidget {
  final MealType? mealType;

  const ScannerScreen({super.key, this.mealType});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final ProductService _productService = ProductService();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final l10n = AppLocalizations.of(context)!;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _controller.stop();

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
            _isProcessing = false;
          });
          await _controller.start();
        }
      } else {
        // Product not found - offer to create custom product
        _showCreateProductDialog(code);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(l10n.error, l10n.failedToFetchProduct(e.toString()));
      setState(() {
        _isProcessing = false;
      });
      await _controller.start();
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
                _isProcessing = false;
              });
              _controller.start();
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
                  _isProcessing = false;
                });
                await _controller.start();
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text(title),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          if (_isProcessing)
            Container(
              color: Theme.of(context).colorScheme.scrim.withOpacity(0.54),
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
              color: Theme.of(context).colorScheme.scrim.withOpacity(0.54),
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
