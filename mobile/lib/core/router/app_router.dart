import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/cases/screens/cases_screen.dart';
import '../../features/cases/screens/add_case_screen.dart';
import '../../features/cases/screens/case_detail_screen.dart';
import '../../features/cases/screens/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState is AuthAuthenticated;
      final isInitializing = authState is AuthInitial || authState is AuthLoading;

      // Still loading initial auth state
      if (isInitializing && authState is AuthInitial) return null;

      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/cases';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/cases',
        builder: (_, __) => const CasesScreen(),
      ),
      GoRoute(
        path: '/cases/add',
        builder: (_, __) => const AddCaseScreen(),
      ),
      GoRoute(
        path: '/cases/:receiptNumber',
        builder: (_, state) => CaseDetailScreen(
          receiptNumber: state.pathParameters['receiptNumber']!,
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

/// A ChangeNotifier that triggers GoRouter refresh on auth state changes
class _AuthListenable extends ChangeNotifier {
  final Ref _ref;
  late final ProviderSubscription _sub;

  _AuthListenable(this._ref) {
    _sub = _ref.listen(authProvider, (_, __) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
