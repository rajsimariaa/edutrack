import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/models.dart';
import '../utils/streak_utils.dart';
import 'focus_service.dart';
import 'test_service.dart';
import 'syllabus_service.dart';
import 'gamification_service.dart';

class BadgeService {
  final _supabase = SupabaseService.client;

  Future<List<Badge>> getAllBadges() async {
    final data = await _supabase
        .from('badges')
        .select()
        .eq('is_active', true)
        .order('points');
    return (data as List).map((e) => Badge.fromJson(e)).toList();
  }

  Future<List<UserBadge>> getUserBadges(String userId) async {
    final data = await _supabase
        .from('user_badges')
        .select()
        .eq('user_id', userId)
        .order('unlocked_at', ascending: false);
    return (data as List).map((e) => UserBadge.fromJson(e)).toList();
  }

  Future<List<UserBadge>> getPinnedBadges(String userId) async {
    final data = await _supabase
        .from('user_badges')
        .select()
        .eq('user_id', userId)
        .eq('is_pinned', true)
        .order('pin_order');
    return (data as List).map((e) => UserBadge.fromJson(e)).toList();
  }

  Future<void> pinBadge(String userId, String badgeId, int pinOrder) async {
    await _supabase
        .from('user_badges')
        .update({'is_pinned': true, 'pin_order': pinOrder})
        .eq('user_id', userId)
        .eq('badge_id', badgeId);
  }

  Future<void> unpinBadge(String userId, String badgeId) async {
    await _supabase
        .from('user_badges')
        .update({'is_pinned': false, 'pin_order': null})
        .eq('user_id', userId)
        .eq('badge_id', badgeId);
  }

  Future<List<UserMilestone>> getUserMilestones(String userId) async {
    final data = await _supabase
        .from('user_milestones')
        .select()
        .eq('user_id', userId)
        .order('unlocked_at', ascending: false);
    return (data as List).map((e) => UserMilestone.fromJson(e)).toList();
  }

  Future<void> evaluateAndAwardBadges(String userId) async {
    final badges = await getAllBadges();
    final userBadges = await getUserBadges(userId);
    final earnedBadgeIds = userBadges.map((ub) => ub.badgeId).toSet();

    for (final badge in badges) {
      if (earnedBadgeIds.contains(badge.id)) continue;

      final criteria = badge.criteriaJson;
      bool earned = false;

      final type = criteria['type'] as String?;
      final count = (criteria['count'] as num?)?.toInt() ?? 0;

      if (type == 'focus_sessions') {
        final subs = await FocusService().getUserSessions(userId);
        final completed = subs.where((s) => s.status == 'completed').length;
        earned = completed >= count;
      } else if (type == 'tests_completed') {
        final subs = await TestService().getUserSubmissions(userId);
        earned = subs.length >= count;
      } else if (type == 'streak') {
        final heatmap = await GamificationService().getHeatmapData(userId, startDate: DateTime.now().subtract(const Duration(days: 365)));
        final streak = StreakUtils.computeCurrentStreak(heatmap);
        earned = streak >= count;
      } else if (type == 'perfect_score') {
        final subs = await TestService().getUserSubmissions(userId);
        earned = subs.any((s) => (s.score as num?)?.toDouble() == 100.0);
      } else if (type == 'topics_mastered') {
        final progress = await SyllabusService().getUserProgress(userId);
        int mastered = progress.where((p) => p.status == TopicStatus.mastered).length;
        earned = mastered >= count;
      } else if (type == 'fast_test') {
        final subs = await TestService().getUserSubmissions(userId);
        earned = subs.any((s) => (s.timeTakenMins as num?)?.toInt() != null && (s.timeTakenMins as num) <= 10);
      } else if (type == 'join_room') {
        final rooms = await GamificationService().getPeerRooms(userId);
        earned = rooms.isNotEmpty;
      }

      if (earned) {
        await _supabase.from('user_badges').upsert({
          'user_id': userId,
          'badge_id': badge.id,
        });
      }
    }
  }

  Future<int> unlockBadge(String userId, String badgeId) async {
    final existing = await _supabase
        .from('user_badges')
        .select('pin_order')
        .eq('user_id', userId)
        .eq('badge_id', badgeId)
        .maybeSingle();
    if (existing != null) return 0;

    await _supabase.from('user_badges').insert({
      'user_id': userId,
      'badge_id': badgeId,
    });
    return 1;
  }
}
