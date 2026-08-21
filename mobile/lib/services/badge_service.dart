import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/models.dart';
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

      if (criteria.containsKey('focus_hours')) {
        final hours = await FocusService().getTotalFocusHours(userId);
        earned = hours >= (criteria['focus_hours'] as num).toDouble();
      } else if (criteria.containsKey('tests_completed')) {
        final subs = await TestService().getUserSubmissions(userId);
        earned = subs.length >= (criteria['tests_completed'] as num).toInt();
      } else if (criteria.containsKey('streak_days')) {
        final heatmap = await GamificationService().getHeatmapData(userId, startDate: DateTime.now().subtract(const Duration(days: 365)));
        int streak = 0;
        final today = DateTime.now();
        for (int i = 0; i < 365; i++) {
          final date = today.subtract(Duration(days: i));
          final hasEntry = heatmap.any((h) =>
              h.activityDate.year == date.year &&
              h.activityDate.month == date.month &&
              h.activityDate.day == date.day);
          if (hasEntry) {
            streak++;
          } else if (i > 0) {
            break;
          }
        }
        earned = streak >= (criteria['streak_days'] as num).toInt();
      } else if (criteria.containsKey('topics_mastered')) {
        final progress = await SyllabusService().getUserProgress(userId);
        int mastered = progress.where((p) => p.status == TopicStatus.mastered).length;
        earned = mastered >= (criteria['topics_mastered'] as num).toInt();
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
