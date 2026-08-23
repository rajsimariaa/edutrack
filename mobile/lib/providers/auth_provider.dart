import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../services/services.dart';
import '../models/models.dart';
import 'service_providers.dart';

class AuthState {
  final supa.User? user;
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.profile,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    supa.User? user,
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _init();
  }

  final _controller = StreamController<AuthState>.broadcast();
  Stream<AuthState> get stream => _controller.stream;

  void _emit(AuthState newState) {
    state = newState;
    _controller.add(newState);
  }

  void _init() {
    final user = _authService.currentUser;
    if (user != null) {
      _emit(state.copyWith(user: user, isLoading: true));
      _loadProfile(user.id);
    }

    _authService.authStateChanges.listen((authState) {
      final event = authState.event;
      final session = authState.session;

      if (event == supa.AuthChangeEvent.signedIn && session != null) {
        _emit(state.copyWith(user: session.user, isLoading: true));
        _loadProfile(session.user.id);
      } else if (event == supa.AuthChangeEvent.signedOut) {
        _emit(AuthState());
      } else if (event == supa.AuthChangeEvent.tokenRefreshed && session != null) {
        _emit(state.copyWith(user: session.user));
      }
    });
  }

  Future<void> _loadProfile(String userId) async {
    try {
      final profile = await _authService.getProfile(userId);
      _emit(state.copyWith(profile: profile, isLoading: false));
    } catch (e) {
      _emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _emit(state.copyWith(isLoading: true, error: null));
    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      _emit(state.copyWith(isLoading: false));
    } catch (e) {
      _emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _emit(state.copyWith(isLoading: true, error: null));
    try {
      await _authService.signIn(email: email, password: password);
      _emit(state.copyWith(isLoading: false));
    } catch (e) {
      _emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      _emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> createProfile({
    required String examCategory,
    int? targetYear,
    String? institution,
    String? city,
  }) async {
    if (state.user == null) return;
    _emit(state.copyWith(isLoading: true));
    try {
      final profile = await _authService.createProfile(
        userId: state.user!.id,
        examCategory: examCategory,
        targetYear: targetYear,
        institution: institution,
        city: city,
      );
      _emit(state.copyWith(profile: profile, isLoading: false));
    } catch (e) {
      _emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (state.user == null) return;
    try {
      final profile = await _authService.updateProfile(
        userId: state.user!.id,
        updates: updates,
      );
      final updatedUser = _authService.currentUser;
      _emit(state.copyWith(profile: profile, user: updatedUser));
    } catch (e) {
      _emit(state.copyWith(error: e.toString()));
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});
