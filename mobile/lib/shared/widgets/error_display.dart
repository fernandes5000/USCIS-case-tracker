import 'package:flutter/material.dart';
import '../../app.dart';

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplay({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    String displayMessage = message;
    if (message.contains('SocketException') ||
        message.contains('Connection refused')) {
      displayMessage = l.connectionError;
    } else if (message.contains('401') || message.contains('Unauthorized')) {
      displayMessage = l.sessionExpired;
    } else if (message.contains('"error"')) {
      final match =
          RegExp(r'"error"\s*:\s*"([^"]+)"').firstMatch(message);
      if (match != null) displayMessage = match.group(1)!;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade700),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l.tryAgain),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
