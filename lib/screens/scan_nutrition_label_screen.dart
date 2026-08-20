import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../services/ocr/nutrition_label_parser.dart';
import '../services/ocr/ocr_service.dart';
import '../widgets/branded_app_bar.dart';

/// Opens the camera, runs on-device OCR + parsing on the captured nutrition
/// label, and pops with the result.
///
/// Pop result contract:
/// - `null` — the user cancelled before/without capturing a photo. The
///   caller should do nothing.
/// - non-null `ScannedLabelInfo` — a photo was processed. Some or all of
///   its fields may still be null if they weren't confidently recognized;
///   the caller prefills whichever fields came back non-null and, if the
///   whole result is empty, shows a "couldn't read the label" message.
class ScanNutritionLabelScreen extends StatefulWidget {
  const ScanNutritionLabelScreen({super.key});

  @override
  State<ScanNutritionLabelScreen> createState() =>
      _ScanNutritionLabelScreenState();
}

class _ScanNutritionLabelScreenState extends State<ScanNutritionLabelScreen> {
  final _imagePicker = ImagePicker();
  final _ocrService = OcrService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureAndProcess());
  }

  Future<void> _captureAndProcess() async {
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 90,
    );

    if (!mounted) return;

    if (photo == null) {
      Navigator.pop(context, null);
      return;
    }

    final rawText = await _ocrService.recognizeText(File(photo.path));
    final parsed = parseNutritionLabel(rawText);

    if (!mounted) return;
    Navigator.pop(context, parsed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: BrandedAppBar(title: l10n.scanNutritionLabel),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.scanningLabel),
          ],
        ),
      ),
    );
  }
}
