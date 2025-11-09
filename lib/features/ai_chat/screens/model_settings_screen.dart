import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_provider.dart';

class ModelSettingsScreen extends StatelessWidget {
  const ModelSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Model Settings'),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Model Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildStatusRow(
                        'Status',
                        _getStatusText(provider.modelStatus),
                      ),
                      if (provider.modelStatus == ModelStatus.loaded)
                        _buildStatusRow('Memory Usage', '~1.2 GB'),
                      if (provider.modelStatus == ModelStatus.downloading)
                        _buildStatusRow(
                          'Download Progress',
                          '${(provider.downloadProgress * 100).toStringAsFixed(1)}%',
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (provider.modelStatus == ModelStatus.loaded)
                        ListTile(
                          leading: const Icon(Icons.delete_outline),
                          title: const Text('Unload Model'),
                          subtitle: const Text('Free memory (model stays on disk)'),
                          onTap: () async {
                            await provider.unloadModel();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Model unloaded from memory'),
                                ),
                              );
                            }
                          },
                        ),
                      if (provider.modelStatus == ModelStatus.downloaded)
                        ListTile(
                          leading: const Icon(Icons.play_arrow),
                          title: const Text('Load Model'),
                          subtitle: const Text('Load into memory for use'),
                          onTap: () => provider.loadModelIntoMemory(),
                        ),
                      if (provider.modelStatus == ModelStatus.downloaded ||
                          provider.modelStatus == ModelStatus.loaded)
                        ListTile(
                          leading: const Icon(Icons.delete_forever),
                          title: const Text('Delete Model'),
                          subtitle: const Text('Remove from device (~1.6 GB freed)'),
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete AI Model'),
                                content: const Text(
                                  'This will delete the downloaded model and clear all chat history. You can re-download it later.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await provider.deleteModel();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Model deleted'),
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      const Text('Model: Qwen2.5-1.5B-Instruct'),
                      const SizedBox(height: 8),
                      const Text('Size: ~1.6 GB'),
                      const SizedBox(height: 8),
                      const Text('Runs 100% on your device'),
                      const SizedBox(height: 8),
                      const Text('All conversations are private'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getStatusText(ModelStatus status) {
    switch (status) {
      case ModelStatus.notDownloaded:
        return 'Not Downloaded';
      case ModelStatus.downloading:
        return 'Downloading...';
      case ModelStatus.downloaded:
        return 'Downloaded (Not Loaded)';
      case ModelStatus.loading:
        return 'Loading...';
      case ModelStatus.loaded:
        return 'Loaded';
      case ModelStatus.error:
        return 'Error';
    }
  }
}
