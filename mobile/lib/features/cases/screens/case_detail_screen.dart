import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app.dart';
import '../providers/cases_provider.dart';
import '../models/case.dart';
import '../../../shared/widgets/error_display.dart';

class CaseDetailScreen extends ConsumerWidget {
  final String receiptNumber;
  const CaseDetailScreen({super.key, required this.receiptNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final caseAsync = ref.watch(caseStatusProvider(receiptNumber));

    return Scaffold(
      appBar: AppBar(
        title: Text(receiptNumber),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cases'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(caseStatusProvider(receiptNumber)),
            tooltip: l.refresh,
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                _showEditNicknameDialog(context, ref, caseAsync.valueOrNull);
              } else if (value == 'delete') {
                _confirmDelete(context, ref);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(l.editNickname),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: const Icon(Icons.delete_outlined, color: Colors.red),
                  title: Text(l.removeCase,
                      style: const TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: caseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorDisplay(
          message: error.toString(),
          onRetry: () => ref.invalidate(caseStatusProvider(receiptNumber)),
        ),
        data: (caseData) => _CaseDetailBody(caseData: caseData),
      ),
    );
  }

  void _showEditNicknameDialog(
    BuildContext context,
    WidgetRef ref,
    CaseWithStatus? currentData,
  ) {
    final l = context.l10n;
    final controller = TextEditingController(text: currentData?.nickname);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.editNickname),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l.nickname,
            hintText: l.nicknamePlaceholder,
          ),
          maxLength: 50,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(casesProvider.notifier).updateCase(
                      receiptNumber: receiptNumber,
                      nickname: controller.text.trim().isEmpty
                          ? null
                          : controller.text.trim(),
                    );
                ref.invalidate(caseStatusProvider(receiptNumber));
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('${context.l10n.failedToUpdate}: $e')),
                  );
                }
              }
            },
            child: Text(l.save),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.removeCase),
        content: Text(l.removeCaseConfirm(receiptNumber)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(casesProvider.notifier)
                    .deleteCase(receiptNumber);
                if (context.mounted) context.go('/cases');
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('${context.l10n.failedToRemove}: $e')),
                  );
                }
              }
            },
            child: Text(l.remove),
          ),
        ],
      ),
    );
  }
}

class _CaseDetailBody extends StatelessWidget {
  final CaseWithStatus caseData;
  const _CaseDetailBody({required this.caseData});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final status = caseData.uscisData?.currentStatus;
    final history = caseData.uscisData?.history ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (caseData.nickname != null) ...[
                  Text(caseData.nickname!,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    const Icon(Icons.tag, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      caseData.receiptNumber,
                      style: const TextStyle(
                          fontFamily: 'monospace',
                          letterSpacing: 1.2,
                          color: Colors.grey),
                    ),
                  ],
                ),
                if (caseData.uscisData?.formType != null) ...[
                  const SizedBox(height: 8),
                  _InfoChip(
                    icon: Icons.article_outlined,
                    label: 'Form ${caseData.uscisData!.formType}',
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (status != null) ...[
          _SectionHeader(title: l.currentStatus),
          const SizedBox(height: 8),
          _StatusCard(status: status),
          const SizedBox(height: 16),
        ] else if (caseData.uscisData == null) ...[
          _NoDataCard(),
          const SizedBox(height: 16),
        ],
        if (history.isNotEmpty) ...[
          _SectionHeader(
            title: l.caseHistory,
            subtitle: l.caseHistoryCount(history.length),
          ),
          const SizedBox(height: 8),
          _HistoryTimeline(events: history),
        ],
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final CaseStatus status;
  const _StatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status.description ?? '',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                        fontSize: 15),
                  ),
                ),
              ],
            ),
            if (status.statusDate != null) ...[
              const SizedBox(height: 8),
              Text(_formatDate(status.statusDate!),
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600)),
            ],
            if (status.externalText != null) ...[
              const Divider(height: 24),
              Text(status.externalText!,
                  style: const TextStyle(fontSize: 13, height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryTimeline extends StatelessWidget {
  final List<CaseHistoryEvent> events;
  const _HistoryTimeline({required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: events.asMap().entries.map((entry) {
        final i = entry.key;
        final event = entry.value;
        final isFirst = i == 0;
        final isLast = i == events.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFirst
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade400,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.grey.shade300,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 12, bottom: isLast ? 0 : 16, top: 8),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (event.date != null)
                            Text(
                              _formatDate(event.date!),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500),
                            ),
                          if (event.description != null) ...[
                            const SizedBox(height: 4),
                            Text(event.description!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                          if (event.externalText != null) ...[
                            const SizedBox(height: 6),
                            Text(event.externalText!,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    height: 1.4)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _NoDataCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(l.statusUnavailable,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(l.statusUnavailableSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(subtitle!,
              style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      ],
    );
  }
}

String _formatDate(String raw) {
  try {
    final dt = DateTime.parse(raw);
    return DateFormat('MMM d, yyyy').format(dt);
  } catch (_) {
    return raw;
  }
}
