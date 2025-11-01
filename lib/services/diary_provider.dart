import 'package:flutter/foundation.dart';
import '../models/diary_entry.dart';
import '../models/user_goals.dart';
import '../models/food_product.dart';
import '../models/meal_type.dart';
import 'database_service.dart';

class DiaryProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  DateTime _selectedDate = DateTime.now();
  List<DiaryEntry> _entries = [];
  DailySummary _dailySummary =
      DailySummary(calories: 0, proteins: 0, fat: 0, carbs: 0);
  UserGoals? _userGoals;
  bool _isLoading = false;

  DateTime get selectedDate => _selectedDate;
  List<DiaryEntry> get entries => _entries;
  DailySummary get dailySummary => _dailySummary;
  UserGoals? get userGoals => _userGoals;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await loadGoals();
    await loadEntriesForDate(_selectedDate);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadGoals() async {
    _userGoals = await _dbService.getCurrentGoals();
    if (_userGoals == null) {
      _userGoals = UserGoals.defaultGoals();
      await _dbService.insertGoals(_userGoals!);
    }
    notifyListeners();
  }

  Future<void> updateGoals(UserGoals goals) async {
    await _dbService.updateGoals(goals);
    _userGoals = goals;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    loadEntriesForDate(_selectedDate);
  }

  void nextDay() {
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    loadEntriesForDate(_selectedDate);
  }

  void previousDay() {
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    loadEntriesForDate(_selectedDate);
  }

  void goToToday() {
    _selectedDate = DateTime.now();
    loadEntriesForDate(_selectedDate);
  }

  Future<void> loadEntriesForDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    _entries = await _dbService.getEntriesByDate(date);
    _dailySummary = await _dbService.getDailySummary(date);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProductEntry(
      FoodProduct product, double portionGrams, MealType mealType) async {
    final nutrition = product.calculateNutrition(portionGrams);

    final entry = DiaryEntry(
      barcode: product.barcode,
      productName: product.name,
      brand: product.brand,
      date: _selectedDate,
      portionGrams: portionGrams,
      calories: nutrition.calories,
      proteins: nutrition.proteins,
      fat: nutrition.fat,
      carbs: nutrition.carbs,
      imageUrl: product.imageUrl,
      mealType: mealType,
    );

    await _dbService.insertEntry(entry);

    // Track product usage for frequent products feature
    await _dbService.incrementProductUsage(product.barcode, product.name);

    await loadEntriesForDate(_selectedDate);
  }

  Future<void> addQuickEntry({
    required String productName,
    required double calories,
    required double proteins,
    required double fat,
    required double carbs,
    required MealType mealType,
  }) async {
    final entry = DiaryEntry(
      barcode: '', // No barcode for quick add
      productName: productName,
      date: _selectedDate,
      portionGrams: 1,
      calories: calories,
      proteins: proteins,
      fat: fat,
      carbs: carbs,
      mealType: mealType,
    );

    await _dbService.insertEntry(entry);
    await loadEntriesForDate(_selectedDate);
  }

  Future<void> updateEntry(DiaryEntry entry, double newPortionGrams) async {
    final product = FoodProduct(
      barcode: entry.barcode,
      name: entry.productName,
      brand: entry.brand,
      caloriesPer100g: (entry.calories / entry.portionGrams) * 100,
      proteinsPer100g: (entry.proteins / entry.portionGrams) * 100,
      fatPer100g: (entry.fat / entry.portionGrams) * 100,
      carbsPer100g: (entry.carbs / entry.portionGrams) * 100,
      imageUrl: entry.imageUrl,
    );

    final nutrition = product.calculateNutrition(newPortionGrams);

    final updatedEntry = entry.copyWith(
      portionGrams: newPortionGrams,
      calories: nutrition.calories,
      proteins: nutrition.proteins,
      fat: nutrition.fat,
      carbs: nutrition.carbs,
    );

    await _dbService.updateEntry(updatedEntry);
    await loadEntriesForDate(_selectedDate);
  }

  Future<void> deleteEntry(int entryId) async {
    await _dbService.deleteEntry(entryId);
    await loadEntriesForDate(_selectedDate);
  }

  // Meal-specific methods
  List<DiaryEntry> getEntriesByMealType(MealType mealType) {
    return _entries.where((entry) => entry.mealType == mealType).toList();
  }

  Future<DailySummary> getMealSummary(MealType mealType) async {
    return await _dbService.getMealSummary(_selectedDate, mealType.toDatabase());
  }

  Future<void> changeEntryMealType(int entryId, MealType newMealType) async {
    final entry = _entries.firstWhere((e) => e.id == entryId);
    final updatedEntry = entry.copyWith(mealType: newMealType);
    await _dbService.updateEntry(updatedEntry);
    await loadEntriesForDate(_selectedDate);
  }

  int getEntryCountForMeal(MealType mealType) {
    return getEntriesByMealType(mealType).length;
  }

  double getMealCalories(MealType mealType) {
    final entries = getEntriesByMealType(mealType);
    return entries.fold(0.0, (sum, entry) => sum + entry.calories);
  }

  // Charts data methods
  Future<List<DailySummary>> getWeeklySummaries() async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final startOfWeek = startOfToday.subtract(const Duration(days: 6));

    final summaryMap = await _dbService.getDailySummariesForRange(
      startOfWeek,
      7,
    );

    // Convert to ordered list
    final summaries = <DailySummary>[];
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final summary = summaryMap[date] ?? DailySummary(calories: 0, proteins: 0, fat: 0, carbs: 0);
      summaries.add(summary);
    }

    return summaries;
  }

  Future<DailySummary> getTodaySummary() async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return await _dbService.getDailySummary(startOfToday);
  }

  // Frequent products methods
  Future<List<Map<String, dynamic>>> getFrequentProducts({int limit = 10}) async {
    return await _dbService.getFrequentProducts(limit: limit);
  }

  Future<void> clearFrequentProductsCache() async {
    await _dbService.clearFrequentProducts();
    notifyListeners();
  }
}
