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
    final data = await _supabase
        .from('user_test_submissions')
        .select('''
          *,
          tests!inner(title, total_marks, exam_id)
        ''')
        .eq('user_id', userId)
        .order('submitted_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => UserTestSubmission.fromJson(e)).toList();
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
}
