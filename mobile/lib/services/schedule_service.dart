import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/models.dart';

class ScheduleService {
  final _supabase = SupabaseService.instance.client;

  Future<Schedule?> getActiveSchedule(String userId) async {
    final data = await _supabase
        .from('schedules')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .maybeSingle();
    if (data == null) return null;
    return Schedule.fromJson(data);
  }

  Future<Schedule> createSchedule({
    required String userId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final data = await _supabase
        .from('schedules')
        .insert({
          'user_id': userId,
          'title': title,
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
        })
        .select()
        .single();
    return Schedule.fromJson(data);
  }

  Future<List<ScheduleItem>> getScheduleItems(
    String scheduleId, {
    DateTime? date,
  }) async {
    var query = _supabase
        .from('schedule_items')
        .select()
        .eq('schedule_id', scheduleId)
        .order('scheduled_date')
        .order('start_time');
    if (date != null) {
      query = query.eq(
          'scheduled_date', date.toIso8601String().split('T')[0]);
    }
    final data = await query;
    return (data as List).map((e) => ScheduleItem.fromJson(e)).toList();
  }

  Future<ScheduleItem> createScheduleItem({
    required String scheduleId,
    String? topicId,
    required String title,
    required DateTime scheduledDate,
    String? startTime,
    String? endTime,
    int priority = 1,
  }) async {
    final data = await _supabase
        .from('schedule_items')
        .insert({
          'schedule_id': scheduleId,
          'topic_id': topicId,
          'title': title,
          'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
          'start_time': startTime,
          'end_time': endTime,
          'priority': priority,
        })
        .select()
        .single();
    return ScheduleItem.fromJson(data);
  }

  Future<void> updateItemStatus(String itemId, ScheduleItemStatus status) async {
    await _supabase.from('schedule_items').update({
      'status': scheduleItemStatusToString(status),
    }).eq('id', itemId);
  }

  Future<void> rescheduleItem(String itemId, DateTime newDate) async {
    final existing = await _supabase
        .from('schedule_items')
        .select()
        .eq('id', itemId)
        .single();

    await _supabase.from('schedule_items').update({
      'scheduled_date': newDate.toIso8601String().split('T')[0],
      'status': 'rescheduled',
      'original_date': existing['scheduled_date'],
    }).eq('id', itemId);
  }

  Future<List<ScheduleItem>> getMissedItems(String scheduleId) async {
    final data = await _supabase
        .from('schedule_items')
        .select()
        .eq('schedule_id', scheduleId)
        .eq('status', 'missed')
        .order('scheduled_date');
    return (data as List).map((e) => ScheduleItem.fromJson(e)).toList();
  }
}
