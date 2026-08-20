import 'package:flutter_test/flutter_test.dart';
import 'package:purecal/services/ocr/nutrition_label_parser.dart';

void main() {
  group('parseNutritionLabel', () {
    test('parses an English EU-format label', () {
      const text = '''
Nutrition Facts per 100g
Energy 1046 kJ / 250 kcal
Fat 12.5 g
Protein 8.0 g
Carbohydrate 24.0 g
''';
      final result = parseNutritionLabel(text);
      expect(result.caloriesPer100g, 250);
      expect(result.fatPer100g, 12.5);
      expect(result.proteinsPer100g, 8.0);
      expect(result.carbsPer100g, 24.0);
    });

    test('parses a Russian label with comma decimals', () {
      const text = '''
Пищевая ценность на 100 г
Энергетическая ценность 837 кДж / 200 ккал
Белки 5,5 г
Жиры 10,0 г
Углеводы 22,3 г
''';
      final result = parseNutritionLabel(text);
      expect(result.caloriesPer100g, 200);
      expect(result.proteinsPer100g, 5.5);
      expect(result.fatPer100g, 10.0);
      expect(result.carbsPer100g, 22.3);
    });

    test('parses a Polish label', () {
      const text = '''
Wartość odżywcza w 100 g
Wartość energetyczna 1180 kJ / 282 kcal
Tłuszcz 14,0 g
Białko 6,2 g
Węglowodany 30,0 g
''';
      final result = parseNutritionLabel(text);
      expect(result.caloriesPer100g, 282);
      expect(result.fatPer100g, 14.0);
      expect(result.proteinsPer100g, 6.2);
      expect(result.carbsPer100g, 30.0);
    });

    test('parses a Spanish label', () {
      const text = '''
Información nutricional por 100 g
Valor energético 900 kJ / 215 kcal
Grasas 9,5 g
Proteínas 7,0 g
Hidratos de carbono 25,0 g
''';
      final result = parseNutritionLabel(text);
      expect(result.caloriesPer100g, 215);
      expect(result.fatPer100g, 9.5);
      expect(result.proteinsPer100g, 7.0);
      expect(result.carbsPer100g, 25.0);
    });

    test('parses a Belarusian label', () {
      const text = '''
Энергетычная каштоўнасць 1000 кДж / 239 ккал
Тлушчы 11,0 г
Бялкі 9,0 г
Вугляводы 20,0 г
''';
      final result = parseNutritionLabel(text);
      expect(result.caloriesPer100g, 239);
      expect(result.fatPer100g, 11.0);
      expect(result.proteinsPer100g, 9.0);
      expect(result.carbsPer100g, 20.0);
    });

    test('leaves calories null when only kJ is present, never guesses from kJ', () {
      const text = '''
Energy 837 kJ
Fat 10.0 g
''';
      final result = parseNutritionLabel(text);
      expect(result.caloriesPer100g, isNull);
      expect(result.fatPer100g, 10.0);
    });

    test('leaves unmatched fields null instead of guessing', () {
      const text = '''
Energy 1046 kJ / 250 kcal
Fat 12.5 g
''';
      final result = parseNutritionLabel(text);
      expect(result.caloriesPer100g, 250);
      expect(result.fatPer100g, 12.5);
      expect(result.proteinsPer100g, isNull);
      expect(result.carbsPer100g, isNull);
    });

    test('returns an empty result for unrelated or garbled text', () {
      const text = '''
Best before: 12/2027
Lot 4471A
''';
      final result = parseNutritionLabel(text);
      expect(result.isEmpty, isTrue);
    });

    test('picks up name and brand printed above the nutrition table', () {
      const text = '''
Chocolate Digestive Biscuits
Fine Foods Co
Nutrition Facts per 100g
Energy 1046 kJ / 250 kcal
Fat 12.5 g
Protein 8.0 g
Carbohydrate 24.0 g
''';
      final result = parseNutritionLabel(text);
      expect(result.name, 'Chocolate Digestive Biscuits');
      expect(result.brand, 'Fine Foods Co');
      expect(result.caloriesPer100g, 250);
    });

    test('leaves name/brand null when nothing usable precedes the table', () {
      const text = '''
Nutrition Facts per 100g
1234567890123
Energy 1046 kJ / 250 kcal
Fat 12.5 g
''';
      final result = parseNutritionLabel(text);
      expect(result.name, isNull);
      expect(result.brand, isNull);
      expect(result.caloriesPer100g, 250);
    });

    test('leaves name/brand null when no nutrition table is found at all', () {
      const text = '''
Some Random Photo
Of Something Else
''';
      final result = parseNutritionLabel(text);
      expect(result.name, isNull);
      expect(result.brand, isNull);
      expect(result.isEmpty, isTrue);
    });

    test('fills only name when a single usable header line precedes the table', () {
      const text = '''
Rye Bread
Wartość odżywcza w 100 g
Wartość energetyczna 1180 kJ / 282 kcal
Białko 6,2 g
''';
      final result = parseNutritionLabel(text);
      expect(result.name, 'Rye Bread');
      expect(result.brand, isNull);
      expect(result.caloriesPer100g, 282);
    });

    test('handles mg-unit lines without crossing nutrients (salt line ignored)', () {
      const text = '''
Energy 500 kJ / 119 kcal
Salt 0.5 g
Protein 3.0 g
''';
      final result = parseNutritionLabel(text);
      expect(result.caloriesPer100g, 119);
      expect(result.proteinsPer100g, 3.0);
      // "Salt" isn't one of our tracked nutrients — must not be picked up
      // as fat/carbs just because it's a number-bearing line in between.
      expect(result.fatPer100g, isNull);
      expect(result.carbsPer100g, isNull);
    });
  });
}
