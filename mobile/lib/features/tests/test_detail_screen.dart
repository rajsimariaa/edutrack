import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class TestDetailScreen extends ConsumerStatefulWidget {
  final String testId;
  const TestDetailScreen({super.key, required this.testId});

  @override
  ConsumerState<TestDetailScreen> createState() => _TestDetailScreenState();
}

class _TestDetailScreenState extends ConsumerState<TestDetailScreen> {
  final _testService = TestService();
  Test? _test;
  List<TestQuestion> _questions = [];
  int _currentQuestion = 0;
  Map<int, String> _answers = {};
  bool _isLoading = true;
  bool _isSubmitted = false;
  int _remainingSeconds = 0;
  bool _timerActive = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _test = await _testService.getTest(widget.testId);
      _questions = await _testService.getTestQuestions(widget.testId);
      setState(() => _isLoading = false);
      if (_test != null && _test!.durationMins > 0) {
        _remainingSeconds = _test!.durationMins * 60;
        _timerActive = true;
        _startTimer();
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!_timerActive || _isSubmitted) return false;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
        return true;
      }
      _submitTest();
      return false;
    });
  }

  void _selectAnswer(int questionIndex, String option) {
    setState(() => _answers[questionIndex] = option);
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() => _currentQuestion--);
    }
  }

  Future<void> _submitTest() async {
    final auth = ref.read(authProvider);
    if (auth.user == null || _test == null) return;

    int correct = 0;
    int wrong = 0;
    int unattempted = 0;
    double totalScore = 0;

    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final answer = _answers[i];
      if (answer == null) {
        unattempted++;
      } else if (answer == q.correctOption) {
        correct++;
        totalScore += q.marks;
      } else {
        wrong++;
      }
    }

    final answersJson = <Map<String, dynamic>>[];
    for (int i = 0; i < _questions.length; i++) {
      if (_answers.containsKey(i)) {
        answersJson.add({
          'question_id': _questions[i].id,
          'selected_option': _answers[i],
          'is_correct': _answers[i] == _questions[i].correctOption,
          'marks_obtained':
              _answers[i] == _questions[i].correctOption ? _questions[i].marks : 0.0,
        });
      }
    }

    final userId = auth.user?.id;
    if (userId == null) return;

    await _testService.submitTest(
      userId: userId,
      testId: widget.testId,
      score: totalScore,
      totalCorrect: correct,
      totalWrong: wrong,
      totalUnattempted: unattempted,
      answers: answersJson,
    );

    setState(() => _isSubmitted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Test')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_test == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Test')),
        body: const Center(child: Text('Test not found')),
      );
    }

    if (_isSubmitted) {
      return _buildResultScreen();
    }

    final question = _questions[_currentQuestion];
    final options = List<Map<String, dynamic>>.from(question.options);

    return Scaffold(
      appBar: AppBar(
        title: Text(_test!.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/tests');
            }
          },
        ),
        actions: [
          if (_timerActive && _remainingSeconds > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _remainingSeconds < 60 ? AppColors.error.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _remainingSeconds < 60 ? AppColors.error : AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentQuestion + 1}/${_questions.length}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / _questions.length,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${question.marks} marks',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question.questionText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...options.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final opt = entry.value;
                    final label = String.fromCharCode(65 + idx);
                    final isSelected = _answers[_currentQuestion] == label;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _selectAnswer(_currentQuestion, label),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  opt['text'] ?? '',
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _currentQuestion > 0 ? _previousQuestion : null,
                    child: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentQuestion < _questions.length - 1
                        ? _nextQuestion
                        : _submitTest,
                    child: Text(
                      _currentQuestion < _questions.length - 1
                          ? 'Next'
                          : 'Submit',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    int correct = 0;
    int wrong = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].correctOption) {
        correct++;
      } else if (_answers[i] != null) {
        wrong++;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: AppColors.success,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Test Submitted!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildResultStat('Correct', '$correct', AppColors.success),
                    _buildResultStat('Wrong', '$wrong', AppColors.error),
                    _buildResultStat('Skipped', '${_questions.length - correct - wrong}', AppColors.textHint),
                  ],
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Tests'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
