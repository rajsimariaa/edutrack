import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/models.dart';

class TestService {
  final _supabase = SupabaseService.client;

  Future<List<Test>> getAvailableTests(String examId) async {
    final data = await _supabase
        .from('tests')
        .select()
        .eq('exam_id', examId)
        .eq('is_published', true)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Test.fromJson(e)).toList();
  }

  Future<Test?> getTest(String testId) async {
    final data = await _supabase
        .from('tests')
        .select()
        .eq('id', testId)
        .maybeSingle();
    if (data == null) return null;
    return Test.fromJson(data);
  }

  Future<List<TestQuestion>> getTestQuestions(String testId) async {
    final data = await _supabase
        .from('test_questions')
        .select()
        .eq('test_id', testId)
        .order('display_order');
    return (data as List).map((e) => TestQuestion.fromJson(e)).toList();
  }

  Future<UserTestSubmission> submitTest({
    required String userId,
    required String testId,
    required double score,
    int? totalCorrect,
    int? totalWrong,
    int? totalUnattempted,
    int? timeTakenMins,
    double? negativeMarksPerQuestion,
    List<Map<String, dynamic>>? answers,
  }) async {
    await _supabase
        .from('user_test_answers')
        .delete()
        .inFilter('submission_id',
            (await _supabase
                    .from('user_test_submissions')
                    .select('id')
                    .eq('user_id', userId)
                    .eq('test_id', testId))
                .map((s) => s['id'] as String)
                .toList());

    await _supabase
        .from('user_test_submissions')
        .delete()
        .eq('user_id', userId)
        .eq('test_id', testId);

    final submission = await _supabase
        .from('user_test_submissions')
        .insert({
          'user_id': userId,
          'test_id': testId,
          'score': score,
          'total_correct': totalCorrect,
          'total_wrong': totalWrong,
          'total_unattempted': totalUnattempted,
          'time_taken_mins': timeTakenMins,
          'negative_marks_per_question': negativeMarksPerQuestion,
        })
        .select()
        .single();

    if (answers != null && answers.isNotEmpty) {
      final answerInserts = answers.map((a) => {
        'submission_id': submission['id'],
        'question_id': a['question_id'],
        'selected_option': a['selected_option'],
        'is_correct': a['is_correct'],
        'marks_obtained': a['marks_obtained'],
      }).toList();
      await _supabase.from('user_test_answers').insert(answerInserts);
    }

    return UserTestSubmission.fromJson(submission);
  }

  Future<List<UserTestSubmission>> getUserSubmissions(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final data = await _supabase
          .from('user_test_submissions')
          .select()
          .eq('user_id', userId)
          .order('submitted_at', ascending: false)
          .limit(limit);
      return (data as List).map((e) => UserTestSubmission.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getTestStats(String userId) async {
    final submissions = await _supabase
        .from('user_test_submissions')
        .select('score, percentile, total_correct, total_wrong')
        .eq('user_id', userId);

    if (submissions.isEmpty) {
      return {
        'totalTests': 0,
        'avgScore': 0.0,
        'avgPercentile': 0.0,
        'bestScore': 0.0,
      };
    }

    final total = submissions.length;
    final avgScore = submissions.fold<double>(
            0, (sum, s) => sum + ((s['score'] as num?)?.toDouble() ?? 0)) /
        total;
    final avgPercentile = submissions.fold<double>(
            0, (sum, s) => sum + ((s['percentile'] as num?)?.toDouble() ?? 0)) /
        total;
    final bestScore = submissions
        .map<double>((s) => (s['score'] as num?)?.toDouble() ?? 0)
        .reduce((a, b) => a > b ? a : b);

    return {
      'totalTests': total,
      'avgScore': avgScore,
      'avgPercentile': avgPercentile,
      'bestScore': bestScore,
    };
  }

  Future<List<Map<String, dynamic>>> getUserTestAnswers(String userId) async {
    try {
      final submissions = await _supabase
          .from('user_test_submissions')
          .select('id')
          .eq('user_id', userId);

      if (submissions.isEmpty) return [];

      final submissionIds = submissions.map((s) => s['id'] as String).toList();
      final answers = await _supabase
          .from('user_test_answers')
          .select('question_id, is_correct, marks_obtained')
          .inFilter('submission_id', submissionIds);

      if (answers.isEmpty) return [];

      final questionIds = answers
          .map((a) => a['question_id'] as String)
          .toSet()
          .toList();
      final questions = await _supabase
          .from('test_questions')
          .select('id, topic_id, test_id')
          .inFilter('id', questionIds);

      final questionMap = <String, Map<String, dynamic>>{};
      for (final q in questions) {
        questionMap[q['id'] as String] = q;
      }

      final testIds = questions.map((q) => q['test_id'] as String).toSet().toList();
      final tests = await _supabase
          .from('user_test_submissions')
          .select('id, test_id, submitted_at, time_taken_mins')
          .eq('user_id', userId);
      final submissionTestMap = <String, String>{};
      for (final s in tests) {
        submissionTestMap[s['id'] as String] = s['test_id'] as String;
      }

      final result = <Map<String, dynamic>>[];
      for (final answer in answers) {
        final qId = answer['question_id'] as String;
        final qData = questionMap[qId];
        if (qData != null) {
          result.add({
            'question_id': qId,
            'topic_id': qData['topic_id'],
            'is_correct': answer['is_correct'] ?? false,
            'marks_obtained': answer['marks_obtained'],
          });
        }
      }
      return result;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getChapterAccuracy(
      String userId, String chapterId) async {
    try {
      final topicRows = await _supabase
          .from('topics')
          .select('id')
          .eq('chapter_id', chapterId);

      if (topicRows.isEmpty) {
        return {'total': 0, 'correct': 0, 'accuracy': 0.0};
      }

      final topicIds = topicRows.map((t) => t['id'] as String).toList();

      final answers = await getUserTestAnswers(userId);
      final topicAnswers = answers
          .where((a) =>
              a['topic_id'] != null && topicIds.contains(a['topic_id']))
          .toList();

      if (topicAnswers.isEmpty) {
        return {'total': 0, 'correct': 0, 'accuracy': 0.0};
      }

      final total = topicAnswers.length;
      final correct =
          topicAnswers.where((a) => a['is_correct'] == true).length;

      return {
        'total': total,
        'correct': correct,
        'accuracy': total > 0 ? (correct / total) * 100 : 0.0,
      };
    } catch (e) {
      return {'total': 0, 'correct': 0, 'accuracy': 0.0};
    }
  }

  Future<List<Map<String, dynamic>>> getTopicWiseAccuracy(String userId) async {
    try {
      final answers = await getUserTestAnswers(userId);
      if (answers.isEmpty) return [];

      final topicGroups = <String, List<Map<String, dynamic>>>{};
      for (final answer in answers) {
        final topicId = answer['topic_id'] as String?;
        if (topicId == null) continue;
        topicGroups.putIfAbsent(topicId, () => []).add(answer);
      }

      if (topicGroups.isEmpty) return [];

      final topicIds = topicGroups.keys.toList();
      final topics = await _supabase
          .from('topics')
          .select('id, name')
          .inFilter('id', topicIds);

      final topicNameMap = <String, String>{};
      for (final t in topics) {
        topicNameMap[t['id'] as String] = t['name'] as String;
      }

      final result = <Map<String, dynamic>>[];
      for (final entry in topicGroups.entries) {
        final total = entry.value.length;
        final correct =
            entry.value.where((a) => a['is_correct'] == true).length;
        result.add({
          'topic_id': entry.key,
          'topic_name': topicNameMap[entry.key] ?? 'Unknown Topic',
          'total': total,
          'correct': correct,
          'accuracy': total > 0 ? (correct / total) * 100 : 0.0,
        });
      }

      result.sort((a, b) => (a['accuracy'] as double).compareTo(b['accuracy'] as double));
      return result;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSubmissionsWithScores(
      String userId) async {
    try {
      final data = await _supabase
          .from('user_test_submissions')
          .select('id, test_id, score, submitted_at, time_taken_mins')
          .eq('user_id', userId)
          .order('submitted_at', ascending: false);
      return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSubjectWiseAccuracy(
      String userId) async {
    try {
      final answers = await getUserTestAnswers(userId);
      if (answers.isEmpty) return [];

      final topicIds = answers
          .map((a) => a['topic_id'] as String?)
          .where((id) => id != null)
          .toSet()
          .toList();
      if (topicIds.isEmpty) return [];

      final topics = await _supabase
          .from('topics')
          .select('id, chapter_id')
          .inFilter('id', topicIds);

      final topicToChapter = <String, String>{};
      for (final t in topics) {
        topicToChapter[t['id'] as String] = t['chapter_id'] as String;
      }

      final chapterIds = topicToChapter.values.toSet().toList();
      final chapters = await _supabase
          .from('chapters')
          .select('id, module_id')
          .inFilter('id', chapterIds);

      final chapterToModule = <String, String>{};
      for (final c in chapters) {
        chapterToModule[c['id'] as String] = c['module_id'] as String;
      }

      final moduleIds = chapterToModule.values.toSet().toList();
      final modules = await _supabase
          .from('modules')
          .select('id, subject_id')
          .inFilter('id', moduleIds);

      final moduleToSubject = <String, String>{};
      final subjectIds = <String>[];
      for (final m in modules) {
        moduleToSubject[m['id'] as String] = m['subject_id'] as String;
        subjectIds.add(m['subject_id'] as String);
      }

      final uniqueSubjectIds = subjectIds.toSet().toList();
      final subjects = await _supabase
          .from('subjects')
          .select('id, name')
          .inFilter('id', uniqueSubjectIds);

      final subjectNameMap = <String, String>{};
      for (final s in subjects) {
        subjectNameMap[s['id'] as String] = s['name'] as String;
      }

      final subjectGroups = <String, List<Map<String, dynamic>>>{};
      for (final answer in answers) {
        final topicId = answer['topic_id'] as String?;
        if (topicId == null) continue;
        final chapterId = topicToChapter[topicId];
        if (chapterId == null) continue;
        final moduleId = chapterToModule[chapterId];
        if (moduleId == null) continue;
        final subjectId = moduleToSubject[moduleId];
        if (subjectId == null) continue;
        subjectGroups.putIfAbsent(subjectId, () => []).add(answer);
      }

      final result = <Map<String, dynamic>>[];
      for (final entry in subjectGroups.entries) {
        final total = entry.value.length;
        final correct =
            entry.value.where((a) => a['is_correct'] == true).length;
        result.add({
          'subject_id': entry.key,
          'subject_name': subjectNameMap[entry.key] ?? 'Unknown',
          'total': total,
          'correct': correct,
          'accuracy': total > 0 ? (correct / total) * 100 : 0.0,
        });
      }

      result.sort((a, b) => (a['accuracy'] as double).compareTo(b['accuracy'] as double));
      return result;
    } catch (e) {
      return [];
    }
  }
}
