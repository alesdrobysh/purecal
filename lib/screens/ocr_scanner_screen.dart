import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../models/meal_type.dart';
import '../models/nutrition_extraction.dart';
import '../services/ocr/ocr_service.dart';
import '../services/ocr/nutrition_table_detector.dart';
import 'ocr_result_screen.dart';

/// Screen for scanning nutrition labels using OCR
class OcrScannerScreen extends StatefulWidget {
  final MealType? mealType;

  const OcrScannerScreen({super.key, this.mealType});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> {
  CameraController? _cameraController;
  final ImagePicker _imagePicker = ImagePicker();
  final OcrService _ocrService = OcrService();
  final NutritionTableDetector _tableDetector = NutritionTableDetector();

  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _useTableDetection = false; // Set to true when model is available
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeTableDetector();
  }

  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No camera found';
        });
        return;
      }

      // Use back camera (index 0)
      final camera = cameras.first;

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Camera initialization failed: $e';
      });
    }
  }

  Future<void> _initializeTableDetector() async {
    try {
      await _tableDetector.initialize();
      setState(() {
        _useTableDetection = true;
      });
    } catch (e) {
      // Table detection not available - will use full image OCR
      debugPrint('Table detection not available: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _ocrService.dispose();
    _tableDetector.dispose();
    super.dispose();
  }

  /// Capture image from camera and process it
  Future<void> _captureAndProcess() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Capture image
      final image = await _cameraController!.takePicture();

      // Process the image
      await _processImage(image.path);
    } catch (e) {
      if (mounted) {
        _showError('Failed to capture image: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Pick image from gallery and process it
  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;

    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _isProcessing = true;
      });

      await _processImage(image.path);
    } catch (e) {
      if (mounted) {
        _showError('Failed to process image: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Process captured/picked image with OCR
  Future<void> _processImage(String imagePath) async {
    try {
      NutritionExtraction? extraction;

      if (_useTableDetection) {
        // Step 1: Detect nutrition table region
        final region = await _tableDetector.detectBestNutritionTable(imagePath);

        if (region != null && region.confidence > 0.5) {
          // Step 2: OCR on detected region
          extraction = await _ocrService.extractNutritionFromImage(
            imagePath,
            preprocessImage: true,
          );
        }
      }

      // Fallback: OCR on full image if table detection failed or disabled
      if (extraction == null) {
        extraction = await _ocrService.extractNutritionFromImage(
          imagePath,
          preprocessImage: true,
        );
      }

      // Navigate to results screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OcrResultScreen(
              extraction: extraction!,
              imagePath: imagePath,
              mealType: widget.mealType,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('OCR processing failed: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanNutritionLabel),
        actions: [
          // Gallery button
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _isProcessing ? null : _pickFromGallery,
            tooltip: 'Pick from gallery',
          ),
        ],
      ),
      body: _buildBody(l10n),
      floatingActionButton: _isInitialized && !_isProcessing
          ? FloatingActionButton.large(
              onPressed: _captureAndProcess,
              child: const Icon(Icons.camera, size: 32),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Pick from gallery instead'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        // Camera preview
        Center(
          child: CameraPreview(_cameraController!),
        ),

        // Overlay guide
        CustomPaint(
          painter: _NutritionLabelGuidePainter(),
          child: Container(),
        ),

        // Instructions
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Card(
            color: Colors.black.withOpacity(0.7),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Position the nutrition label within the frame',
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        // Processing indicator
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Processing nutrition label...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Custom painter for nutrition label guide overlay
class _NutritionLabelGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw a rectangle guide in the center
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.6,
    );

    // Draw corners
    const cornerLength = 40.0;

    // Top-left corner
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(cornerLength, 0), paint);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, cornerLength), paint);

    // Top-right corner
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(-cornerLength, 0), paint);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, cornerLength), paint);

    // Bottom-left corner
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(cornerLength, 0), paint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(0, -cornerLength), paint);

    // Bottom-right corner
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(-cornerLength, 0), paint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + const Offset(0, -cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
