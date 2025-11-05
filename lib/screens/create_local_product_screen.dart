import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/food_product.dart';
import '../l10n/app_localizations.dart';
import '../services/product_service.dart';
import '../widgets/custom_input_decoration.dart';
import '../config/decorations.dart';

class CreateLocalProductScreen extends StatefulWidget {
  final FoodProduct? product; // For editing existing local products
  final FoodProduct? sourceOffProduct; // For creating from OFF product
  final String? initialBarcode;

  const CreateLocalProductScreen({
    super.key,
    this.product,
    this.sourceOffProduct,
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
    // Priority: product (editing) > sourceOffProduct (creating from OFF) > defaults
    final sourceProduct = widget.product ?? widget.sourceOffProduct;

    _nameController = TextEditingController(text: sourceProduct?.name ?? '');
    _brandController = TextEditingController(text: sourceProduct?.brand ?? '');
    _barcodeController = TextEditingController(
      text: widget.initialBarcode ?? sourceProduct?.barcode ?? '',
    );
    _caloriesController = TextEditingController(
      text: sourceProduct?.caloriesPer100g.toString() ?? '',
    );
    _proteinsController = TextEditingController(
      text: sourceProduct?.proteinsPer100g.toString() ?? '',
    );
    _fatController = TextEditingController(
      text: sourceProduct?.fatPer100g.toString() ?? '',
    );
    _carbsController = TextEditingController(
      text: sourceProduct?.carbsPer100g.toString() ?? '',
    );
    _servingSizeController = TextEditingController(
      text: sourceProduct?.servingSize?.toString() ?? '',
    );

    // For OFF products, add a default note
    final defaultNotes = widget.sourceOffProduct != null
        ? 'Based on OpenFoodFacts product'
        : '';
    _notesController = TextEditingController(
      text: sourceProduct?.notes ?? defaultNotes,
    );
    _imagePath = sourceProduct?.imageUrl;
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
    final l10n = AppLocalizations.of(context)!;
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
        SnackBar(content: Text(l10n.errorPickingImage(e.toString()))),
      );
    }
  }

  void _showImageSourceDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectImageSource),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.camera),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.gallery),
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
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return l10n.fieldRequired;
    }
    return null;
  }

  String? _validateNumber(String? value, {bool required = true}) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.trim().isEmpty) {
      return required ? l10n.fieldRequired : null;
    }
    if (double.tryParse(value) == null) {
      return l10n.pleaseEnterValidNumber;
    }
    if (double.parse(value) < 0) {
      return l10n.valueMustBeNonNegative;
    }
    return null;
  }

  Future<void> _saveProduct() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Determine source type
      String? sourceType;
      if (widget.sourceOffProduct != null) {
        // Creating a local product from an OFF product
        sourceType = 'edited_off';
      } else if (widget.product != null) {
        // Editing existing local product, preserve its source type
        sourceType = widget.product!.sourceType ?? 'local';
      } else {
        // Creating a brand new local product
        sourceType = 'local';
      }

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
        sourceType: sourceType,
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
              ? l10n.productUpdatedSuccessfully
              : l10n.productCreatedSuccessfully),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorSavingProduct(e.toString()))),
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? l10n.editProduct : l10n.createProduct),
        backgroundColor: AppColors.green,
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
                              l10n.addPhoto,
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
              decoration: customInputDecoration(context).copyWith(
                labelText: l10n.productNameRequired,
              ),
              validator: _validateRequired,
            ),
            const SizedBox(height: 16),

            // Brand
            TextFormField(
              controller: _brandController,
              decoration: customInputDecoration(context).copyWith(
                labelText: l10n.brand,
              ),
            ),
            const SizedBox(height: 16),

            // Barcode
            TextFormField(
              controller: _barcodeController,
              decoration: customInputDecoration(context).copyWith(
                labelText: l10n.barcodeOptional,
                helperText: l10n.leaveEmptyForHomemade,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Nutrition Section
            Text(
              l10n.nutritionPer100g,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Calories
            TextFormField(
              controller: _caloriesController,
              decoration: customInputDecoration(context).copyWith(
                labelText: l10n.caloriesKcalRequired,
              ),
              keyboardType: TextInputType.number,
              validator: (value) => _validateNumber(value, required: true),
            ),
            const SizedBox(height: 16),

            // Protein
            TextFormField(
              controller: _proteinsController,
              decoration: customInputDecoration(context).copyWith(
                labelText: l10n.proteinGramsRequired,
              ),
              keyboardType: TextInputType.number,
              validator: (value) => _validateNumber(value, required: true),
            ),
            const SizedBox(height: 16),

            // Fat
            TextFormField(
              controller: _fatController,
              decoration: customInputDecoration(context).copyWith(
                labelText: l10n.fatGramsRequired,
              ),
              keyboardType: TextInputType.number,
              validator: (value) => _validateNumber(value, required: true),
            ),
            const SizedBox(height: 16),

            // Carbs
            TextFormField(
              controller: _carbsController,
              decoration: customInputDecoration(context).copyWith(
                labelText: l10n.carbohydratesGramsRequired,
              ),
              keyboardType: TextInputType.number,
              validator: (value) => _validateNumber(value, required: true),
            ),
            const SizedBox(height: 16),

            // Serving Size
            TextFormField(
              controller: _servingSizeController,
              decoration: customInputDecoration(context).copyWith(
                labelText: l10n.typicalServingSize,
              ),
              keyboardType: TextInputType.number,
              validator: (value) => _validateNumber(value, required: false),
            ),
            const SizedBox(height: 24),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: customInputDecoration(context).copyWith(
                labelText: l10n.notes,
                helperText: l10n.additionalInformation,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
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
                      _isEditMode ? l10n.updateProduct : l10n.createProductButton,
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
