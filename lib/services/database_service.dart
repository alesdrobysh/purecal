import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/diary_entry.dart';
import '../models/user_goals.dart';
import '../models/food_product.dart';

class DailySummary {
  final double calories;
  final double proteins;
  final double fat;
  final double carbs;

  DailySummary({
    required this.calories,
    required this.proteins,
    required this.fat,
    required this.carbs,
  });
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'foodiefit.db');

    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE diary_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT NOT NULL,
        product_name TEXT NOT NULL,
        brand TEXT,
        date TEXT NOT NULL,
        portion_grams REAL NOT NULL,
        calories REAL NOT NULL,
        proteins REAL NOT NULL,
        fat REAL NOT NULL,
        carbs REAL NOT NULL,
        image_url TEXT,
        meal_type TEXT NOT NULL DEFAULT 'snacks'
      )
    ''');

    await db.execute('''
      CREATE TABLE user_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        calories_goal REAL NOT NULL,
        proteins_goal REAL NOT NULL,
        fat_goal REAL NOT NULL,
        carbs_goal REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE product_usage (
        barcode TEXT PRIMARY KEY,
        product_name TEXT NOT NULL,
        total_count INTEGER NOT NULL DEFAULT 0,
        recent_count INTEGER NOT NULL DEFAULT 0,
        weighted_score REAL NOT NULL DEFAULT 0,
        last_used TEXT NOT NULL,
        image_url TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_diary_date ON diary_entries(date)
    ''');

    await db.execute('''
      CREATE INDEX idx_usage_score ON product_usage(weighted_score DESC)
    ''');

    // Add local_products table for custom user-created products
    await db.execute('''
        CREATE TABLE local_products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          barcode TEXT,
          product_name TEXT NOT NULL,
          brand TEXT,
          calories_per_100g REAL NOT NULL,
          proteins_per_100g REAL NOT NULL,
          fat_per_100g REAL NOT NULL,
          carbs_per_100g REAL NOT NULL,
          serving_size REAL,
          image_path TEXT,
          notes TEXT,
          is_deleted INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

    await db.execute('''
        CREATE INDEX idx_local_barcode ON local_products(barcode)
      ''');

    await db.execute('''
        CREATE INDEX idx_local_name ON local_products(product_name)
      ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add meal_type column
      await db.execute('''
        ALTER TABLE diary_entries ADD COLUMN meal_type TEXT
      ''');

      // Update existing entries with auto-assigned meal types based on time
      final entries = await db.query('diary_entries');
      for (final entry in entries) {
        final dateStr = entry['date'] as String;
        final date = DateTime.parse(dateStr);
        final hour = date.hour;

        String mealType;
        if (hour >= 6 && hour < 11) {
          mealType = 'breakfast';
        } else if (hour >= 11 && hour < 15) {
          mealType = 'lunch';
        } else if (hour >= 15 && hour < 20) {
          mealType = 'dinner';
        } else {
          mealType = 'snacks';
        }

        await db.update(
          'diary_entries',
          {'meal_type': mealType},
          where: 'id = ?',
          whereArgs: [entry['id']],
        );
      }
    }

    if (oldVersion < 3) {
      // Add product_usage table
      await db.execute('''
        CREATE TABLE product_usage (
          barcode TEXT PRIMARY KEY,
          product_name TEXT NOT NULL,
          total_count INTEGER NOT NULL DEFAULT 0,
          recent_count INTEGER NOT NULL DEFAULT 0,
          weighted_score REAL NOT NULL DEFAULT 0,
          last_used TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_usage_score ON product_usage(weighted_score DESC)
      ''');
    }

    if (oldVersion < 4) {
      // Add local_products table for custom user-created products
      await db.execute('''
        CREATE TABLE local_products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          barcode TEXT,
          product_name TEXT NOT NULL,
          brand TEXT,
          calories_per_100g REAL NOT NULL,
          proteins_per_100g REAL NOT NULL,
          fat_per_100g REAL NOT NULL,
          carbs_per_100g REAL NOT NULL,
          serving_size REAL,
          image_path TEXT,
          notes TEXT,
          is_deleted INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE INDEX idx_local_barcode ON local_products(barcode)
      ''');

      await db.execute('''
        CREATE INDEX idx_local_name ON local_products(product_name)
      ''');
    }

    if (oldVersion < 5) {
      await db.execute('''
        ALTER TABLE product_usage ADD COLUMN image_url TEXT
      ''');
    }
  }

  Future<int> insertEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.insert('diary_entries', entry.toMap());
  }

  Future<List<DiaryEntry>> getEntriesByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final results = await db.query(
      'diary_entries',
      where: 'date >= ? AND date < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'date DESC',
    );

    return results.map((map) => DiaryEntry.fromMap(map)).toList();
  }

  Future<List<DiaryEntry>> getEntriesByDateAndMeal(
      DateTime date, String mealType) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final results = await db.query(
      'diary_entries',
      where: 'date >= ? AND date < ? AND meal_type = ?',
      whereArgs: [
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
        mealType
      ],
      orderBy: 'date DESC',
    );

    return results.map((map) => DiaryEntry.fromMap(map)).toList();
  }

  Future<List<DiaryEntry>> getAllDiaryEntries() async {
    final db = await database;
    final results = await db.query(
      'diary_entries',
      orderBy: 'date DESC',
    );

    return results.map((map) => DiaryEntry.fromMap(map)).toList();
  }

  Future<List<DiaryEntry>> getEntriesByDateRange(
      DateTime startDate, DateTime endDate) async {
    final db = await database;
    final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
    final endOfDay = DateTime(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));

    final results = await db.query(
      'diary_entries',
      where: 'date >= ? AND date < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'date DESC',
    );

    return results.map((map) => DiaryEntry.fromMap(map)).toList();
  }

  Future<DailySummary> getDailySummary(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery('''
      SELECT
        SUM(calories) as total_calories,
        SUM(proteins) as total_proteins,
        SUM(fat) as total_fat,
        SUM(carbs) as total_carbs
      FROM diary_entries
      WHERE date >= ? AND date < ?
    ''', [startOfDay.toIso8601String(), endOfDay.toIso8601String()]);

    if (result.isEmpty) {
      return DailySummary(calories: 0, proteins: 0, fat: 0, carbs: 0);
    }

    final row = result.first;
    return DailySummary(
      calories: _toDouble(row['total_calories']),
      proteins: _toDouble(row['total_proteins']),
      fat: _toDouble(row['total_fat']),
      carbs: _toDouble(row['total_carbs']),
    );
  }

  Future<DailySummary> getMealSummary(DateTime date, String mealType) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery('''
      SELECT
        SUM(calories) as total_calories,
        SUM(proteins) as total_proteins,
        SUM(fat) as total_fat,
        SUM(carbs) as total_carbs
      FROM diary_entries
      WHERE date >= ? AND date < ? AND meal_type = ?
    ''', [startOfDay.toIso8601String(), endOfDay.toIso8601String(), mealType]);

    if (result.isEmpty) {
      return DailySummary(calories: 0, proteins: 0, fat: 0, carbs: 0);
    }

    final row = result.first;
    return DailySummary(
      calories: _toDouble(row['total_calories']),
      proteins: _toDouble(row['total_proteins']),
      fat: _toDouble(row['total_fat']),
      carbs: _toDouble(row['total_carbs']),
    );
  }

  Future<int> updateEntry(DiaryEntry entry) async {
    final db = await database;
    return await db.update(
      'diary_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertGoals(UserGoals goals) async {
    final db = await database;
    return await db.insert('user_goals', goals.toMap());
  }

  Future<UserGoals?> getCurrentGoals() async {
    final db = await database;
    final results = await db.query(
      'user_goals',
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return UserGoals.fromMap(results.first);
  }

  Future<int> updateGoals(UserGoals goals) async {
    final db = await database;
    if (goals.id != null) {
      return await db.update(
        'user_goals',
        goals.toMap(),
        where: 'id = ?',
        whereArgs: [goals.id],
      );
    } else {
      return await insertGoals(goals);
    }
  }

  Future<void> incrementProductUsage(
    String barcode,
    String productName, {
    String? imageUrl,
  }) async {
    final db = await database;
    final now = DateTime.now();

    // Check if product exists
    final existing = await db.query(
      'product_usage',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (existing.isNotEmpty) {
      final row = existing.first;
      final lastUsed = DateTime.parse(row['last_used'] as String);
      final daysSinceLastUse = now.difference(lastUsed).inDays;

      // Reset recent_count if last used more than 30 days ago
      int recentCount = row['recent_count'] as int;
      if (daysSinceLastUse > 30) {
        recentCount = 0;
      }

      final totalCount = (row['total_count'] as int) + 1;
      recentCount += 1;

      // Calculate weighted quadratic score: recent_count² + (total_count × 0.3)
      final weightedScore = (recentCount * recentCount) + (totalCount * 0.3);

      await db.update(
        'product_usage',
        {
          'product_name': productName,
          'total_count': totalCount,
          'recent_count': recentCount,
          'weighted_score': weightedScore,
          'last_used': now.toIso8601String(),
          if (imageUrl != null) 'image_url': imageUrl,
        },
        where: 'barcode = ?',
        whereArgs: [barcode],
      );
    } else {
      // Insert new product
      const weightedScore =
          1.0 + 0.3; // recent_count² (1²) + total_count × 0.3 (1 × 0.3)
      await db.insert('product_usage', {
        'barcode': barcode,
        'product_name': productName,
        'total_count': 1,
        'recent_count': 1,
        'weighted_score': weightedScore,
        'last_used': now.toIso8601String(),
        if (imageUrl != null) 'image_url': imageUrl,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getFrequentProducts(
      {int limit = 10}) async {
    final db = await database;

    final results = await db.query(
      'product_usage',
      orderBy: 'weighted_score DESC',
      limit: limit,
    );

    return results;
  }

  Future<void> clearFrequentProducts() async {
    final db = await database;
    await db.delete('product_usage');
  }

  Future<Map<DateTime, DailySummary>> getDailySummariesForRange(
    DateTime startDate,
    int days,
  ) async {
    final db = await database;
    final summaries = <DateTime, DailySummary>{};

    // Create all dates in range with zero values
    for (int i = 0; i < days; i++) {
      final date = DateTime(
        startDate.year,
        startDate.month,
        startDate.day + i,
      );
      summaries[date] = DailySummary(
        calories: 0,
        proteins: 0,
        fat: 0,
        carbs: 0,
      );
    }

    // Query actual data
    final endDate = startDate.add(Duration(days: days));
    final result = await db.rawQuery('''
      SELECT
        date,
        SUM(calories) as total_calories,
        SUM(proteins) as total_proteins,
        SUM(fat) as total_fat,
        SUM(carbs) as total_carbs
      FROM diary_entries
      WHERE date >= ? AND date < ?
      GROUP BY DATE(date)
      ORDER BY DATE(date)
    ''', [
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ]);

    // Populate with actual data
    for (final row in result) {
      final date = DateTime.parse(row['date'] as String);
      final normalizedDate = DateTime(date.year, date.month, date.day);

      summaries[normalizedDate] = DailySummary(
        calories: _toDouble(row['total_calories']),
        proteins: _toDouble(row['total_proteins']),
        fat: _toDouble(row['total_fat']),
        carbs: _toDouble(row['total_carbs']),
      );
    }

    return summaries;
  }

  // Local Products CRUD Operations

  Future<int> insertLocalProduct(FoodProduct product) async {
    final db = await database;
    return await db.insert('local_products', product.toLocalMap());
  }

  Future<FoodProduct?> getLocalProductById(int id) async {
    final db = await database;
    final results = await db.query(
      'local_products',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return FoodProduct.fromLocalMap(results.first);
  }

  Future<FoodProduct?> getLocalProductByBarcode(String barcode) async {
    if (barcode.isEmpty) return null;

    final db = await database;
    final results = await db.query(
      'local_products',
      where: 'barcode = ? AND is_deleted = 0',
      whereArgs: [barcode],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return FoodProduct.fromLocalMap(results.first);
  }

  Future<List<FoodProduct>> searchLocalProducts(String query) async {
    final db = await database;
    final searchTerm = '%$query%';

    final results = await db.query(
      'local_products',
      where: '(product_name LIKE ? OR brand LIKE ?) AND is_deleted = 0',
      whereArgs: [searchTerm, searchTerm],
      orderBy: 'product_name ASC',
    );

    return results.map((map) => FoodProduct.fromLocalMap(map)).toList();
  }

  Future<List<FoodProduct>> getAllLocalProducts(
      {bool includeDeleted = false}) async {
    final db = await database;

    final results = await db.query(
      'local_products',
      where: includeDeleted ? null : 'is_deleted = 0',
      orderBy: 'created_at DESC',
    );

    return results.map((map) => FoodProduct.fromLocalMap(map)).toList();
  }

  Future<int> updateLocalProduct(FoodProduct product) async {
    if (product.localId == null) {
      throw ArgumentError('Cannot update local product without localId');
    }

    final db = await database;
    final updatedProduct = FoodProduct(
      barcode: product.barcode,
      name: product.name,
      brand: product.brand,
      caloriesPer100g: product.caloriesPer100g,
      proteinsPer100g: product.proteinsPer100g,
      fatPer100g: product.fatPer100g,
      carbsPer100g: product.carbsPer100g,
      servingSize: product.servingSize,
      imageUrl: product.imageUrl,
      isLocal: true,
      localId: product.localId,
      notes: product.notes,
      createdAt: product.createdAt,
      updatedAt: DateTime.now(),
    );

    return await db.update(
      'local_products',
      updatedProduct.toLocalMap(),
      where: 'id = ?',
      whereArgs: [product.localId],
    );
  }

  Future<int> softDeleteLocalProduct(int id) async {
    final db = await database;
    return await db.update(
      'local_products',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  double _toDouble(Object? value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
