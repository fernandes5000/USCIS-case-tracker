import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../models/user.dart';

// Auth state
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Check for stored token
    final user = await _repository.tryRestoreSession();
    if (user != null) {
      state = AuthAuthenticated(user);
    } else {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final tokens = await _repository.login(email: email, password: password);
      state = AuthAuthenticated(tokens.user);
    } catch (e, st) {
      debugPrint('[Auth] Login error: $e\n$st');
      state = AuthError(_extractMessage(e));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AuthLoading();
    try {
      final tokens = await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      state = AuthAuthenticated(tokens.user);
    } catch (e, st) {
      debugPrint('[Auth] Register error: $e\n$st');
      state = AuthError(_extractMessage(e));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthUnauthenticated();
  }

  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }

  String _extractMessage(Object e) {
    final str = e.toString();
    if (str.contains('"error"')) {
      final match = RegExp(r'"error"\s*:\s*"([^"]+)"').firstMatch(str);
      if (match != null) return match.group(1)!;
    }
    if (str.contains('SocketException') || str.contains('Connection')) {
      return 'Could not connect to server. Check your connection.';
    }
    return 'An error occurred. Please try again.';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
