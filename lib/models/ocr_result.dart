/// Represents the raw OCR output from text recognition engines
class OcrResult {
  /// List of detected text blocks with their positions
  final List<TextBlock> textBlocks;

  /// Overall confidence score (0.0 - 1.0)
  final double confidence;

  /// Full concatenated text from all blocks
  final String fullText;

  /// Source engine that produced this result
  final OcrEngine engine;

  OcrResult({
    required this.textBlocks,
    required this.confidence,
    required this.fullText,
    required this.engine,
  });

  /// Combine multiple OCR results (e.g., from different engines)
  factory OcrResult.merge(List<OcrResult> results) {
    if (results.isEmpty) {
      return OcrResult(
        textBlocks: [],
        confidence: 0.0,
        fullText: '',
        engine: OcrEngine.none,
      );
    }

    // Take the result with highest confidence
    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return results.first;
  }

  @override
  String toString() {
    return 'OcrResult(blocks: ${textBlocks.length}, confidence: ${confidence.toStringAsFixed(2)}, engine: $engine)';
  }
}

/// Individual text block with position information
class TextBlock {
  /// The recognized text
  final String text;

  /// Bounding box coordinates (x, y, width, height)
  final BoundingBox boundingBox;

  /// Confidence score for this block (0.0 - 1.0)
  final double confidence;

  /// Line number in the image (top to bottom)
  final int lineNumber;

  TextBlock({
    required this.text,
    required this.boundingBox,
    required this.confidence,
    required this.lineNumber,
  });

  @override
  String toString() => 'TextBlock(text: "$text", confidence: ${confidence.toStringAsFixed(2)})';
}

/// Bounding box for text detection
class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Check if this box overlaps with another
  bool overlaps(BoundingBox other) {
    return !(x + width < other.x ||
        other.x + other.width < x ||
        y + height < other.y ||
        other.y + other.height < y);
  }

  @override
  String toString() => 'BoundingBox(x: $x, y: $y, w: $width, h: $height)';
}

/// OCR engine types
enum OcrEngine {
  googleMLKit,
  tesseract,
  none,
}
