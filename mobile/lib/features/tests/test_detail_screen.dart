import 'dart:async';
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
  Set<int> _markedForReview = {};
  bool _isLoading = true;
  bool _isSubmitted = false;
  int _remainingSeconds = 0;
  bool _timerActive = false;
  Timer? _timer;
  static const double _negativeMarkingRate = 0.33;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_timerActive || _isSubmitted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _submitTest();
      }
    });
  }

  void _selectAnswer(int questionIndex, String option) {
    setState(() => _answers[questionIndex] = option);
  }

  void _toggleMarkForReview(int questionIndex) {
    setState(() {
      if (_markedForReview.contains(questionIndex)) {
        _markedForReview.remove(questionIndex);
      } else {
        _markedForReview.add(questionIndex);
      }
    });
  }

  void _clearAnswer(int questionIndex) {
    setState(() => _answers.remove(questionIndex));
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

  Map<String, dynamic> _calculateScore() {
    int correct = 0;
    int wrong = 0;
    int unattempted = 0;
    double totalScore = 0;
    double totalPenalty = 0;

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
        totalPenalty += q.marks * _negativeMarkingRate;
      }
    }

    return {
      'correct': correct,
      'wrong': wrong,
      'unattempted': unattempted,
      'totalScore': totalScore,
      'totalPenalty': totalPenalty,
      'netScore': totalScore - totalPenalty,
    };
  }

  Future<void> _submitTest() async {
    final auth = ref.read(authProvider);
    if (auth.user == null || _test == null) return;

    final scoreData = _calculateScore();

    final answersJson = <Map<String, dynamic>>[];
    for (int i = 0; i < _questions.length; i++) {
      if (_answers.containsKey(i)) {
        final isCorrect = _answers[i] == _questions[i].correctOption;
        answersJson.add({
          'question_id': _questions[i].id,
          'selected_option': _answers[i],
          'is_correct': isCorrect,
          'marks_obtained':
              isCorrect ? _questions[i].marks : -_questions[i].marks * _negativeMarkingRate,
        });
      }
    }

    final userId = auth.user?.id;
    if (userId == null) return;

    await _testService.submitTest(
      userId: userId,
      testId: widget.testId,
      score: scoreData['netScore'] as double,
      totalCorrect: scoreData['correct'] as int,
      totalWrong: scoreData['wrong'] as int,
      totalUnattempted: scoreData['unattempted'] as int,
      negativeMarksPerQuestion: _negativeMarkingRate,
      answers: answersJson,
    );

    await GamificationService().updateHeatmapEntry(
      userId: userId,
      date: DateTime.now(),
      tasksCompleted: 1,
    );

    try {
      await BadgeService().evaluateAndAwardBadges(userId);
    } catch (_) {}

    setState(() => _isSubmitted = true);
  }

  Widget _buildRunningScore() {
    final scoreData = _calculateScore();
    final netScore = scoreData['netScore'] as double;
    final penalty = scoreData['totalPenalty'] as double;
    final totalMarks = _test?.totalMarks ?? 100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Score: ${netScore.toStringAsFixed(0)}/${totalMarks.toStringAsFixed(0)}${penalty > 0 ? ' (-${penalty.toStringAsFixed(1)})' : ''}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          fontSize: 12,
        ),
      ),
    );
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
    final options = question.options;
    final sortedKeys = options.keys.toList()..sort();

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
              padding: const EdgeInsets.only(right: 12),
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
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: _buildRunningScore(),
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
                  ...sortedKeys.map((key) {
                    final text = options[key]?.toString() ?? '';
                    final isSelected = _answers[_currentQuestion] == key;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _selectAnswer(_currentQuestion, key),
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
                                  key,
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
                                  text,
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
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleMarkForReview(_currentQuestion),
                        icon: Icon(
                          _markedForReview.contains(_currentQuestion)
                              ? Icons.star
                              : Icons.star_border,
                          color: _markedForReview.contains(_currentQuestion)
                              ? AppColors.warning
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                        label: Text(
                          _markedForReview.contains(_currentQuestion)
                              ? 'Unmark'
                              : 'Review',
                          style: TextStyle(
                            color: _markedForReview.contains(_currentQuestion)
                                ? AppColors.warning
                                : AppColors.textSecondary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          side: BorderSide(
                            color: _markedForReview.contains(_currentQuestion)
                                ? AppColors.warning
                                : AppColors.border,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _clearAnswer(_currentQuestion),
                        icon: const Icon(Icons.clear, size: 20),
                        label: const Text('Clear'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          foregroundColor: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final scoreData = _calculateScore();
    final correct = scoreData['correct'] as int;
    final wrong = scoreData['wrong'] as int;
    final skipped = scoreData['unattempted'] as int;
    final totalMarks = _questions.fold<double>(0, (sum, q) => sum + q.marks);
    final obtained = scoreData['totalScore'] as double;
    final penalty = scoreData['totalPenalty'] as double;
    final netScore = scoreData['netScore'] as double;
    final pct = totalMarks > 0 ? (netScore / totalMarks * 100) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: pct >= 50
                      ? [AppColors.success, AppColors.success.withOpacity(0.8)]
                      : [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    pct >= 50 ? Icons.check_circle_outline : Icons.info_outline,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${pct.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Net: ${netScore.toStringAsFixed(1)} / ${totalMarks.toStringAsFixed(0)} marks',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Correct: +${obtained.toStringAsFixed(1)} | Wrong: -${penalty.toStringAsFixed(1)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildResultStat('Correct', '$correct', AppColors.success),
                _buildResultStat('Wrong', '$wrong', AppColors.error),
                _buildResultStat('Skipped', '$skipped', AppColors.textHint),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Score Breakdown',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildBreakdownRow('Questions correct', '+${obtained.toStringAsFixed(1)}', AppColors.success),
                  const SizedBox(height: 8),
                  _buildBreakdownRow('Questions wrong', '-${penalty.toStringAsFixed(1)}', AppColors.error),
                  const SizedBox(height: 8),
                  _buildBreakdownRow('Questions unattempted', '0', AppColors.textHint),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Net Score',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        netScore.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: netScore >= totalMarks * 0.5 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Question Review',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${correct}/${_questions.length} correct',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(_questions.length, (i) {
              final q = _questions[i];
              final userAnswer = _answers[i];
              final isCorrect = userAnswer == q.correctOption;
              final options = q.options;
              final correctText = options[q.correctOption]?.toString() ?? q.correctOption;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCorrect
                        ? AppColors.success.withOpacity(0.5)
                        : AppColors.error.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isCorrect ? AppColors.success : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCorrect ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Q${i + 1}. ${q.questionText}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (userAnswer != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 38),
                        child: Text(
                          'Your answer: $userAnswer - ${options[userAnswer]?.toString() ?? ''}',
                          style: TextStyle(
                            color: isCorrect ? AppColors.success : AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(left: 38),
                        child: Text(
                          'Skipped',
                          style: TextStyle(color: AppColors.textHint, fontSize: 13),
                        ),
                      ),
                    if (!isCorrect)
                      Padding(
                        padding: const EdgeInsets.only(left: 38, top: 4),
                        child: Text(
                          'Correct: $q.correctOption - $correctText',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (q.explanation != null && q.explanation!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 38, top: 8),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lightbulb_outline, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  q.explanation!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _timer?.cancel();
                  setState(() {
                    _isSubmitted = false;
                    _currentQuestion = 0;
                    _answers = {};
                    if (_test != null && _test!.durationMins > 0) {
                      _remainingSeconds = _test!.durationMins * 60;
                      _timerActive = true;
                      _startTimer();
                    }
                  });
                },
                child: const Text('Retake Test'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Tests'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
