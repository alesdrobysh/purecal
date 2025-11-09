import 'package:flutter/material.dart';
import 'package:foodiefit/models/meal_type.dart';
import 'package:foodiefit/services/diary_provider.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_input_decoration.dart';
import '../config/decorations.dart';
import '../config/custom_colors.dart';
import '../widgets/branded_app_bar.dart';

class QuickAddScreen extends StatefulWidget {
  final MealType? mealType;

  const QuickAddScreen({super.key, this.mealType});

  @override
  State<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends State<QuickAddScreen> {
  final _formKey = GlobalKey<FormState>();
  late MealType _selectedMealType;

  String _productName = '';
  double _calories = 0;
  double _proteins = 0;
  double _fat = 0;
  double _carbs = 0;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.mealType ?? MealType.fromTime(DateTime.now());
  }

  Future<void> _submitForm() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await Provider.of<DiaryProvider>(context, listen: false).addQuickEntry(
        productName: _productName,
        calories: _calories,
        proteins: _proteins,
        fat: _fat,
        carbs: _carbs,
        mealType: _selectedMealType,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(l10n.addedProductToMeal(_productName, _selectedMealType.displayName(context))),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: BrandedAppBar(
        title: '${l10n.quickAdd} - ${_selectedMealType.displayName(context)}',
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16.0,
            children: [
              TextFormField(
                decoration: customInputDecoration(context).copyWith(labelText: l10n.productName),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterProductName;
                  }
                  return null;
                },
                onSaved: (value) => _productName = value!,
              ),
              TextFormField(
                decoration: customInputDecoration(context).copyWith(labelText: l10n.calories),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return l10n.pleaseEnterValidNumber;
                  }
                  return null;
                },
                onSaved: (value) => _calories = double.parse(value!),
              ),
              TextFormField(
                decoration: customInputDecoration(context).copyWith(labelText: '${l10n.protein} (${l10n.grams})'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _proteins = double.tryParse(value!) ?? 0,
              ),
              TextFormField(
                decoration: customInputDecoration(context).copyWith(labelText: '${l10n.fat} (${l10n.grams})'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _fat = double.tryParse(value!) ?? 0,
              ),
              TextFormField(
                decoration: customInputDecoration(context).copyWith(labelText: '${l10n.carbs} (${l10n.grams})'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _carbs = double.tryParse(value!) ?? 0,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submitForm,
        icon: const Icon(Icons.check),
        label: Text(l10n.save),
      ),
    );
  }
}
