import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/services.dart';
import '../models/models.dart';

class AuthState {
  final User? user;
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
    User? user,
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

  void _init() {
    final user = _authService.currentUser;
    if (user != null) {
      state = state.copyWith(user: user);
      _loadProfile(user.id);
    }

    _authService.authStateChanges.listen((authState) {
      final event = authState.event;
      final session = authState.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        state = state.copyWith(user: session.user);
        _loadProfile(session.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        state = AuthState();
      } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        state = state.copyWith(user: session.user);
      }
    });
  }

  Future<void> _loadProfile(String userId) async {
    try {
      final profile = await _authService.getProfile(userId);
      state = state.copyWith(profile: profile);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signIn(email: email, password: password);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> createProfile({
    required String examCategory,
    int? targetYear,
    String? institution,
    String? city,
  }) async {
    if (state.user == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _authService.createProfile(
        userId: state.user!.id,
        examCategory: examCategory,
        targetYear: targetYear,
        institution: institution,
        city: city,
      );
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (state.user == null) return;
    try {
      final profile = await _authService.updateProfile(
        userId: state.user!.id,
        updates: updates,
      );
      state = state.copyWith(profile: profile);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});
