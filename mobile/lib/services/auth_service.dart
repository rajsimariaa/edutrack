import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'supabase_service.dart';
import '../models/models.dart';

class AuthService {
  supa.SupabaseClient get _supabase => SupabaseService.client;

  supa.User? get currentUser => _supabase.auth.currentUser;
  Stream<supa.AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<supa.AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
      emailRedirectTo: 'io.supabase.edutrack://login-callback/',
    );
    return response;
  }

  Future<supa.AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<UserProfile?> getProfile(String userId) async {
    final data = await _supabase
        .from('user_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> createProfile({
    required String userId,
    required String examCategory,
    int? targetYear,
    String? institution,
    String? city,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final data = await _supabase
        .from('user_profiles')
        .upsert({
          'user_id': userId,
          'exam_category': examCategory,
          'target_year': targetYear,
          'institution': institution,
          'city': city,
        }, onConflict: 'user_id')
        .select()
        .single();
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    final profileUpdates = Map<String, dynamic>.from(updates);
    final fullName = profileUpdates.remove('full_name');

    if (fullName != null && fullName.toString().isNotEmpty) {
      await _supabase.auth.updateUser(
        UserAttributes(data: {'full_name': fullName}),
      );
    }

    final data = await _supabase
        .from('user_profiles')
        .update({...profileUpdates, 'updated_at': DateTime.now().toIso8601String()})
        .eq('user_id', userId)
        .select()
        .single();
    return UserProfile.fromJson(data);
  }
}
