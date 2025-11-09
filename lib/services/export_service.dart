import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'database_service.dart';
import '../models/diary_entry.dart';

class ExportService {
  Future<void> exportDiaryEntriesToCSV({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final List<DiaryEntry> entries;
    if (startDate != null && endDate != null) {
      entries =
          await DatabaseService().getEntriesByDateRange(startDate, endDate);
    } else {
      entries = await DatabaseService().getAllDiaryEntries();
    }

    if (entries.isEmpty) {
      throw Exception('No diary entries to export');
    }

    // Create CSV data
    final csvData = _generateCSVData(entries);

    // Convert to CSV string
    final csv = const ListToCsvConverter().convert(csvData);

    // Save to temporary file
    final file = await _saveToTempFile(csv, startDate, endDate);

    // Share the file
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'FoodieFit Diary Export',
    );
  }

  /// Generate CSV data from diary entries
  List<List<dynamic>> _generateCSVData(List<DiaryEntry> entries) {
    // CSV Headers
    final List<List<dynamic>> csvData = [
      [
        'Date',
        'Time',
        'Meal Type',
        'Product Name',
        'Brand',
        'Portion (g)',
        'Calories',
        'Protein (g)',
        'Fat (g)',
        'Carbs (g)',
      ]
    ];

    // Add each entry as a row
    for (final entry in entries) {
      csvData.add([
        DateFormat('yyyy-MM-dd').format(entry.date),
        DateFormat('HH:mm').format(entry.date),
        _capitalizeFirst(entry.mealType.name),
        entry.productName,
        entry.brand ?? '',
        entry.portionGrams.toStringAsFixed(1),
        entry.calories.toStringAsFixed(1),
        entry.proteins.toStringAsFixed(1),
        entry.fat.toStringAsFixed(1),
        entry.carbs.toStringAsFixed(1),
      ]);
    }

    return csvData;
  }

  /// Save CSV content to a temporary file
  Future<File> _saveToTempFile(
    String csvContent,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    // Generate filename with date range if specified
    String fileName;
    if (startDate != null && endDate != null) {
      final startStr = DateFormat('yyyyMMdd').format(startDate);
      final endStr = DateFormat('yyyyMMdd').format(endDate);
      fileName = 'foodiefit_diary_${startStr}_to_$endStr.csv';
    } else {
      fileName = 'foodiefit_diary_$timestamp.csv';
    }

    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsString(csvContent);

    return file;
  }

  /// Capitalize first letter of a string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Export diary entries to JSON format
  Future<void> exportDiaryEntriesToJSON({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final List<DiaryEntry> entries;
    if (startDate != null && endDate != null) {
      entries =
          await DatabaseService().getEntriesByDateRange(startDate, endDate);
    } else {
      entries = await DatabaseService().getAllDiaryEntries();
    }

    if (entries.isEmpty) {
      throw Exception('No diary entries to export');
    }

    // Generate JSON data
    final jsonData = _generateJSONData(entries, startDate, endDate);

    // Convert to JSON string
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

    // Save to temporary file
    final file = await _saveJSONToTempFile(jsonString, startDate, endDate);

    // Share the file
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'FoodieFit Diary Export (JSON)',
    );
  }

  /// Generate JSON data structure from diary entries
  Map<String, dynamic> _generateJSONData(
    List<DiaryEntry> entries,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    // Calculate daily summaries
    final Map<String, Map<String, double>> dailySummaries = {};

    for (final entry in entries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.date);

      if (!dailySummaries.containsKey(dateKey)) {
        dailySummaries[dateKey] = {
          'calories': 0,
          'proteins': 0,
          'fat': 0,
          'carbs': 0,
        };
      }

      dailySummaries[dateKey]!['calories'] =
          dailySummaries[dateKey]!['calories']! + entry.calories;
      dailySummaries[dateKey]!['proteins'] =
          dailySummaries[dateKey]!['proteins']! + entry.proteins;
      dailySummaries[dateKey]!['fat'] =
          dailySummaries[dateKey]!['fat']! + entry.fat;
      dailySummaries[dateKey]!['carbs'] =
          dailySummaries[dateKey]!['carbs']! + entry.carbs;
    }

    // Build JSON structure
    return {
      'exportDate': DateTime.now().toIso8601String(),
      'dateRange': {
        'start': startDate?.toIso8601String() ?? 'all',
        'end': endDate?.toIso8601String() ?? 'all',
      },
      'totalEntries': entries.length,
      'entries': entries.map((entry) {
        return {
          'id': entry.id,
          'date': entry.date.toIso8601String(),
          'mealType': entry.mealType.name,
          'product': {
            'name': entry.productName,
            'brand': entry.brand,
            'barcode': entry.barcode,
          },
          'portion': {
            'grams': entry.portionGrams,
          },
          'nutrition': {
            'calories': entry.calories,
            'protein': entry.proteins,
            'fat': entry.fat,
            'carbs': entry.carbs,
          },
          'imageUrl': entry.imageUrl,
        };
      }).toList(),
      'dailySummaries': dailySummaries.entries.map((entry) {
        return {
          'date': entry.key,
          'totals': entry.value,
        };
      }).toList(),
    };
  }

  /// Save JSON content to a temporary file
  Future<File> _saveJSONToTempFile(
    String jsonContent,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    // Generate filename with date range if specified
    String fileName;
    if (startDate != null && endDate != null) {
      final startStr = DateFormat('yyyyMMdd').format(startDate);
      final endStr = DateFormat('yyyyMMdd').format(endDate);
      fileName = 'foodiefit_diary_${startStr}_to_$endStr.json';
    } else {
      fileName = 'foodiefit_diary_$timestamp.json';
    }

    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsString(jsonContent);

    return file;
  }
}
