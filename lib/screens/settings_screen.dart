import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/diary_provider.dart';
import 'local_products_list_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('My Products'),
          _buildMyProductsOption(context),
          const Divider(),
          _buildSectionHeader('Data Management'),
          _buildClearCacheOption(context),
          const Divider(),
          _buildSectionHeader('About'),
          _buildAboutOption(context),
          _buildOFFAttribution(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildMyProductsOption(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.inventory_2, color: Colors.blue),
      title: const Text('My Products'),
      subtitle: const Text('Manage your custom products'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LocalProductsListScreen(),
          ),
        );
      },
    );
  }

  Widget _buildClearCacheOption(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete_sweep, color: Colors.orange),
      title: const Text('Clear Frequent Products Cache'),
      subtitle: const Text('Remove all frequently used products history'),
      onTap: () => _showClearCacheDialog(context),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'Are you sure you want to clear your frequent products cache? '
          'This will remove all usage history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final provider = Provider.of<DiaryProvider>(context, listen: false);
              await provider.clearFrequentProductsCache();

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Frequent products cache cleared'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutOption(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline, color: Colors.blue),
      title: const Text('App Version'),
      subtitle: const Text('FoodieFit v1.0.0'),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: 'FoodieFit',
          applicationVersion: '1.0.0',
          applicationIcon: const Icon(Icons.restaurant, size: 48, color: Colors.green),
          children: [
            const Text(
              'A food diary app to track your daily nutrition and reach your goals.',
            ),
          ],
        );
      },
    );
  }

  Widget _buildOFFAttribution(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.public, color: Colors.green),
      title: const Text('Open Food Facts'),
      subtitle: const Text('Product data provided by Open Food Facts'),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Open Food Facts'),
            content: const Text(
              'This app uses product data from Open Food Facts, '
              'a collaborative, free and open database of food products from around the world.\n\n'
              'Visit: https://world.openfoodfacts.org',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
}
