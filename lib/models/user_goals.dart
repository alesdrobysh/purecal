class UserGoals {
  final int? id;
  final double caloriesGoal;
  final double proteinsGoal;
  final double fatGoal;
  final double carbsGoal;
  final DateTime createdAt;

  UserGoals({
    this.id,
    required this.caloriesGoal,
    required this.proteinsGoal,
    required this.fatGoal,
    required this.carbsGoal,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'calories_goal': caloriesGoal,
      'proteins_goal': proteinsGoal,
      'fat_goal': fatGoal,
      'carbs_goal': carbsGoal,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserGoals.fromMap(Map<String, dynamic> map) {
    return UserGoals(
      id: map['id'] as int?,
      caloriesGoal: (map['calories_goal'] ?? 2000).toDouble(),
      proteinsGoal: (map['proteins_goal'] ?? 150).toDouble(),
      fatGoal: (map['fat_goal'] ?? 65).toDouble(),
      carbsGoal: (map['carbs_goal'] ?? 200).toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }

  factory UserGoals.defaultGoals() {
    return UserGoals(
      caloriesGoal: 2000,
      proteinsGoal: 150,
      fatGoal: 65,
      carbsGoal: 200,
    );
  }

  UserGoals copyWith({
    int? id,
    double? caloriesGoal,
    double? proteinsGoal,
    double? fatGoal,
    double? carbsGoal,
    DateTime? createdAt,
  }) {
    return UserGoals(
      id: id ?? this.id,
      caloriesGoal: caloriesGoal ?? this.caloriesGoal,
      proteinsGoal: proteinsGoal ?? this.proteinsGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserGoals(calories: $caloriesGoal, proteins: $proteinsGoal, fat: $fatGoal, carbs: $carbsGoal)';
  }
}
