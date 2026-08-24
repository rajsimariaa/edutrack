import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/env.dart';
import 'services/supabase_service.dart';
import 'services/reminder_service.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    debugPrint('Stack: $stack');
    return true;
  };

  try {
    await dotenv.load(fileName: 'assets/.env');
    debugPrint('ENV loaded: URL=${Env.supabaseUrl}');
    debugPrint('ENV loaded: Key prefix=${Env.supabaseAnonKey.substring(0, Env.supabaseAnonKey.length > 10 ? 10 : Env.supabaseAnonKey.length)}...');
  } catch (e) {
    debugPrint('ENV load failed: $e');
  }

  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('CRITICAL: Supabase init failed: $e');
  }

  try {
    await ReminderService().init();
    final granted = await ReminderService().requestPermissions();
    debugPrint('Notification permissions granted: $granted');
    // Re-schedule on every launch to survive app kills
    final enabled = await ReminderService().isEnabled();
    if (enabled) {
      final hour = await ReminderService().getReminderHour();
      final minute = await ReminderService().getReminderMinute();
      await ReminderService().setReminder(enabled: true, hour: hour, minute: minute);
    }
  } catch (e) {
    debugPrint('Reminder init failed: $e');
  }

  runApp(
    const ProviderScope(
      child: EduTrackApp(),
    ),
  );
}

class EduTrackApp extends ConsumerWidget {
  const EduTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'EduTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
