import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/meal_type.dart';
import '../services/product_service.dart';
import '../widgets/add_product_dialog.dart';
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
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AddProductDialog(
            product: product,
            mealType: widget.mealType,
          ),
        );

        if (!mounted) return;

        // If product was added, return true to parent screen
        if (result == true) {
          Navigator.of(context).pop(true);
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
      _showErrorDialog('Error', 'Failed to fetch product: $e');
      setState(() {
        _isProcessing = false;
      });
      await _controller.start();
    }
  }

  void _showCreateProductDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Not Found'),
        content: Text(
          'No product found with barcode: $barcode\n\nWould you like to create a custom product with this barcode?',
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
            child: const Text('Cancel'),
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
            child: const Text('Create Product'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.mealType != null
        ? 'Scan for ${widget.mealType!.displayName}'
        : 'Scan Barcode';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.green,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading product...',
                      style: TextStyle(
                        color: Colors.white,
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
              color: Colors.black54,
              child: const Text(
                'Point your camera at a barcode to scan',
                style: TextStyle(
                  color: Colors.white,
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
