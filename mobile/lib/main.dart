import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/env.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    return true;
  };

  await dotenv.load(fileName: 'assets/.env');

  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase init failed: $e');
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
