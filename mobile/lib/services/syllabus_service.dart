import 'supabase_service.dart';
import '../models/models.dart';

class SyllabusService {
  final _supabase = SupabaseService.client;

  Future<List<Exam>> getExams() async {
    final data = await _supabase
        .from('exams')
        .select()
        .eq('is_active', true)
        .order('name');
    return (data as List).map((e) => Exam.fromJson(e)).toList();
  }

  Future<Exam?> getExamForCategory(String category) async {
    final data = await _supabase
        .from('exams')
        .select()
        .eq('category', category)
        .eq('is_active', true)
        .maybeSingle();
    if (data == null) return null;
    return Exam.fromJson(data);
  }

  Future<List<Subject>> getSubjects(String examId) async {
    final data = await _supabase
        .from('subjects')
        .select()
        .eq('exam_id', examId)
        .order('display_order');
    return (data as List).map((e) => Subject.fromJson(e)).toList();
  }

  Future<List<Module>> getModules(String subjectId) async {
    final data = await _supabase
        .from('modules')
        .select()
        .eq('subject_id', subjectId)
        .order('display_order');
    return (data as List).map((e) => Module.fromJson(e)).toList();
  }

  Future<List<Chapter>> getChapters(String moduleId) async {
    final data = await _supabase
        .from('chapters')
        .select()
        .eq('module_id', moduleId)
        .order('display_order');
    return (data as List).map((e) => Chapter.fromJson(e)).toList();
  }

  Future<List<Topic>> getTopics(String chapterId) async {
    final data = await _supabase
        .from('topics')
        .select()
        .eq('chapter_id', chapterId)
        .order('display_order');
    return (data as List).map((e) => Topic.fromJson(e)).toList();
  }

  Future<List<UserTopicProgress>> getUserProgress(String userId) async {
    final data = await _supabase
        .from('user_topic_progress')
        .select()
        .eq('user_id', userId);
    return (data as List).map((e) => UserTopicProgress.fromJson(e)).toList();
  }

  Future<void> updateTopicProgress({
    required String userId,
    required String topicId,
    required TopicStatus status,
  }) async {
    final existing = await _supabase
        .from('user_topic_progress')
        .select()
        .eq('user_id', userId)
        .eq('topic_id', topicId)
        .maybeSingle();

    final now = DateTime.now().toIso8601String();
    final statusStr = topicStatusToString(status);

    if (existing != null) {
      final updates = <String, dynamic>{
        'status': statusStr,
        'updated_at': now,
      };
      if (status == TopicStatus.inProgress && existing['started_at'] == null) {
        updates['started_at'] = now;
      }
      if (status == TopicStatus.mastered && existing['mastered_at'] == null) {
        updates['mastered_at'] = now;
      }
      await _supabase
          .from('user_topic_progress')
          .update(updates)
          .eq('id', existing['id']);
    } else {
      await _supabase.from('user_topic_progress').insert({
        'user_id': userId,
        'topic_id': topicId,
        'status': statusStr,
        if (status == TopicStatus.inProgress) 'started_at': now,
        if (status == TopicStatus.mastered) 'mastered_at': now,
      });
    }
  }

  Future<List<Topic>> getTopicsByIds(List<String> topicIds) async {
    if (topicIds.isEmpty) return [];
    final data = await _supabase
        .from('topics')
        .select()
        .inFilter('id', topicIds);
    return (data as List).map((e) => Topic.fromJson(e)).toList();
  }

  Future<Map<String, String>> getTopicChapterSubjectMap(
      List<String> topicIds) async {
    if (topicIds.isEmpty) return {};
    final topics = await getTopicsByIds(topicIds);
    final chapterIds = topics.map((t) => t.chapterId).toSet().toList();
    final chapters = await _supabase
        .from('chapters')
        .select('id, module_id')
        .inFilter('id', chapterIds);
    final chapterMap = <String, String>{};
    for (final c in chapters) {
      chapterMap[c['id'] as String] = c['module_id'] as String;
    }
    final moduleIds = chapterMap.values.toSet().toList();
    final modules = await _supabase
        .from('modules')
        .select('id, subject_id')
        .inFilter('id', moduleIds);
    final moduleMap = <String, String>{};
    for (final m in modules) {
      moduleMap[m['id'] as String] = m['subject_id'] as String;
    }
    final subjectIds = moduleMap.values.toSet().toList();
    final subjects = await _supabase
        .from('subjects')
        .select('id, name')
        .inFilter('id', subjectIds);
    final subjectNameMap = <String, String>{};
    for (final s in subjects) {
      subjectNameMap[s['id'] as String] = s['name'] as String;
    }
    final result = <String, String>{};
    for (final topic in topics) {
      final moduleId = chapterMap[topic.chapterId];
      final subjectId = moduleId != null ? moduleMap[moduleId] : null;
      if (subjectId != null) {
        result[topic.id] = subjectNameMap[subjectId] ?? 'Unknown';
      }
    }
    return result;
  }

  Future<void> updateTopicDifficulty(String topicId, String difficulty) async {
    await _supabase.from('topics').update({'difficulty': difficulty}).eq('id', topicId);
  }

  Future<Map<String, double>> getSubjectProgress(
    String userId,
    String subjectId,
  ) async {
    final chapters = await _supabase
        .from('chapters')
        .select('id')
        .inFilter('module_id',
            (await _supabase.from('modules').select('id').eq('subject_id', subjectId))
                .map((m) => m['id'] as String)
                .toList());

    if (chapters.isEmpty) return {'total': 0, 'mastered': 0, 'inProgress': 0};

    final chapterIds = chapters.map((c) => c['id'] as String).toList();
    final topics = await _supabase
        .from('topics')
        .select('id')
        .inFilter('chapter_id', chapterIds);

    if (topics.isEmpty) return {'total': 0, 'mastered': 0, 'inProgress': 0};

    final topicIds = topics.map((t) => t['id'] as String).toList();
    final progress = await _supabase
        .from('user_topic_progress')
        .select('status')
        .eq('user_id', userId)
        .inFilter('topic_id', topicIds);

    final total = topicIds.length;
    final mastered =
        progress.where((p) => p['status'] == 'mastered').length;
    final inProgress =
        progress.where((p) => p['status'] == 'in_progress').length;

    return {
      'total': total.toDouble(),
      'mastered': mastered.toDouble(),
      'inProgress': inProgress.toDouble(),
    };
  }
}
