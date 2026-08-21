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
      final exams = await SyllabusService().getExams();
      if (exams.isNotEmpty) {
        _tests = await _testService.getAvailableTests(exams.first.id);
      }
      _submissions = await _testService.getUserSubmissions(auth.user!.id);
      setState(() => _isLoading = false);
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
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Available'),
                      Tab(text: 'My Results'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildAvailableTests(),
                        _buildMyResults(),
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
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.quiz, color: AppColors.secondary),
            ),
            title: Text(
              test.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${test.totalMarks} marks • ${test.durationMins} min',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            trailing: ElevatedButton(
              onPressed: () => context.go('/tests/${test.id}'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Start'),
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
              'Percentile: ${sub.percentile?.toStringAsFixed(1) ?? "N/A"} • Rank: ${sub.rankInCategory ?? "N/A"}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        );
      },
    );
  }
}
