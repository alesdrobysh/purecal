import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../models/meal_type.dart';
import 'database_service.dart';

/// Result of a CSV import operation
class ImportResult {
  final int imported;
  final int skipped;
  final int errors;
  final List<String> errorMessages;

  ImportResult({
    required this.imported,
    required this.skipped,
    required this.errors,
    required this.errorMessages,
  });

  bool get hasErrors => errors > 0;
  int get totalProcessed => imported + skipped + errors;
}

/// Service for importing diary entries from CSV files
class ImportService {
  final DatabaseService _databaseService = DatabaseService();

  /// Import diary entries from a CSV file
  ///
  /// Expected CSV format (matching export format):
  /// Date, Time, Meal Type, Product Name, Brand, Portion (g), Calories, Protein (g), Fat (g), Carbs (g)
  ///
  /// Returns an [ImportResult] with statistics about the import operation
  Future<ImportResult> importDiaryEntriesFromCsv(String filePath) async {
    int importedCount = 0;
    int skippedCount = 0;
    int errorCount = 0;
    final List<String> errorMessages = [];

    try {
      // Read file content
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        throw Exception('File is empty');
      }

      // Parse CSV
      final csvData = _parseCsvFile(content);

      if (csvData.isEmpty) {
        throw Exception('No data found in CSV file');
      }

      // Skip header row (first row)
      if (csvData.length < 2) {
        throw Exception('CSV file contains only headers, no data rows');
      }

      // Validate header
      if (!_validateHeader(csvData.first)) {
        throw Exception(
          'Invalid CSV format. Expected headers: Date, Time, Meal Type, Product Name, Brand, Portion (g), Calories, Protein (g), Fat (g), Carbs (g)',
        );
      }

      // Process each data row (skip header)
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        final lineNumber = i + 1; // +1 for 1-based line numbers

        try {
          // Parse CSV line to DiaryEntry
          final entry = _parseCsvLineToEntry(row, lineNumber);

          if (entry == null) {
            errorCount++;
            errorMessages.add('Line $lineNumber: Could not parse entry');
            continue;
          }

          // Validate entry
          if (!_validateEntry(entry)) {
            errorCount++;
            errorMessages.add('Line $lineNumber: Invalid entry data (missing required fields)');
            continue;
          }

          // Check for duplicates
          if (await _isDuplicate(entry)) {
            skippedCount++;
            continue;
          }

          // Insert into database
          await _databaseService.insertEntry(entry);
          importedCount++;

        } catch (e) {
          errorCount++;
          errorMessages.add('Line $lineNumber: ${e.toString()}');
        }
      }

      return ImportResult(
        imported: importedCount,
        skipped: skippedCount,
        errors: errorCount,
        errorMessages: errorMessages,
      );

    } catch (e) {
      // Fatal error - couldn't process file at all
      return ImportResult(
        imported: importedCount,
        skipped: skippedCount,
        errors: errorCount + 1,
        errorMessages: [...errorMessages, 'Fatal error: ${e.toString()}'],
      );
    }
  }

  /// Parse CSV file content into a list of rows
  List<List<String>> _parseCsvFile(String content) {
    try {
      final csvConverter = const CsvToListConverter();
      final List<List<dynamic>> rawData = csvConverter.convert(content);

      // Convert to List<List<String>> and trim whitespace
      return rawData.map((row) {
        return row.map((cell) => cell.toString().trim()).toList();
      }).toList();
    } catch (e) {
      throw Exception('Failed to parse CSV: ${e.toString()}');
    }
  }

  /// Validate CSV header row
  bool _validateHeader(List<String> header) {
    if (header.length < 10) return false;

    // Check for expected headers (case-insensitive, flexible matching)
    final expectedHeaders = [
      'date',
      'time',
      'meal type',
      'product name',
      'brand',
      'portion',
      'calories',
      'protein',
      'fat',
      'carbs',
    ];

    for (int i = 0; i < expectedHeaders.length; i++) {
      final headerCell = header[i].toLowerCase();
      final expected = expectedHeaders[i];

      if (!headerCell.contains(expected)) {
        return false;
      }
    }

    return true;
  }

  /// Parse a CSV row into a DiaryEntry
  /// Returns null if parsing fails
  DiaryEntry? _parseCsvLineToEntry(List<String> row, int lineNumber) {
    try {
      // Ensure we have enough columns
      if (row.length < 10) {
        return null;
      }

      // Parse date and time
      final dateStr = row[0].trim();
      final timeStr = row[1].trim();
      final dateTimeStr = '$dateStr $timeStr';

      final DateTime date;
      try {
        date = DateFormat('yyyy-MM-dd HH:mm').parse(dateTimeStr);
      } catch (e) {
        // Try alternative formats
        try {
          date = DateTime.parse(dateTimeStr);
        } catch (e2) {
          return null;
        }
      }

      // Parse meal type
      final mealTypeStr = row[2].trim();
      final mealType = MealType.fromString(mealTypeStr);
      if (mealType == null) {
        // Fall back to time-based meal type
        return null;
      }

      // Parse product info
      final productName = row[3].trim();
      final brand = row[4].trim();

      // Parse nutrition data
      final double portionGrams = double.tryParse(row[5]) ?? 0.0;
      final double calories = double.tryParse(row[6]) ?? 0.0;
      final double proteins = double.tryParse(row[7]) ?? 0.0;
      final double fat = double.tryParse(row[8]) ?? 0.0;
      final double carbs = double.tryParse(row[9]) ?? 0.0;

      // Create DiaryEntry
      // Note: CSV doesn't contain barcode, so we use a placeholder
      // This is acceptable since barcode is mainly for product lookups
      return DiaryEntry(
        barcode: 'csv_import', // Placeholder barcode for imported entries
        productName: productName,
        brand: brand.isEmpty ? null : brand,
        date: date,
        portionGrams: portionGrams,
        calories: calories,
        proteins: proteins,
        fat: fat,
        carbs: carbs,
        mealType: mealType,
        imageUrl: null,
      );

    } catch (e) {
      return null;
    }
  }

  /// Validate that a DiaryEntry has all required fields
  bool _validateEntry(DiaryEntry entry) {
    // Check required fields
    if (entry.productName.isEmpty) return false;
    if (entry.portionGrams <= 0) return false;
    if (entry.calories < 0) return false;
    if (entry.proteins < 0) return false;
    if (entry.fat < 0) return false;
    if (entry.carbs < 0) return false;

    return true;
  }

  /// Check if an entry is a duplicate
  ///
  /// A duplicate is defined as an entry with:
  /// - Same date (within 1 minute)
  /// - Same product name
  /// - Same meal type
  Future<bool> _isDuplicate(DiaryEntry newEntry) async {
    try {
      // Get all entries for the same date
      final existingEntries = await _databaseService.getEntriesByDate(newEntry.date);

      // Check for duplicates
      for (final existing in existingEntries) {
        // Check if product name matches (case-insensitive)
        if (existing.productName.toLowerCase() != newEntry.productName.toLowerCase()) {
          continue;
        }

        // Check if meal type matches
        if (existing.mealType != newEntry.mealType) {
          continue;
        }

        // Check if time is within 1 minute
        final timeDifference = existing.date.difference(newEntry.date).abs();
        if (timeDifference.inMinutes <= 1) {
          return true; // This is a duplicate
        }
      }

      return false; // Not a duplicate

    } catch (e) {
      // If we can't check for duplicates, assume it's not a duplicate
      // to avoid losing data
      return false;
    }
  }
}
