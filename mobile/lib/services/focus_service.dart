import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/models.dart';

class FocusService {
  final _supabase = SupabaseService.instance.client;

  Future<PomodoroSession> startPomodoro({
    required String userId,
    String? topicId,
    String? chapterId,
    int durationMins = 25,
  }) async {
    final data = await _supabase
        .from('pomodoro_sessions')
        .insert({
          'user_id': userId,
          'topic_id': topicId,
          'chapter_id': chapterId,
          'duration_mins': durationMins,
          'started_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();
    return PomodoroSession.fromJson(data);
  }

  Future<PomodoroSession> completePomodoro(String sessionId) async {
    final data = await _supabase
        .from('pomodoro_sessions')
        .update({
          'status': 'completed',
          'ended_at': DateTime.now().toIso8601String(),
        })
        .eq('id', sessionId)
        .select()
        .single();
    return PomodoroSession.fromJson(data);
  }

  Future<List<PomodoroSession>> getUserSessions(
    String userId, {
    int limit = 50,
  }) async {
    final data = await _supabase
        .from('pomodoro_sessions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => PomodoroSession.fromJson(e)).toList();
  }

  Future<double> getTotalFocusHours(String userId) async {
    final data = await _supabase
        .from('pomodoro_sessions')
        .select('duration_mins')
        .eq('user_id', userId)
        .eq('status', 'completed');

    final totalMins = (data as List)
        .fold<int>(0, (sum, e) => sum + (e['duration_mins'] as int));
    return totalMins / 60.0;
  }

  Future<List<Note>> getNotes(String userId, {String? chapterId}) async {
    var query = _supabase
        .from('notes')
        .select()
        .eq('user_id', userId);
    if (chapterId != null) {
      query = query.eq('chapter_id', chapterId);
    }
    final data = await query.order('updated_at', ascending: false);
    return (data as List).map((e) => Note.fromJson(e)).toList();
  }

  Future<Note> createNote({
    required String userId,
    required String chapterId,
    String? topicId,
    String? title,
    String contentMd = '',
  }) async {
    final data = await _supabase
        .from('notes')
        .insert({
          'user_id': userId,
          'chapter_id': chapterId,
          'topic_id': topicId,
          'title': title,
          'content_md': contentMd,
        })
        .select()
        .single();
    return Note.fromJson(data);
  }

  Future<Note> updateNote({
    required String noteId,
    String? title,
    String? contentMd,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (title != null) updates['title'] = title;
    if (contentMd != null) updates['content_md'] = contentMd;

    final data = await _supabase
        .from('notes')
        .update(updates)
        .eq('id', noteId)
        .select()
        .single();
    return Note.fromJson(data);
  }

  Future<void> deleteNote(String noteId) async {
    await _supabase.from('notes').delete().eq('id', noteId);
  }

  Future<List<Habit>> getHabits(String userId) async {
    final data = await _supabase
        .from('habits')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Habit.fromJson(e)).toList();
  }

  Future<Habit> createHabit({
    required String userId,
    required String name,
    String frequency = 'daily',
    int targetCount = 1,
  }) async {
    final data = await _supabase
        .from('habits')
        .insert({
          'user_id': userId,
          'name': name,
          'frequency': frequency,
          'target_count': targetCount,
        })
        .select()
        .single();
    return Habit.fromJson(data);
  }

  Future<void> checkInHabit({
    required String habitId,
    String? note,
  }) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await _supabase.from('habit_entries').upsert({
      'habit_id': habitId,
      'checkin_date': today,
      'count': 1,
      'note': note,
    });
  }

  Future<List<HabitEntry>> getHabitEntries(
    String habitId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _supabase
        .from('habit_entries')
        .select()
        .eq('habit_id', habitId);
    if (startDate != null) {
      query = query.gte('checkin_date', startDate.toIso8601String().split('T')[0]);
    }
    if (endDate != null) {
      query = query.lte('checkin_date', endDate.toIso8601String().split('T')[0]);
    }
    final data = await query.order('checkin_date', ascending: false);
    return (data as List).map((e) => HabitEntry.fromJson(e)).toList();
  }
}
