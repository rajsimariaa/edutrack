import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/services.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final syllabusServiceProvider = Provider<SyllabusService>((ref) {
  return SyllabusService();
});

final badgeServiceProvider = Provider<BadgeService>((ref) {
  return BadgeService();
});

final focusServiceProvider = Provider<FocusService>((ref) {
  return FocusService();
});

final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService();
});

final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService();
});

final testServiceProvider = Provider<TestService>((ref) {
  return TestService();
});

final resourceServiceProvider = Provider<ResourceService>((ref) {
  return ResourceService();
});
