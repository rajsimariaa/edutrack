import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/models.dart';

class ResourceService {
  final _supabase = SupabaseService.instance.client;

  Future<List<Map<String, dynamic>>> getPastPapers(
    String examId, {
    int? year,
  }) async {
    var query = _supabase
        .from('past_papers')
        .select()
        .eq('exam_id', examId);
    if (year != null) {
      query = query.eq('year', year);
    }
    final data = await query.order('year', ascending: false);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getYoutubeLinks(
    String chapterId, {
    String? topicId,
  }) async {
    var query = _supabase
        .from('youtube_links')
        .select()
        .eq('chapter_id', chapterId);
    if (topicId != null) {
      query = query.eq('topic_id', topicId);
    }
    final data = await query.order('upvotes', ascending: false);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> upvoteYoutubeLink(String linkId) async {
    await _supabase.rpc('increment_upvote', params: {'link_id': linkId});
  }
}
