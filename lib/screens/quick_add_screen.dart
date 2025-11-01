import 'package:flutter/material.dart';
import 'package:foodiefit/models/meal_type.dart';
import 'package:foodiefit/services/diary_provider.dart';
import 'package:provider/provider.dart';

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
              Text('Added $_productName to ${_selectedMealType.displayName}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Add'),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
                onSaved: (value) => _productName = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => _calories = double.parse(value!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Proteins (g)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _proteins = double.tryParse(value!) ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Fat (g)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _fat = double.tryParse(value!) ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Carbs (g)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _carbs = double.tryParse(value!) ?? 0,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MealType>(
                value: _selectedMealType,
                decoration: const InputDecoration(
                  labelText: 'Meal Type',
                  border: OutlineInputBorder(),
                ),
                items: MealType.values.map((mealType) {
                  return DropdownMenuItem(
                    value: mealType,
                    child: Text(mealType.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMealType = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitForm,
        child: const Icon(Icons.check),
      ),
    );
  }
}
