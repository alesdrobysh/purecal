import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import '../models/meal_type.dart';
import '../services/diary_provider.dart';
import 'package:foodiefit/screens/quick_add_screen.dart';

import '../screens/search_screen.dart';
import 'custom_input_decoration.dart';

class MealSection extends StatefulWidget {
  final MealType mealType;
  final bool initiallyExpanded;

  const MealSection({
    super.key,
    required this.mealType,
    this.initiallyExpanded = false,
  });

  @override
  State<MealSection> createState() => _MealSectionState();
}

class _MealSectionState extends State<MealSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _openSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SearchScreen(preselectedMealType: widget.mealType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiaryProvider>(
      builder: (context, provider, child) {
        final entries = provider.getEntriesByMealType(widget.mealType);
        final calories = provider.getMealCalories(widget.mealType);
        final count = entries.length;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        widget.mealType.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.mealType.displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (count > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                '$count ${count == 1 ? 'item' : 'items'} • ${calories.toStringAsFixed(0)} kcal',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => _openSearch(context),
                        icon: const Icon(Icons.add),
                        tooltip: 'Add product',
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isExpanded) ...[
                const Divider(
                    height: 1, indent: 16, endIndent: 16, thickness: 0.5),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No items for ${widget.mealType.displayName.toLowerCase()} yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap the + button to add',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _buildEntryCard(context, entry, provider);
                    },
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEntryCard(
      BuildContext context, DiaryEntry entry, DiaryProvider provider) {
    return Card(
      elevation: 0,
      child: InkWell(
        onLongPress: () => _showEntryOptions(context, entry, provider),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (entry.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    entry.imageUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderImage(),
                  ),
                )
              else
                _buildPlaceholderImage(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.portionGrams.toStringAsFixed(0)}g • ${entry.calories.toStringAsFixed(0)} kcal',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'P: ${entry.proteins.toStringAsFixed(1)}g • '
                      'F: ${entry.fat.toStringAsFixed(1)}g • '
                      'C: ${entry.carbs.toStringAsFixed(1)}g',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.fastfood, color: Colors.grey[500], size: 24),
    );
  }

  void _showEntryOptions(
      BuildContext context, DiaryEntry entry, DiaryProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Portion'),
              onTap: () {
                Navigator.pop(context);
                _editEntryPortion(context, entry, provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Change Meal'),
              onTap: () {
                Navigator.pop(context);
                _changeEntryMeal(context, entry, provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteEntry(context, entry, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editEntryPortion(
      BuildContext context, DiaryEntry entry, DiaryProvider provider) {
    final controller =
        TextEditingController(text: entry.portionGrams.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Portion'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: customInputDecoration(context).copyWith(
            labelText: 'Portion (grams)',
            suffixText: 'g',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newPortion = double.tryParse(controller.text);
              if (newPortion != null && newPortion > 0) {
                provider.updateEntry(entry, newPortion);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _changeEntryMeal(
      BuildContext context, DiaryEntry entry, DiaryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: MealType.values.map((mealType) {
            return ListTile(
              leading: Text(
                mealType.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(mealType.displayName),
              selected: entry.mealType == mealType,
              onTap: () {
                if (entry.id != null) {
                  provider.changeEntryMealType(entry.id!, mealType);
                }
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _deleteEntry(
      BuildContext context, DiaryEntry entry, DiaryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Delete ${entry.productName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (entry.id != null) {
                provider.deleteEntry(entry.id!);
              }
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
