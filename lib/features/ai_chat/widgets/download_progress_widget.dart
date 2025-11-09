import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_provider.dart';

class DownloadProgressWidget extends StatefulWidget {
  const DownloadProgressWidget({super.key});

  @override
  State<DownloadProgressWidget> createState() =>
      _DownloadProgressWidgetState();
}

class _DownloadProgressWidgetState extends State<DownloadProgressWidget> {
  bool _agreedToWarning = false;

  Future<void> _startDownload() async {
    final provider = context.read<ChatProvider>();

    // Show experimental warning
    final agreed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.science, color: Colors.orange),
            const SizedBox(width: 8),
            const Text('Experimental Feature'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This AI assistant is:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('• Experimental and may produce errors'),
            const Text('• Runs 100% on your device'),
            const Text('• Requires ~1.6GB download'),
            const Text('• Not a substitute for medical/professional advice'),
            const SizedBox(height: 16),
            const Text(
              'All conversations stay private on your device.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );

    if (agreed == true) {
      setState(() => _agreedToWarning = true);
      await provider.downloadModel();

      // Auto-load after download
      if (provider.modelStatus == ModelStatus.downloaded) {
        await provider.loadModelIntoMemory();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        if (provider.modelStatus == ModelStatus.downloading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(value: provider.downloadProgress),
                const SizedBox(height: 24),
                Text(
                  'Downloading AI model...',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(provider.downloadProgress * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                const Text(
                  '~1.6 GB total',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Not downloaded - show intro
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology,
                    size: 80, color: Theme.of(context).primaryColor),
                const SizedBox(height: 24),
                Text(
                  'AI Nutrition Assistant',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Get personalized nutrition insights powered by on-device AI.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                Text(
                  '100% private - all processing happens on your device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _startDownload,
                  icon: const Icon(Icons.download),
                  label: const Text('Download AI Model (1.6 GB)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
