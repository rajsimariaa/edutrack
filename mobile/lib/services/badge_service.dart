import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/models.dart';

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
}
