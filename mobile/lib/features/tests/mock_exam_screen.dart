import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class MockExamScreen extends ConsumerStatefulWidget {
  final String testId;
  const MockExamScreen({super.key, required this.testId});

  @override
  ConsumerState<MockExamScreen> createState() => _MockExamScreenState();
}

enum QuestionStatus { unanswered, answered, wrong, markedForReview, answeredAndMarked }

class _MockExamScreenState extends ConsumerState<MockExamScreen> {
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
  int _timeTakenSeconds = 0;
  bool _showPalette = false;
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
      if (!mounted) return;
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
        setState(() {
          _remainingSeconds--;
          _timeTakenSeconds++;
        });
      } else {
        timer.cancel();
        _submitTest(autoSubmitted: true);
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

  void _jumpToQuestion(int index) {
    setState(() {
      _currentQuestion = index;
      _showPalette = false;
    });
  }

  QuestionStatus _getQuestionStatus(int index) {
    final hasAnswer = _answers.containsKey(index);
    final isMarked = _markedForReview.contains(index);

    if (hasAnswer && isMarked) return QuestionStatus.answeredAndMarked;
    if (isMarked) return QuestionStatus.markedForReview;
    if (hasAnswer) {
      final isCorrect = _answers[index] == _questions[index].correctOption;
      return isCorrect ? QuestionStatus.answered : QuestionStatus.wrong;
    }
    return QuestionStatus.unanswered;
  }

  Color _getStatusColor(QuestionStatus status) {
    switch (status) {
      case QuestionStatus.answered:
        return AppColors.success;
      case QuestionStatus.wrong:
        return AppColors.error;
      case QuestionStatus.unanswered:
        return AppColors.textHintOf(context);
      case QuestionStatus.markedForReview:
        return AppColors.warning;
      case QuestionStatus.answeredAndMarked:
        return AppColors.primary;
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

  void _showSubmitConfirmation() {
    final scoreData = _calculateScore();
    final answered = (scoreData['correct'] as int) + (scoreData['wrong'] as int);
    final unattempted = scoreData['unattempted'] as int;
    final marked = _markedForReview.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Exam?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Answered: $answered'),
            Text('Unattempted: $unattempted'),
            Text('Marked for review: $marked'),
            const SizedBox(height: 12),
            const Text('Are you sure you want to submit?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitTest();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTest({bool autoSubmitted = false}) async {
    if (_isSubmitted) return;

    final auth = ref.read(authProvider);
    if (auth.user == null || _test == null) return;

    _timer?.cancel();
    final scoreData = _calculateScore();
    final timeTakenMins = (_timeTakenSeconds / 60).floor();

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
      timeTakenMins: timeTakenMins,
      negativeMarksPerQuestion: _negativeMarkingRate,
      answers: answersJson,
    );

    try {
      await GamificationService().updateHeatmapEntry(
        userId: userId,
        date: DateTime.now(),
        tasksCompleted: 1,
      );
    } catch (_) {}

    try {
      await BadgeService().evaluateAndAwardBadges(userId);
    } catch (_) {}

    await _saveMockExamResult(scoreData, timeTakenMins);

    if (!mounted) return;
    setState(() => _isSubmitted = true);

    if (autoSubmitted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time\'s up! Exam submitted automatically.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _saveMockExamResult(Map<String, dynamic> scoreData, int timeTakenMins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final resultsJson = prefs.getStringList('mock_exam_results') ?? [];
      final result = {
        'testId': widget.testId,
        'testTitle': _test?.title ?? 'Mock Exam',
        'netScore': scoreData['netScore'],
        'correct': scoreData['correct'],
        'wrong': scoreData['wrong'],
        'unattempted': scoreData['unattempted'],
        'totalMarks': _test?.totalMarks ?? 0,
        'timeTakenMins': timeTakenMins,
        'date': DateTime.now().toIso8601String(),
      };
      resultsJson.add(result.toString());
      await prefs.setStringList('mock_exam_results', resultsJson);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mock Exam')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_test == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mock Exam')),
        body: const Center(child: Text('Test not found')),
      );
    }

    if (_isSubmitted) {
      return _buildResultScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_test!.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit Exam?'),
                content: const Text('Your progress will be submitted.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _submitTest();
                    },
                    child: const Text('Submit & Exit'),
                  ),
                ],
              ),
            );
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
                    color: _remainingSeconds < 300
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _remainingSeconds < 300 ? AppColors.error : AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: _buildRunningScore()),
          ),
          IconButton(
            icon: Icon(_showPalette ? Icons.close : Icons.grid_view),
            onPressed: () => setState(() => _showPalette = !_showPalette),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              LinearProgressIndicator(
                value: (_currentQuestion + 1) / _questions.length,
                backgroundColor: AppColors.borderOf(context),
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_questions[_currentQuestion].marks} marks',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '-${(_questions[_currentQuestion].marks * _negativeMarkingRate).toStringAsFixed(1)} for wrong',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _questions[_currentQuestion].questionText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._buildOptions(),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
          if (_showPalette) _buildQuestionPalette(),
        ],
      ),
    );
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

  List<Widget> _buildOptions() {
    final question = _questions[_currentQuestion];
    final options = question.options;
    final sortedKeys = options.keys.toList()..sort();

    return sortedKeys.map((key) {
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
                  : AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderOf(context),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.borderOf(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    key,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimaryOf(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textPrimaryOf(context),
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        border: Border(top: BorderSide(color: AppColors.borderOf(context))),
      ),
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
                        : AppColors.textSecondaryOf(context),
                    size: 20,
                  ),
                  label: Text(
                    _markedForReview.contains(_currentQuestion)
                        ? 'Unmark'
                        : 'Review',
                    style: TextStyle(
                      color: _markedForReview.contains(_currentQuestion)
                          ? AppColors.warning
                          : AppColors.textSecondaryOf(context),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    side: BorderSide(
                      color: _markedForReview.contains(_currentQuestion)
                          ? AppColors.warning
                          : AppColors.borderOf(context),
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
                    foregroundColor: AppColors.textSecondaryOf(context),
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
                      : _showSubmitConfirmation,
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
    );
  }

  Widget _buildQuestionPalette() {
    return Positioned(
      top: 0,
      right: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width * 0.35,
      child: Container(
        color: AppColors.surfaceOf(context),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderOf(context))),
              ),
              child: const Text(
                'Question Palette',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final status = _getQuestionStatus(index);
                  final color = _getStatusColor(status);
                  final isCurrent = index == _currentQuestion;

                  return GestureDetector(
                    onTap: () => _jumpToQuestion(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrent ? AppColors.primary : color,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderOf(context))),
              ),
              child: Column(
                children: [
                  _buildLegend(AppColors.success, 'Answered'),
                  _buildLegend(AppColors.error, 'Wrong'),
                  _buildLegend(AppColors.textHintOf(context), 'Unattempted'),
                  _buildLegend(AppColors.warning, 'Marked'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final scoreData = _calculateScore();
    final correct = scoreData['correct'] as int;
    final wrong = scoreData['wrong'] as int;
    final skipped = scoreData['unattempted'] as int;
    final totalMarks = _test?.totalMarks ?? 100;
    final obtained = scoreData['totalScore'] as double;
    final penalty = scoreData['totalPenalty'] as double;
    final netScore = scoreData['netScore'] as double;
    final pct = totalMarks > 0 ? (netScore / totalMarks * 100) : 0.0;
    final timeTakenMins = (_timeTakenSeconds / 60).floor();

    final subjects = <String, Map<String, dynamic>>{};
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final subject = q.topicId ?? 'General';
      if (!subjects.containsKey(subject)) {
        subjects[subject] = {'correct': 0, 'total': 0, 'marks': 0.0};
      }
      subjects[subject]!['total'] = (subjects[subject]!['total'] as int) + 1;
      if (_answers[i] == q.correctOption) {
        subjects[subject]!['correct'] = (subjects[subject]!['correct'] as int) + 1;
        subjects[subject]!['marks'] = (subjects[subject]!['marks'] as double) + q.marks;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Results'),
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
                _buildResultStat('Skipped', '$skipped', AppColors.textHintOf(context)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceOf(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderOf(context)),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Time Taken: ${timeTakenMins} mins ${(_timeTakenSeconds % 60)} secs',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceOf(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderOf(context)),
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
                  _buildBreakdownRow('Questions unattempted', '0', AppColors.textHintOf(context)),
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
            if (subjects.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceOf(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderOf(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accuracy by Subject',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...subjects.entries.map((entry) {
                      final total = entry.value['total'] as int;
                      final correctCount = entry.value['correct'] as int;
                      final accuracy = total > 0 ? (correctCount / total * 100) : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(entry.key, style: const TextStyle(fontSize: 14)),
                            ),
                            Text(
                              '$correctCount/$total',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 60,
                              child: LinearProgressIndicator(
                                value: accuracy / 100,
                                backgroundColor: AppColors.borderOf(context),
                                valueColor: AlwaysStoppedAnimation(
                                  accuracy >= 50 ? AppColors.success : AppColors.error,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${accuracy.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: accuracy >= 50 ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Tests'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isSubmitted = false;
                    _currentQuestion = 0;
                    _answers = {};
                    _markedForReview = {};
                    _timeTakenSeconds = 0;
                    if (_test != null && _test!.durationMins > 0) {
                      _remainingSeconds = _test!.durationMins * 60;
                      _timerActive = true;
                      _startTimer();
                    }
                  });
                },
                child: const Text('Retake Exam'),
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
              style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 12),
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
          style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 14),
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
