class FoodProduct {
  final String barcode;
  final String name;
  final String? brand;
  final double caloriesPer100g;
  final double proteinsPer100g;
  final double fatPer100g;
  final double carbsPer100g;
  final double? servingSize;
  final String? imageUrl;

  // Local product fields
  final bool isLocal;
  final int? localId;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FoodProduct({
    required this.barcode,
    required this.name,
    this.brand,
    required this.caloriesPer100g,
    required this.proteinsPer100g,
    required this.fatPer100g,
    required this.carbsPer100g,
    this.servingSize,
    this.imageUrl,
    this.isLocal = false,
    this.localId,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory FoodProduct.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

    String parseServingSize(dynamic value) {
      if (value == null) return '100';
      final str = value.toString().toLowerCase();
      final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(str);
      return match?.group(1) ?? '100';
    }

    return FoodProduct(
      barcode: json['code']?.toString() ?? '',
      name: product['product_name']?.toString() ?? 'Unknown Product',
      brand: product['brands']?.toString(),
      caloriesPer100g: (nutriments['energy-kcal_100g'] ?? 0).toDouble(),
      proteinsPer100g: (nutriments['proteins_100g'] ?? 0).toDouble(),
      fatPer100g: (nutriments['fat_100g'] ?? 0).toDouble(),
      carbsPer100g: (nutriments['carbohydrates_100g'] ?? 0).toDouble(),
      servingSize: double.tryParse(parseServingSize(product['serving_size'])),
      imageUrl: product['image_front_url']?.toString() ??
          product['image_url']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'calories_per_100g': caloriesPer100g,
      'proteins_per_100g': proteinsPer100g,
      'fat_per_100g': fatPer100g,
      'carbs_per_100g': carbsPer100g,
      'serving_size': servingSize,
      'image_url': imageUrl,
    };
  }

  factory FoodProduct.fromMap(Map<String, dynamic> map) {
    return FoodProduct(
      barcode: map['barcode']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown Product',
      brand: map['brand']?.toString(),
      caloriesPer100g: (map['calories_per_100g'] ?? 0).toDouble(),
      proteinsPer100g: (map['proteins_per_100g'] ?? 0).toDouble(),
      fatPer100g: (map['fat_per_100g'] ?? 0).toDouble(),
      carbsPer100g: (map['carbs_per_100g'] ?? 0).toDouble(),
      servingSize: map['serving_size'] != null
          ? double.tryParse(map['serving_size'].toString())
          : null,
      imageUrl: map['image_url']?.toString(),
    );
  }

  factory FoodProduct.fromLocalMap(Map<String, dynamic> map) {
    return FoodProduct(
      barcode: map['barcode']?.toString() ?? '',
      name: map['product_name']?.toString() ?? 'Unknown Product',
      brand: map['brand']?.toString(),
      caloriesPer100g: (map['calories_per_100g'] ?? 0).toDouble(),
      proteinsPer100g: (map['proteins_per_100g'] ?? 0).toDouble(),
      fatPer100g: (map['fat_per_100g'] ?? 0).toDouble(),
      carbsPer100g: (map['carbs_per_100g'] ?? 0).toDouble(),
      servingSize: map['serving_size'] != null
          ? double.tryParse(map['serving_size'].toString())
          : null,
      imageUrl: map['image_path']?.toString(),
      isLocal: true,
      localId: map['id'] as int?,
      notes: map['notes']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toLocalMap() {
    return {
      if (localId != null) 'id': localId,
      'barcode': barcode.isEmpty ? null : barcode,
      'product_name': name,
      'brand': brand,
      'calories_per_100g': caloriesPer100g,
      'proteins_per_100g': proteinsPer100g,
      'fat_per_100g': fatPer100g,
      'carbs_per_100g': carbsPer100g,
      'serving_size': servingSize,
      'image_path': imageUrl,
      'notes': notes,
      'is_deleted': 0,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  NutritionForPortion calculateNutrition(double portionInGrams) {
    final multiplier = portionInGrams / 100.0;
    return NutritionForPortion(
      calories: caloriesPer100g * multiplier,
      proteins: proteinsPer100g * multiplier,
      fat: fatPer100g * multiplier,
      carbs: carbsPer100g * multiplier,
    );
  }

  @override
  String toString() {
    return 'FoodProduct(name: $name, brand: $brand, barcode: $barcode)';
  }
}

class NutritionForPortion {
  final double calories;
  final double proteins;
  final double fat;
  final double carbs;

  NutritionForPortion({
    required this.calories,
    required this.proteins,
    required this.fat,
    required this.carbs,
  });
}
