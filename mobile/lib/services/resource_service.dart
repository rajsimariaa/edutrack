import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/models.dart';

class ResourceService {
  final _supabase = SupabaseService.client;

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

  Future<List<Map<String, dynamic>>> getYoutubeLinks({
    String? examId,
    String? chapterId,
    String? topicId,
  }) async {
    if (examId != null) {
      final subjects = await _supabase.from('subjects').select('id').eq('exam_id', examId);
      final subjectIds = (subjects as List).map((s) => s['id'] as String).toList();
      if (subjectIds.isEmpty) return [];

      final modules = await _supabase.from('modules').select('id').inFilter('subject_id', subjectIds);
      final moduleIds = (modules as List).map((m) => m['id'] as String).toList();
      if (moduleIds.isEmpty) return [];

      final chapters = await _supabase.from('chapters').select('id').inFilter('module_id', moduleIds);
      final chapterIds = (chapters as List).map((c) => c['id'] as String).toList();
      if (chapterIds.isEmpty) return [];

      final data = await _supabase
          .from('youtube_links')
          .select()
          .inFilter('chapter_id', chapterIds)
          .order('upvotes', ascending: false);
      return (data as List).cast<Map<String, dynamic>>();
    }

    if (chapterId != null) {
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

    return [];
  }

  Future<void> upvoteYoutubeLink(String linkId) async {
    await _supabase.rpc('increment_upvote', params: {'link_id': linkId});
  }
}
