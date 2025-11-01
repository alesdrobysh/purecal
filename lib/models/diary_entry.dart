import 'meal_type.dart';

class DiaryEntry {
  final int? id;
  final String barcode;
  final String productName;
  final String? brand;
  final DateTime date;
  final double portionGrams;
  final double calories;
  final double proteins;
  final double fat;
  final double carbs;
  final String? imageUrl;
  final MealType mealType;

  DiaryEntry({
    this.id,
    required this.barcode,
    required this.productName,
    this.brand,
    required this.date,
    required this.portionGrams,
    required this.calories,
    required this.proteins,
    required this.fat,
    required this.carbs,
    this.imageUrl,
    required this.mealType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'product_name': productName,
      'brand': brand,
      'date': date.toIso8601String(),
      'portion_grams': portionGrams,
      'calories': calories,
      'proteins': proteins,
      'fat': fat,
      'carbs': carbs,
      'image_url': imageUrl,
      'meal_type': mealType.toDatabase(),
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    final date = DateTime.parse(map['date'].toString());

    // Auto-assign meal type based on time if not present (for migration)
    final mealType = MealType.fromString(map['meal_type']?.toString()) ??
                     MealType.fromTime(date);

    return DiaryEntry(
      id: map['id'] as int?,
      barcode: map['barcode']?.toString() ?? '',
      productName: map['product_name']?.toString() ?? 'Unknown',
      brand: map['brand']?.toString(),
      date: date,
      portionGrams: (map['portion_grams'] ?? 0).toDouble(),
      calories: (map['calories'] ?? 0).toDouble(),
      proteins: (map['proteins'] ?? 0).toDouble(),
      fat: (map['fat'] ?? 0).toDouble(),
      carbs: (map['carbs'] ?? 0).toDouble(),
      imageUrl: map['image_url']?.toString(),
      mealType: mealType,
    );
  }

  DiaryEntry copyWith({
    int? id,
    String? barcode,
    String? productName,
    String? brand,
    DateTime? date,
    double? portionGrams,
    double? calories,
    double? proteins,
    double? fat,
    double? carbs,
    String? imageUrl,
    MealType? mealType,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      date: date ?? this.date,
      portionGrams: portionGrams ?? this.portionGrams,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      imageUrl: imageUrl ?? this.imageUrl,
      mealType: mealType ?? this.mealType,
    );
  }

  @override
  String toString() {
    return 'DiaryEntry(id: $id, name: $productName, portion: ${portionGrams}g, date: $date)';
  }
}
