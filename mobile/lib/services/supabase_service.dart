import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

class SupabaseService {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase not initialized');
    }
    return Supabase.instance.client;
  }

  static Future<void> initialize() async {
    if (_initialized) return;

    final url = Env.supabaseUrl;
    final anonKey = Env.supabaseAnonKey;

    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception('Supabase URL or anon key is empty. Check assets/.env');
    }

    debugPrint('Supabase initializing with URL: $url');
    debugPrint('Anon key prefix: ${anonKey.substring(0, anonKey.length > 15 ? 15 : anonKey.length)}...');

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );

    _initialized = true;
    debugPrint('Supabase initialized successfully');
  }

  User? get currentUser => _initialized ? Supabase.instance.client.auth.currentUser : null;
  Session? get currentSession => _initialized ? Supabase.instance.client.auth.currentSession : null;
  bool get isAuthenticated => currentUser != null;
}
