import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/models.dart';

class GamificationService {
  final _supabase = SupabaseService.client;

  Future<List<HeatmapEntry>> getHeatmapData(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _supabase
        .from('heatmap_entries')
        .select()
        .eq('user_id', userId);

    if (startDate != null) {
      query = query.gte('activity_date', startDate.toIso8601String().split('T')[0]);
    }
    if (endDate != null) {
      query = query.lte('activity_date', endDate.toIso8601String().split('T')[0]);
    }

    final data = await query.order('activity_date', ascending: true);
    return (data as List).map((e) => HeatmapEntry.fromJson(e)).toList();
  }

  Future<void> updateHeatmapEntry({
    required String userId,
    required DateTime date,
    int tasksCompleted = 0,
    int focusMins = 0,
  }) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final existing = await _supabase
        .from('heatmap_entries')
        .select()
        .eq('user_id', userId)
        .eq('activity_date', dateStr)
        .maybeSingle();

    if (existing != null) {
      await _supabase.from('heatmap_entries').update({
        'tasks_completed': (existing['tasks_completed'] ?? 0) + tasksCompleted,
        'focus_mins': (existing['focus_mins'] ?? 0) + focusMins,
      }).eq('id', existing['id']);
    } else {
      await _supabase.from('heatmap_entries').insert({
        'user_id': userId,
        'activity_date': dateStr,
        'tasks_completed': tasksCompleted,
        'focus_mins': focusMins,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard({
    required String examCategory,
    String boardType = 'weekly',
    int limit = 50,
  }) async {
    final data = await _supabase
        .from('leaderboard_entries')
        .select('''
          *,
          leaderboards!inner(exam_category, board_type, week_number, year),
          users!inner(full_name, avatar_url)
        ''')
        .eq('leaderboards.exam_category', examCategory)
        .eq('leaderboards.board_type', boardType)
        .eq('leaderboards.is_active', true)
        .order('score', ascending: false)
        .limit(limit);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<PeerRoom>> getPeerRooms(String userId) async {
    final memberData = await _supabase
        .from('peer_room_members')
        .select('room_id')
        .eq('user_id', userId);

    if (memberData.isEmpty) return [];

    final roomIds =
        (memberData as List).map((m) => m['room_id'] as String).toList();
    final data = await _supabase
        .from('peer_rooms')
        .select()
        .inFilter('id', roomIds)
        .eq('is_active', true);
    return (data as List).map((e) => PeerRoom.fromJson(e)).toList();
  }

  Future<PeerRoom> createPeerRoom({
    required String userId,
    required String name,
    required String examCategory,
    int maxMembers = 10,
  }) async {
    final code = _generateRoomCode();
    final data = await _supabase
        .from('peer_rooms')
        .insert({
          'name': name,
          'code': code,
          'exam_category': examCategory,
          'created_by': userId,
          'max_members': maxMembers,
        })
        .select()
        .single();

    await _supabase.from('peer_room_members').insert({
      'room_id': data['id'],
      'user_id': userId,
      'role': 'admin',
    });

    return PeerRoom.fromJson(data);
  }

  Future<PeerRoom?> joinPeerRoom(String userId, String code) async {
    final room = await _supabase
        .from('peer_rooms')
        .select()
        .eq('code', code)
        .eq('is_active', true)
        .maybeSingle();

    if (room == null) return null;

    final memberCountResp = await _supabase
        .from('peer_room_members')
        .select()
        .eq('room_id', room['id'])
        .count();

    if (memberCountResp.count >= (room['max_members'] ?? 10)) {
      throw Exception('Room is full');
    }

    final existingMember = await _supabase
        .from('peer_room_members')
        .select()
        .eq('room_id', room['id'])
        .eq('user_id', userId)
        .maybeSingle();

    if (existingMember != null) {
      return PeerRoom.fromJson(room);
    }

    await _supabase.from('peer_room_members').insert({
      'room_id': room['id'],
      'user_id': userId,
    });

    return PeerRoom.fromJson(room);
  }

  Future<List<Map<String, dynamic>>> getPeerRoomMembers(String roomId) async {
    final data = await _supabase
        .from('peer_room_members')
        .select('''
          *,
          users:user_id(full_name, email)
        ''')
        .eq('room_id', roomId)
        .order('joined_at');
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> leavePeerRoom(String userId, String roomId) async {
    await _supabase
        .from('peer_room_members')
        .delete()
        .eq('room_id', roomId)
        .eq('user_id', userId);
  }

  Future<void> deletePeerRoom(String userId, String roomId) async {
    await _supabase
        .from('peer_room_members')
        .delete()
        .eq('room_id', roomId);
    await _supabase
        .from('peer_rooms')
        .delete()
        .eq('id', roomId)
        .eq('created_by', userId);
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = DateTime.now().millisecondsSinceEpoch;
    return List.generate(6, (i) => chars[(rng + i) % chars.length]).join();
  }
}
