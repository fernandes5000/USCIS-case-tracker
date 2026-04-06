import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app.dart';
import '../providers/cases_provider.dart';
import '../models/case.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/error_display.dart';

class CasesScreen extends ConsumerWidget {
  const CasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final casesAsync = ref.watch(casesProvider);
    final authState = ref.watch(authProvider);

    final userName = authState is AuthAuthenticated
        ? authState.user.fullName.split(' ').first
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l.myCases),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outlined),
            onPressed: () => context.go('/profile'),
            tooltip: l.profile,
          ),
        ],
      ),
      body: casesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorDisplay(
          message: error.toString(),
          onRetry: () => ref.read(casesProvider.notifier).load(),
        ),
        data: (cases) => cases.isEmpty
            ? _EmptyState(onAdd: () => context.go('/cases/add'))
            : RefreshIndicator(
                onRefresh: () => ref.read(casesProvider.notifier).load(),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          l.hello(userName),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList.builder(
                        itemCount: cases.length,
                        itemBuilder: (context, i) =>
                            _CaseCard(userCase: cases[i]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/cases/add'),
        icon: const Icon(Icons.add),
        label: Text(l.addCase),
      ),
    );
  }
}

class _CaseCard extends ConsumerWidget {
  final UserCase userCase;
  const _CaseCard({required this.userCase});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/cases/${userCase.receiptNumber}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userCase.nickname != null)
                      Text(
                        userCase.nickname!,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    Text(
                      userCase.receiptNumber,
                      style: TextStyle(
                        fontSize: userCase.nickname != null ? 13 : 15,
                        fontWeight: userCase.nickname != null
                            ? FontWeight.normal
                            : FontWeight.w600,
                        color: userCase.nickname != null
                            ? Colors.grey.shade600
                            : null,
                        letterSpacing: 1,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined,
                size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              l.noCasesYet,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l.noCasesSubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(l.addFirstCase),
            ),
          ],
        ),
      ),
    );
  }
}
