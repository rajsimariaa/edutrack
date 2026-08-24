import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../utils/exam_utils.dart';
import '../../utils/streak_utils.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  bool _isLoading = true;

  int _totalTopics = 0;
  int _masteredTopics = 0;
  int _streakDays = 0;
  double _totalFocusHours = 0;
  int _totalTestsTaken = 0;

  List<_SubjectProgressData> _subjectProgress = [];
  List<_DailyActivity> _weeklyActivity = [];
  double _avgScore = 0;
  double _bestScore = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final examCategory = ref.read(authProvider).profile?.examCategory;
      final exam = examCategory != null
          ? await SyllabusService().getExamForCategory(examCategory)
          : null;

      final results = await Future.wait([
        if (exam != null) SyllabusService().getSubjects(exam.id) else Future.value(<Subject>[]),
        FocusService().getTotalFocusHours(userId),
        GamificationService().getHeatmapData(
          userId,
          startDate: DateTime.now().subtract(const Duration(days: 90)),
        ),
        TestService().getTestStats(userId),
      ]);

      final subjects = results[0] as List<Subject>;
      final focusHours = results[1] as double;
      final heatmap = results[2] as List<HeatmapEntry>;
      final testStats = results[3] as Map<String, dynamic>;

      List<_SubjectProgressData> subjectData = [];
      int totalTopics = 0;
      int masteredTopics = 0;

      for (final subject in subjects) {
        final progress = await SyllabusService().getSubjectProgress(userId, subject.id);
        final total = progress['total']!.toInt();
        final mastered = progress['mastered']!.toInt();
        final inProgress = progress['inProgress']!.toInt();
        totalTopics += total;
        masteredTopics += mastered;

        subjectData.add(_SubjectProgressData(
          name: subject.name,
          total: total,
          mastered: mastered,
          inProgress: inProgress,
        ));
      }

      final streak = StreakUtils.computeCurrentStreak(heatmap);
      final weekly = _computeWeeklyActivity(heatmap);

      if (!mounted) return;
      setState(() {
        _totalTopics = totalTopics;
        _masteredTopics = masteredTopics;
        _streakDays = streak;
        _totalFocusHours = focusHours;
        _totalTestsTaken = testStats['totalTests'] ?? 0;
        _subjectProgress = subjectData;
        _weeklyActivity = weekly;
        _avgScore = (testStats['avgScore'] ?? 0).toDouble();
        _bestScore = (testStats['bestScore'] ?? 0).toDouble();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<_DailyActivity> _computeWeeklyActivity(List<HeatmapEntry> heatmap) {
    final now = DateTime.now();
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<_DailyActivity> result = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final entry = heatmap.where((h) =>
          h.activityDate.year == date.year &&
          h.activityDate.month == date.month &&
          h.activityDate.day == date.day);
      final focusMins = entry.fold<int>(0, (sum, e) => sum + e.focusMins);
      result.add(_DailyActivity(
        label: dayLabels[(date.weekday - 1) % 7],
        focusMins: focusMins,
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_totalTopics == 0 && _totalTestsTaken == 0 && _totalFocusHours == 0) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(),
            const SizedBox(height: 20),
            _buildWeeklyActivitySection(),
            const SizedBox(height: 20),
            if (_subjectProgress.isNotEmpty) ...[
              _buildSubjectProgressSection(),
              const SizedBox(height: 20),
            ],
            _buildTestPerformanceSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Analytics Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start studying and taking tests to see your progress here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    final overallProgress =
        _totalTopics > 0 ? _masteredTopics / _totalTopics : 0.0;
    final percentLabel = (overallProgress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircularPercentIndicator(
                radius: 52,
                lineWidth: 8,
                percent: overallProgress.clamp(0.0, 1.0),
                backgroundColor: Colors.white24,
                progressColor: Colors.white,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentLabel%',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'mastered',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildOverviewStat(
                      Icons.book_outlined,
                      '$_masteredTopics/$_totalTopics',
                      'Topics',
                    ),
                    const SizedBox(height: 12),
                    _buildOverviewStat(
                      Icons.local_fire_department_outlined,
                      '$_streakDays',
                      'Day Streak',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildOverviewStat(
                      Icons.access_time_outlined,
                      '${_totalFocusHours.toStringAsFixed(1)}',
                      'Focus Hrs',
                    ),
                    const SizedBox(height: 12),
                    _buildOverviewStat(
                      Icons.quiz_outlined,
                      '$_totalTestsTaken',
                      'Tests',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyActivitySection() {
    final maxMins = _weeklyActivity.fold<int>(0, (max, d) => d.focusMins > max ? d.focusMins : max);

    return _buildSectionCard(
      title: 'Weekly Activity',
      icon: Icons.bar_chart,
      child: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weeklyActivity.map((day) {
                final heightRatio =
                    maxMins > 0 ? day.focusMins / maxMins : 0.0;
                final isToday = day.label == _getTodayLabel();

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (day.focusMins > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${day.focusMins}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isToday
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: heightRatio > 0 ? (heightRatio * 100).clamp(6.0, 100.0) : 6,
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColors.primary
                                : day.focusMins > 0
                                    ? AppColors.primaryLight.withOpacity(0.6)
                                    : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          day.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  String _getTodayLabel() {
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[(DateTime.now().weekday - 1) % 7];
  }

  Widget _buildSubjectProgressSection() {
    return _buildSectionCard(
      title: 'Subject Progress',
      icon: Icons.school_outlined,
      child: Column(
        children: _subjectProgress.map((subject) {
          final progress =
              subject.total > 0 ? subject.mastered / subject.total : 0.0;
          final percent = (progress * 100).toStringAsFixed(0);
          final color = progress < 0.3
              ? AppColors.notStarted
              : progress < 0.7
                  ? AppColors.inProgress
                  : AppColors.mastered;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        subject.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${subject.mastered}/${subject.total}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (_subjectProgress.indexOf(subject) <
                    _subjectProgress.length - 1)
                  const SizedBox(height: 4),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTestPerformanceSection() {
    final hasTests = _totalTestsTaken > 0;

    return _buildSectionCard(
      title: 'Test Performance',
      icon: Icons.quiz_outlined,
      child: hasTests
          ? Column(
              children: [
                Row(
                  children: [
                    _buildTestStat('Average', '${_avgScore.toStringAsFixed(1)}%', AppColors.primary),
                    const SizedBox(width: 12),
                    _buildTestStat('Best', '${_bestScore.toStringAsFixed(1)}%', AppColors.mastered),
                    const SizedBox(width: 12),
                    _buildTestStat('Taken', '$_totalTestsTaken', AppColors.inProgress),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Score Distribution',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${_avgScore.toStringAsFixed(1)}% avg',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (_avgScore / 100).clamp(0.0, 1.0),
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _avgScore >= 70
                              ? AppColors.mastered
                              : _avgScore >= 40
                                  ? AppColors.inProgress
                                  : AppColors.notStarted,
                        ),
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '0%',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                        Text(
                          '100%',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )
          : const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No tests taken yet. Start a test to see your performance.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
    );
  }

  Widget _buildTestStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SubjectProgressData {
  final String name;
  final int total;
  final int mastered;
  final int inProgress;

  _SubjectProgressData({
    required this.name,
    required this.total,
    required this.mastered,
    required this.inProgress,
  });
}

class _DailyActivity {
  final String label;
  final int focusMins;

  _DailyActivity({required this.label, required this.focusMins});
}
