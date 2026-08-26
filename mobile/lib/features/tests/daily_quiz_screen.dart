import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class DailyQuizScreen extends ConsumerStatefulWidget {
  const DailyQuizScreen({super.key});

  @override
  ConsumerState<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends ConsumerState<DailyQuizScreen> {
  final _testService = TestService();
  List<TestQuestion> _allQuestions = [];
  List<TestQuestion> _quizQuestions = [];
  int _currentQuestion = 0;
  Map<int, String> _answers = {};
  bool _isLoading = true;
  bool _isSubmitted = false;
  int _remainingSeconds = 600;
  Timer? _timer;
  int _streak = 0;
  int _todayScore = 0;
  bool _hasCompletedToday = false;
  Map<String, bool> _completionMap = {};

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

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadData() async {
    final auth = ref.read(authProvider);
    if (auth.user == null || auth.profile == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = _todayKey();

      final completionData = prefs.getString('daily_quiz_$todayStr');
      if (completionData != null) {
        _hasCompletedToday = true;
        _todayScore = int.tryParse(completionData) ?? 0;
      }

      _streak = prefs.getInt('daily_quiz_streak') ?? 0;
      final lastQuizDate = prefs.getString('daily_quiz_last_date');
      if (lastQuizDate != null) {
        final lastDate = DateTime.parse(lastQuizDate);
        final today = DateTime.now();
        final diff = DateTime(today.year, today.month, today.day)
            .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
            .inDays;
        if (diff > 1) {
          _streak = 0;
        }
      }

      final allKeys = prefs.getKeys().where((k) => k.startsWith('daily_quiz_') && k != 'daily_quiz_streak' && k != 'daily_quiz_last_date');
      _completionMap = {};
      for (final key in allKeys) {
        _completionMap[key] = true;
      }

      final exam = await SyllabusService().getExamForCategory(auth.profile!.examCategory);
      if (exam != null) {
        final tests = await _testService.getAvailableTests(exam.id);
        for (final test in tests) {
          final questions = await _testService.getTestQuestions(test.id);
          _allQuestions.addAll(questions);
        }
      }

      if (_allQuestions.length > 10) {
        _allQuestions.shuffle(Random());
        _quizQuestions = _allQuestions.sublist(0, 10);
      } else {
        _quizQuestions = List.from(_allQuestions);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (!_hasCompletedToday && _quizQuestions.isNotEmpty) {
        _startTimer();
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isSubmitted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _submitQuiz();
      }
    });
  }

  void _selectAnswer(int questionIndex, String option) {
    setState(() => _answers[questionIndex] = option);
  }

  Future<void> _submitQuiz() async {
    _timer?.cancel();

    int correct = 0;
    for (int i = 0; i < _quizQuestions.length; i++) {
      if (_answers[i] == _quizQuestions[i].correctOption) {
        correct++;
      }
    }

    _todayScore = _quizQuestions.isNotEmpty
        ? ((correct / _quizQuestions.length) * 100).round()
        : 0;

    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = _todayKey();
      await prefs.setString('daily_quiz_$todayStr', '$_todayScore');

      final lastDate = prefs.getString('daily_quiz_last_date');
      if (lastDate != null) {
        final last = DateTime.parse(lastDate);
        final today = DateTime.now();
        final diff = DateTime(today.year, today.month, today.day)
            .difference(DateTime(last.year, last.month, last.day))
            .inDays;
        if (diff == 1) {
          _streak++;
        } else if (diff > 1) {
          _streak = 1;
        }
      } else {
        _streak = 1;
      }

      await prefs.setInt('daily_quiz_streak', _streak);
      await prefs.setString('daily_quiz_last_date', todayStr);

      int bonusXp = 0;
      if (_streak >= 7) {
        bonusXp = 100;
      } else if (_streak >= 3) {
        bonusXp = 50;
      }

      if (bonusXp > 0) {
        final userId = ref.read(authProvider).user?.id;
        if (userId != null) {
          await GamificationService().updateHeatmapEntry(
            userId: userId,
            date: DateTime.now(),
            tasksCompleted: 1,
          );
        }
      }

      _completionMap['daily_quiz_$todayStr'] = true;
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isSubmitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quiz'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quizQuestions.isEmpty
              ? const Center(child: Text('No questions available for daily quiz'))
              : _isSubmitted
                  ? _buildResultScreen()
                  : _hasCompletedToday
                      ? _buildCompletedView()
                      : _buildQuizView(),
    );
  }

  Widget _buildCompletedView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, size: 60, color: AppColors.success),
          ),
          const SizedBox(height: 24),
          const Text(
            'Already Completed Today!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Today\'s Score: $_todayScore%',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondaryOf(context)),
          ),
          const SizedBox(height: 16),
          _buildStreakCard(),
          const SizedBox(height: 24),
          _buildCompletionHeatmap(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizView() {
    if (_quizQuestions.isEmpty) return const SizedBox();

    final question = _quizQuestions[_currentQuestion];
    final options = question.options;
    final sortedKeys = options.keys.toList()..sort();

    return Column(
      children: [
        _buildStreakCard(),
        LinearProgressIndicator(
          value: (_currentQuestion + 1) / _quizQuestions.length,
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
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Question ${_currentQuestion + 1} of ${_quizQuestions.length}',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _remainingSeconds < 60
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
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
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  question.questionText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                  onPressed: _currentQuestion > 0
                      ? () => setState(() => _currentQuestion--)
                      : null,
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _currentQuestion < _quizQuestions.length - 1
                      ? () => setState(() => _currentQuestion++)
                      : _submitQuiz,
                  child: Text(
                    _currentQuestion < _quizQuestions.length - 1 ? 'Next' : 'Submit',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.streak, AppColors.streak.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.white, size: 36),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Quiz Streak: $_streak days',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _streak >= 7
                    ? '100 XP bonus!'
                    : _streak >= 3
                        ? '50 XP bonus!'
                        : 'Complete 3+ days for bonus XP',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    int correct = 0;
    for (int i = 0; i < _quizQuestions.length; i++) {
      if (_answers[i] == _quizQuestions[i].correctOption) {
        correct++;
      }
    }
    final total = _quizQuestions.length;
    final pct = total > 0 ? (correct / total * 100) : 0.0;
    final bonusXp = _streak >= 7 ? 100 : _streak >= 3 ? 50 : 0;

    return SingleChildScrollView(
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
                  '$correct / $total correct',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildStreakCard(),
          if (bonusXp > 0)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.badge.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.badge.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: AppColors.badge, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '+$bonusXp Bonus XP for $_streak day streak!',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.badge,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          _buildCompletionHeatmap(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
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
                  _remainingSeconds = 600;
                });
                _startTimer();
              },
              child: const Text('Retry Quiz'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCompletionHeatmap() {
    final days = List.generate(30, (i) {
      final date = DateTime.now().subtract(Duration(days: 29 - i));
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quiz Completions (Last 30 Days)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceOf(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderOf(context)),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 15,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final completed = _completionMap['daily_quiz_${days[index]}'] == true;
              return Container(
                decoration: BoxDecoration(
                  color: completed ? AppColors.success : AppColors.borderOf(context),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
