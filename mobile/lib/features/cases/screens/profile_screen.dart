import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final authState = ref.watch(authProvider);
    final currentLocale = ref.watch(localeProvider);
    final currentTheme = ref.watch(themeProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.profile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cases'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      user?.fullName.isNotEmpty == true
                          ? user!.fullName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? '',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Theme selector
          Text(
            l.appearance,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _ThemeTile(
                  label: l.themeSystem,
                  icon: Icons.brightness_auto_outlined,
                  mode: ThemeMode.system,
                  currentMode: currentTheme,
                  onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.system),
                ),
                const Divider(height: 1, indent: 16),
                _ThemeTile(
                  label: l.themeLight,
                  icon: Icons.light_mode_outlined,
                  mode: ThemeMode.light,
                  currentMode: currentTheme,
                  onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.light),
                ),
                const Divider(height: 1, indent: 16),
                _ThemeTile(
                  label: l.themeDark,
                  icon: Icons.dark_mode_outlined,
                  mode: ThemeMode.dark,
                  currentMode: currentTheme,
                  onTap: () => ref.read(themeProvider.notifier).setTheme(ThemeMode.dark),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Language selector
          Text(
            l.language,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _LanguageTile(
                  label: l.languageEnglish,
                  locale: const Locale('en'),
                  currentLocale: currentLocale,
                  onTap: () =>
                      ref.read(localeProvider.notifier).setLocale(const Locale('en')),
                ),
                const Divider(height: 1, indent: 16),
                _LanguageTile(
                  label: l.languagePortuguese,
                  locale: const Locale('pt'),
                  currentLocale: currentLocale,
                  onTap: () =>
                      ref.read(localeProvider.notifier).setLocale(const Locale('pt')),
                ),
                const Divider(height: 1, indent: 16),
                _LanguageTile(
                  label: l.languageSpanish,
                  locale: const Locale('es'),
                  currentLocale: currentLocale,
                  onTap: () =>
                      ref.read(localeProvider.notifier).setLocale(const Locale('es')),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About
          Text(
            l.about,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outlined),
                  title: Text(l.version),
                  trailing: Text('1.0.0',
                      style: TextStyle(color: Colors.grey.shade500)),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.security_outlined),
                  title: Text(l.privacyPolicy),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l.signOut),
                  content: Text(l.signOutConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(l.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(l.signOut),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(authProvider.notifier).logout();
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            icon: const Icon(Icons.logout),
            label: Text(l.signOut),
          ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final ThemeMode mode;
  final ThemeMode currentMode;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.label,
    required this.icon,
    required this.mode,
    required this.currentMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentMode == mode;
    return ListTile(
      leading: Icon(icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String label;
  final Locale locale;
  final Locale currentLocale;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.label,
    required this.locale,
    required this.currentLocale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentLocale.languageCode == locale.languageCode;
    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
