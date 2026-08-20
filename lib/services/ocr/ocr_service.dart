import 'dart:io';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

/// Thin wrapper around the Tesseract plugin. The only job of this class is
/// turning a photo into raw text — no parsing logic lives here, so the OCR
/// engine can be swapped (e.g. for PaddleOCR) without touching
/// [NutritionLabelParser] or the screens that use it.
class OcrService {
  /// Combined language pack: nutrition labels on EU packaging are often
  /// printed in more than one language, and the label's language has no
  /// relation to the app's UI locale, so we always recognize against all
  /// four bundled languages at once rather than trying to guess one.
  static const String _language = 'eng+rus+pol+spa';

  Future<String> recognizeText(File image) {
    return FlutterTesseractOcr.extractText(
      image.path,
      language: _language,
      args: const {
        'psm': '6', // assume a single uniform block of text — better fit
        // for a tightly-cropped nutrition table than the default
        // page-segmentation mode.
      },
    );
  }
}
