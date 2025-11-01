import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/food_product.dart';
import '../services/product_service.dart';

class CreateLocalProductScreen extends StatefulWidget {
  final FoodProduct? product;
  final String? initialBarcode;

  const CreateLocalProductScreen({
    super.key,
    this.product,
    this.initialBarcode,
  });

  @override
  State<CreateLocalProductScreen> createState() => _CreateLocalProductScreenState();
}

class _CreateLocalProductScreenState extends State<CreateLocalProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  final _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _barcodeController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinsController;
  late TextEditingController _fatController;
  late TextEditingController _carbsController;
  late TextEditingController _servingSizeController;
  late TextEditingController _notesController;

  String? _imagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;

    _nameController = TextEditingController(text: product?.name ?? '');
    _brandController = TextEditingController(text: product?.brand ?? '');
    _barcodeController = TextEditingController(
      text: widget.initialBarcode ?? product?.barcode ?? '',
    );
    _caloriesController = TextEditingController(
      text: product?.caloriesPer100g.toString() ?? '',
    );
    _proteinsController = TextEditingController(
      text: product?.proteinsPer100g.toString() ?? '',
    );
    _fatController = TextEditingController(
      text: product?.fatPer100g.toString() ?? '',
    );
    _carbsController = TextEditingController(
      text: product?.carbsPer100g.toString() ?? '',
    );
    _servingSizeController = TextEditingController(
      text: product?.servingSize?.toString() ?? '',
    );
    _notesController = TextEditingController(text: product?.notes ?? '');
    _imagePath = product?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _barcodeController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    _servingSizeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isEditMode => widget.product != null;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Save image to app's documents directory
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedPath = path.join(directory.path, 'product_images', fileName);

        // Create directory if it doesn't exist
        await Directory(path.dirname(savedPath)).create(recursive: true);

        // Copy image to permanent location
        await File(pickedFile.path).copy(savedPath);

        setState(() {
          _imagePath = savedPath;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _validateNumber(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'This field is required' : null;
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    if (double.parse(value) < 0) {
      return 'Value must be non-negative';
    }
    return null;
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final product = FoodProduct(
        barcode: _barcodeController.text.trim(),
        name: _nameController.text.trim(),
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        caloriesPer100g: double.parse(_caloriesController.text),
        proteinsPer100g: double.parse(_proteinsController.text),
        fatPer100g: double.parse(_fatController.text),
        carbsPer100g: double.parse(_carbsController.text),
        servingSize: _servingSizeController.text.trim().isEmpty
            ? null
            : double.tryParse(_servingSizeController.text),
        imageUrl: _imagePath,
        isLocal: true,
        localId: widget.product?.localId,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.product?.createdAt,
        updatedAt: DateTime.now(),
      );

      if (_isEditMode) {
        await _productService.updateLocalProduct(product);
      } else {
        await _productService.createLocalProduct(product);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode
              ? 'Product updated successfully'
              : 'Product created successfully'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving product: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Product' : 'Create Local Product'),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image picker
            Center(
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 40, color: Colors.grey[600]),
                            const SizedBox(height: 8),
                            Text(
                              'Add Photo',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Product Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name *',
                border: OutlineInputBorder(),
              ),
              validator: _validateRequired,
            ),
            const SizedBox(height: 16),

            // Brand
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Brand',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Barcode
            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'Barcode (optional)',
                border: OutlineInputBorder(),
                helperText: 'Leave empty for homemade items',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Nutrition Section
            const Text(
              'Nutrition per 100g',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Calories
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(
                labelText: 'Calories (kcal) *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => _validateNumber(value, required: true),
            ),
            const SizedBox(height: 16),

            // Protein
            TextFormField(
              controller: _proteinsController,
              decoration: const InputDecoration(
                labelText: 'Protein (g) *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => _validateNumber(value, required: true),
            ),
            const SizedBox(height: 16),

            // Fat
            TextFormField(
              controller: _fatController,
              decoration: const InputDecoration(
                labelText: 'Fat (g) *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => _validateNumber(value, required: true),
            ),
            const SizedBox(height: 16),

            // Carbs
            TextFormField(
              controller: _carbsController,
              decoration: const InputDecoration(
                labelText: 'Carbohydrates (g) *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => _validateNumber(value, required: true),
            ),
            const SizedBox(height: 16),

            // Serving Size
            TextFormField(
              controller: _servingSizeController,
              decoration: const InputDecoration(
                labelText: 'Typical Serving Size (g)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => _validateNumber(value, required: false),
            ),
            const SizedBox(height: 24),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                helperText: 'Additional information about this product',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _isEditMode ? 'Update Product' : 'Create Product',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
