/// Parses OCR text from a photo of an EU-format ("per 100g") nutrition
/// label into structured product info. Pure Dart, no plugin/platform
/// dependencies — this is deliberate so it can be unit-tested without a
/// device or camera.
///
/// Only the EU per-100g table layout is handled. US per-serving labels
/// (with %DV columns) are out of scope; see
/// docs/superpowers/specs/2026-08-20-nutrition-label-ocr-design.md.
library;

class ScannedLabelInfo {
  final String? name;
  final String? brand;
  final double? caloriesPer100g;
  final double? proteinsPer100g;
  final double? fatPer100g;
  final double? carbsPer100g;

  const ScannedLabelInfo({
    this.name,
    this.brand,
    this.caloriesPer100g,
    this.proteinsPer100g,
    this.fatPer100g,
    this.carbsPer100g,
  });

  bool get isEmpty =>
      name == null &&
      brand == null &&
      caloriesPer100g == null &&
      proteinsPer100g == null &&
      fatPer100g == null &&
      carbsPer100g == null;
}

enum _Nutrient { calories, protein, fat, carbs }

// Keyword lists are language-agnostic on purpose: the label's printed
// language has nothing to do with the app's UI locale (a be-locale user
// can easily be scanning a Russian- or Polish-labeled product), and OCR
// output for multilingual packaging can mix languages on the same label.
const Map<_Nutrient, List<String>> _keywords = {
  _Nutrient.calories: [
    'energy',
    'calories',
    'энергетическая ценность',
    'энергетычная каштоўнасць',
    'калорийность',
    'каларыйнасць',
    'wartość energetyczna',
    'valor energético',
    'valor energetico',
  ],
  _Nutrient.protein: [
    'protein',
    'белки',
    'белок',
    'бялкі',
    'białko',
    'proteínas',
    'proteina',
    'proteinas',
  ],
  _Nutrient.fat: [
    'fat',
    'жиры',
    'тлушчы',
    'tłuszcz',
    'grasas',
    'grasa',
  ],
  _Nutrient.carbs: [
    'carbohydrate',
    'углеводы',
    'вугляводы',
    'węglowodany',
    'hidratos de carbono',
    'carbohidratos',
  ],
};

// Generic table-title phrases that show up above the actual nutrient rows
// ("Nutrition Facts", "per 100g", ...). These are never product name/brand
// candidates even though they sit in the header region above the table.
const List<String> _genericHeaderNoise = [
  'nutrition facts',
  'nutritional information',
  'nutritional value',
  'per 100',
  'per serving',
  'wartość odżywcza',
  'informacja żywieniowa',
  'información nutricional',
  'valores nutricionales',
  'valor nutricional',
  'пищевая ценность',
  'информация о пищевой',
  'харчовая каштоўнасць',
  'харчовая вартасць',
];

// Matches "12,5" or "12.5" or "12", optionally followed by a unit.
// Deliberately does not match bare integers with no digits around them
// like page numbers or serving counts picked up elsewhere on the label.
final RegExp _numberPattern = RegExp(r'(\d+(?:[.,]\d+)?)\s*(kcal|ккал|kj|кдж|mg|мг|g|г)?', caseSensitive: false);

final RegExp _nonLetter = RegExp(r'[^\p{L}]', unicode: true);

/// Extracts product name/brand and calories/protein/fat/carbs per 100g from
/// raw OCR text of a nutrition label photo.
///
/// Macro strategy: for each nutrient, find the first line containing one of
/// its keywords, then take the first number on that line — with one
/// exception (see calories below).
///
/// Name/brand strategy: best-effort only. Many EU packages print the
/// product name (and sometimes the brand) directly above the nutrition
/// table, in the same shot — but plenty don't, since that text usually
/// lives on the front of the pack, not next to the macros. We take up to
/// two non-numeric, non-boilerplate lines that appear before the first
/// recognized nutrient row as (name, brand), in that order. If the table
/// itself can't be located, or nothing above it looks like text, both stay
/// null — this function never fabricates a name from an unrelated photo.
///
/// Every field the caller doesn't get can't be confidently filled: it is
/// left `null` rather than guessed.
ScannedLabelInfo parseNutritionLabel(String rawText) {
  final lines = rawText
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();

  final tableStart = _firstNutrientLineIndex(lines);
  final headerLines = tableStart == null ? const <String>[] : lines.sublist(0, tableStart);
  final nameCandidates = _productTextCandidates(headerLines);

  return ScannedLabelInfo(
    name: nameCandidates.isNotEmpty ? nameCandidates[0] : null,
    brand: nameCandidates.length > 1 ? nameCandidates[1] : null,
    caloriesPer100g: _findCalories(lines),
    proteinsPer100g: _findValue(lines, _Nutrient.protein),
    fatPer100g: _findValue(lines, _Nutrient.fat),
    carbsPer100g: _findValue(lines, _Nutrient.carbs),
  );
}

double? _findValue(List<String> lines, _Nutrient nutrient) {
  final line = _lineFor(lines, nutrient);
  if (line == null) return null;
  final match = _numberPattern.firstMatch(line);
  if (match == null) return null;
  return _parseNumber(match.group(1)!);
}

/// Calorie lines commonly show both kJ and kcal, e.g. "1310 kJ / 313 kcal".
/// We only ever take the number explicitly tagged "kcal"/"ккал" — picking
/// the "first number on the line" here would silently record the kJ value
/// as calories, which is wrong by a factor of ~4.
double? _findCalories(List<String> lines) {
  final line = _lineFor(lines, _Nutrient.calories);
  if (line == null) return null;

  for (final match in _numberPattern.allMatches(line)) {
    final unit = match.group(2)?.toLowerCase();
    if (unit == 'kcal' || unit == 'ккал') {
      return _parseNumber(match.group(1)!);
    }
  }
  return null;
}

String? _lineFor(List<String> lines, _Nutrient nutrient) {
  final keywords = _keywords[nutrient]!;
  for (final line in lines) {
    final lower = line.toLowerCase();
    if (keywords.any((k) => lower.contains(k))) {
      return line;
    }
  }
  return null;
}

int? _firstNutrientLineIndex(List<String> lines) {
  for (var i = 0; i < lines.length; i++) {
    final lower = lines[i].toLowerCase();
    for (final keywords in _keywords.values) {
      if (keywords.any((k) => lower.contains(k))) return i;
    }
  }
  return null;
}

List<String> _productTextCandidates(List<String> headerLines) {
  final candidates = <String>[];
  for (final line in headerLines) {
    if (candidates.length == 2) break;
    if (!_looksLikeProductText(line)) continue;
    candidates.add(line);
  }
  return candidates;
}

bool _looksLikeProductText(String line) {
  if (line.length < 3) return false;
  final lower = line.toLowerCase();
  if (_genericHeaderNoise.any((n) => lower.contains(n))) return false;
  final letterCount = line.replaceAll(_nonLetter, '').length;
  // Mostly digits/symbols — barcode, weight, best-before date, etc.
  return letterCount >= 2 && letterCount >= line.length * 0.4;
}

double? _parseNumber(String raw) => double.tryParse(raw.replaceAll(',', '.'));
