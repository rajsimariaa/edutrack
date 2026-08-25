import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class TestsScreen extends ConsumerStatefulWidget {
  const TestsScreen({super.key});

  @override
  ConsumerState<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends ConsumerState<TestsScreen> {
  final _testService = TestService();
  List<Test> _tests = [];
  List<UserTestSubmission> _submissions = [];
  Map<String, int> _attemptCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = ref.read(authProvider);
    if (auth.user == null || auth.profile == null) return;

    try {
      final exam = await SyllabusService().getExamForCategory(auth.profile!.examCategory);
      if (exam != null) {
        _tests = await _testService.getAvailableTests(exam.id);
      }
      final userId = auth.user?.id;
      if (userId == null) return;
      _submissions = await _testService.getUserSubmissions(userId);

      final counts = <String, int>{};
      for (final sub in _submissions) {
        counts[sub.testId] = (counts[sub.testId] ?? 0) + 1;
      }
      setState(() {
        _attemptCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tests'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Available'),
                      Tab(text: 'My Results'),
                      Tab(text: 'Daily Quiz'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildAvailableTests(),
                        _buildMyResults(),
                        _buildDailyQuizTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAvailableTests() {
    if (_tests.isEmpty) {
      return const Center(child: Text('No tests available yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tests.length,
      itemBuilder: (context, index) {
        final test = _tests[index];
        final attempts = _attemptCounts[test.id] ?? 0;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.quiz, color: AppColors.secondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${test.totalMarks} marks • ${test.durationMins} min${attempts > 0 ? ' • Attempt $attempts' : ''}',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/tests/${test.id}'),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: Text(attempts > 0 ? 'Retake' : 'Start'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/tests/mock-exam/${test.id}'),
                        icon: const Icon(Icons.timer_outlined, size: 18),
                        label: const Text('Mock Exam'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          backgroundColor: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyResults() {
    if (_submissions.isEmpty) {
      return const Center(child: Text('No test results yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _submissions.length,
      itemBuilder: (context, index) {
        final sub = _submissions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.grade, color: AppColors.success),
            ),
            title: Text(
              'Score: ${sub.score?.toStringAsFixed(1) ?? "N/A"}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Correct: ${sub.totalCorrect ?? 0} • Wrong: ${sub.totalWrong ?? 0} • Skipped: ${sub.totalUnattempted ?? 0}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyQuizTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.quiz, size: 50, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Daily Quiz',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Test yourself with 10 random questions\nBuild your streak and earn bonus XP!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/tests/daily-quiz'),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Daily Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
