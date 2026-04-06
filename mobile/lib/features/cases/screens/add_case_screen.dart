import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app.dart';
import '../providers/cases_provider.dart';

class AddCaseScreen extends ConsumerStatefulWidget {
  const AddCaseScreen({super.key});

  @override
  ConsumerState<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends ConsumerState<AddCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receiptController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _receiptController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(casesProvider.notifier).addCase(
            receiptNumber: _receiptController.text.trim().toUpperCase(),
            nickname: _nicknameController.text.trim().isEmpty
                ? null
                : _nicknameController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.caseAddedSuccess),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/cases');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_extractError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _extractError(String e) {
    final l = context.l10n;
    if (e.contains('already being tracked')) return l.alreadyTracked;
    if (e.contains('Invalid receipt')) return l.invalidReceiptFormat;
    if (e.contains('not found')) return l.caseNotFound;
    return l.failedToAdd;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.addCase),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cases'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoBanner(),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _receiptController,
                  decoration: InputDecoration(
                    labelText: l.receiptNumber,
                    hintText: l.receiptHint,
                    prefixIcon: const Icon(Icons.numbers_outlined),
                    helperText: l.receiptHelper,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  maxLength: 15,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l.receiptRequired;
                    final upper = v.trim().toUpperCase();
                    if (upper.length < 10) return l.receiptTooShort;
                    final prefix = upper.substring(0, 3);
                    final suffix = upper.substring(3);
                    if (!RegExp(r'^[A-Z]{3}$').hasMatch(prefix)) {
                      return l.receiptInvalidPrefix;
                    }
                    if (!RegExp(r'^\d+$').hasMatch(suffix)) {
                      return l.receiptInvalidSuffix;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: l.nicknameOptional,
                    hintText: l.nicknameHint,
                    prefixIcon: const Icon(Icons.label_outlined),
                  ),
                  maxLength: 50,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l.trackThisCase),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.receiptInfoBanner,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
