# Nutrition label OCR — design

Date: 2026-08-20
Status: approved (design), pending implementation plan

## Purpose

`CreateLocalProductScreen` currently requires the user to type in
`caloriesPer100g`, `proteinsPer100g`, `fatPer100g`, `carbsPer100g` by hand
when creating a custom product. Most packaged food sold in EU-format
markets (which covers the app's RU/PL/BE/most EN and ES users) prints
these four numbers on a "nutrition facts per 100g" label. This feature
lets the user photograph that label and have the four fields prefilled,
instead of typing them in.

## Scope for this iteration

- **Platform**: Android only. iOS (native `Vision` framework OCR) is a
  separate follow-up, not part of this plan.
- **Label format**: EU per-100g format only (`Energy`/`Энергетическая
  ценность`/`Wartość odżywcza`/`Valor energético` tables). US
  per-serving labels with %DV are explicitly out of scope.
- **Languages**: en, ru, pl, es, be — matching the app's existing
  `lib/l10n` locales. `rus.traineddata` is used for `be` (Belarusian
  Cyrillic overlaps enough with Russian for Tesseract's purposes; a
  dedicated Belarusian model does not exist).
- **Everything on-device.** No photo or extracted text ever leaves the
  device — this is a hard requirement, not a preference: it matches
  the app's existing no-cloud-sync, privacy-focused positioning and
  its F-Droid distribution (no Play Services, no proprietary SDKs, no
  network dependency for a core flow).

## Why Tesseract, not ML Kit or PaddleOCR

Three OCR options were considered:

- **Google ML Kit Text Recognition** — rejected outright. Even the
  "unbundled" on-device variant is a proprietary Google library and
  gets flagged as a non-free dependency by F-Droid. Incompatible with
  how this app is distributed.
- **PaddleOCR mobile (PP-OCR, TFLite)** — better accuracy and smaller
  model than Tesseract, Apache-2.0, but no mature Flutter plugin
  exists. Would mean hand-rolling a native Android TFLite bridge.
  Worth revisiting if Tesseract's accuracy turns out to be
  insufficient in practice.
- **Tesseract OCR** — Apache-2.0, offline, mature Flutter plugins
  exist, language data files (`eng`, `rus`, `pol`, `spa`) are
  off-the-shelf. Weaker than PaddleOCR on small/dense/rotated text,
  but nutrition tables print calories/macros in a reasonably large,
  high-contrast, tabular layout, which is Tesseract's better case.

Tesseract is the starting choice. It sits behind an `OcrService`
interface (see below) specifically so it can be swapped for PaddleOCR
later without touching the parser or UI.

## Data flow

```
CreateLocalProductScreen
  → "Scan label" button
  → image_picker (camera)
  → OcrService.recognizeText(imageFile) → raw String
  → NutritionLabelParser.parse(rawText, locale) → ParsedNutrition
  → prefill _caloriesController / _proteinsController /
    _fatController / _carbsController (existing controllers,
    see create_local_product_screen.dart:60-69)
  → user reviews/edits pre-filled fields exactly like manual entry
  → existing save path (create_local_product_screen.dart:223-224 area)
    is unchanged
```

No new database columns, no `FoodProduct` model changes: the four
`local_products` fields (`calories_per_100g`, `proteins_per_100g`,
`fat_per_100g`, `carbs_per_100g`) already exist and already are exactly
per-100g, which is why EU-format-only was the right scope choice —
zero schema or model changes needed for this feature.

## Components

### `lib/services/ocr/ocr_service.dart`

Thin wrapper around the Tesseract plugin. One method:

```dart
Future<String> recognizeText(File image);
```

No parsing logic here. Its only job is turning a photo into raw text.
This boundary is what makes swapping the OCR engine later a
single-file change.

### `lib/services/ocr/nutrition_label_parser.dart`

Pure Dart, no Flutter/plugin dependencies — this is the part that
actually needs to be correct and is the part that's cheap to test.

```dart
class ParsedNutrition {
  final double? caloriesPer100g;
  final double? proteinsPer100g;
  final double? fatPer100g;
  final double? carbsPer100g;
}

ParsedNutrition parseNutritionLabel(String rawText, String localeCode);
```

Approach: per-locale keyword tables (energy/kcal/ккал/kcal/energía,
protein/белки/białko/proteína, fat/жиры/tłuszcz/grasa,
carbohydrate/углеводы/węglowodany/carbohidratos) matched against each
line of OCR output, followed by a number extractor that handles both
`12,5` and `12.5` decimal styles and strips `g`/`kcal`/`ккал` units.
A field that isn't confidently matched is left `null` — the parser
never guesses.

### `lib/screens/scan_nutrition_label_screen.dart`

Camera capture UI (reuses `image_picker`, already a dependency) with a
loading state while OCR/parsing runs, then returns a `ParsedNutrition`
to the caller.

### `create_local_product_screen.dart`

Gets a new "Scan label" entry point next to the existing form. On
return from the scan screen, only the text controllers for fields that
came back non-null are overwritten — anything the user already typed,
or anything the parser couldn't find, is left alone. Nothing is saved
until the user hits the existing save action.

## Error handling

- OCR returns no text, or the parser matches nothing: the screen
  closes back to the form with nothing prefilled and a brief
  "couldn't read the label, please enter manually" message. This is
  not an error state for the rest of the app — manual entry is the
  existing, still fully-supported path.
- Partial matches (e.g. calories and protein found, fat and carbs not)
  are expected and fine: prefill what was found, leave the rest for
  manual entry.

## Testing

- `nutrition_label_parser.dart` is unit-tested directly against a
  small fixture corpus of real label text (typed in by hand from
  photographed EU labels across the 5 supported locales, comma and
  dot decimals, mg/g variants). This is where almost all the test
  investment goes, and it does not require a device or camera.
- `OcrService` and the scan screen are exercised manually on a device;
  OCR accuracy against real-world photos isn't something a unit test
  can meaningfully assert.

## Explicitly out of scope (this iteration)

- US per-serving nutrition labels.
- iOS (native `Vision` OCR integration).
- Any bundled photo of the product itself for identification —
  this feature only reads numbers off the nutrition table, it does
  not attempt to recognize what the food is.
- Any network call, cloud OCR, or telemetry about scan success/failure
  rate.

## Addendum (implementation): name/brand extraction

Shipped alongside the macro parsing in the same iteration. Many EU
packages print the product name (and sometimes the brand) directly
above the nutrition table, in the same photo. `parseNutritionLabel`
takes up to two non-numeric, non-boilerplate lines immediately
preceding the first recognized nutrient row as `(name, brand)`, filtered
against a small list of generic table-title phrases ("Nutrition
Facts", "Wartość odżywcza", "Пищевая ценность", ...) so the table's own
header text is never mistaken for a product name. If the nutrition
table itself can't be located, or nothing above it looks like text
rather than a barcode/date, both stay `null` — same "never guess"
contract as the macro fields. This renamed the result type from
`ParsedNutrition` to `ScannedLabelInfo` throughout.
