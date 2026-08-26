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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  double _focusHours = 0.0;
  int _badgeCount = 0;
  int _streakDays = 0;
  List<ScheduleItem> _todayItems = [];
  List<PomodoroSession> _recentSessions = [];
  Exam? _userExam;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = ref.read(authProvider);
    final userId = auth.user?.id;
    if (userId == null) return;

    final focusService = FocusService();
    final badgeService = BadgeService();
    final gamificationService = GamificationService();
    final scheduleService = ScheduleService();

    try { _focusHours = await focusService.getTotalFocusHours(userId); } catch (_) {}
    try { _badgeCount = (await badgeService.getUserBadges(userId)).length; } catch (_) {}
    try {
      final heatmap = await gamificationService.getHeatmapData(userId, startDate: DateTime.now().subtract(const Duration(days: 90)));
      _streakDays = StreakUtils.computeCurrentStreak(heatmap);
    } catch (_) {}
    try { _todayItems = await _loadTodayItems(userId); } catch (_) {}
    try { _recentSessions = await focusService.getUserSessions(userId, limit: 3); } catch (_) {}

    final examCategory = auth.profile?.examCategory;
    if (examCategory != null && examCategory.isNotEmpty) {
      try {
        _userExam = await SyllabusService().getExamForCategory(examCategory);
      } catch (_) {}
    }

    if (mounted) setState(() {});
  }

  Future<List<ScheduleItem>> _loadTodayItems(String userId) async {
    final schedule = await ScheduleService().getActiveSchedule(userId);
    if (schedule == null) return [];
    return ScheduleService().getScheduleItems(schedule.id, date: DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.menu_book, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('EduTrack'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/profile/reminders'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(context, auth),
              if (_userExam?.nextExamDate != null) ...[
                const SizedBox(height: 16),
                _buildExamCountdown(context),
              ],
              const SizedBox(height: 16),
              _buildQuickStats(context),
              const SizedBox(height: 16),
              _buildTodaySchedule(context),
              const SizedBox(height: 16),
              _buildQuickActions(context),
              const SizedBox(height: 16),
              _buildRecentActivity(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AuthState auth) {
    final name = auth.profile != null
        ? (auth.user?.userMetadata?['full_name'] ?? 'Student')
        : 'Student';
    final exam = auth.profile?.examCategory ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 32,
            lineWidth: 4,
            percent: (auth.profile?.profileCompletion ?? 0) / 100,
            backgroundColor: Colors.white24,
            progressColor: Colors.white,
            center: Text(
              '${(auth.profile?.profileCompletion ?? 0).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey, $name!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exam.isNotEmpty ? 'Preparing for ${getExamDisplayName(exam)}' : 'Complete your profile',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _getAdjustedExamDate(Exam exam, int? targetYear) {
    if (exam.nextExamDate == null) return null;
    final dbYear = exam.nextExamDate!.year;
    final year = targetYear ?? dbYear;
    if (year == dbYear) return exam.nextExamDate;
    return DateTime(year, exam.nextExamDate!.month, exam.nextExamDate!.day);
  }

  Widget _buildExamCountdown(BuildContext context) {
    final auth = ref.read(authProvider);
    final targetYear = auth.profile?.targetYear;
    final exam = _userExam!;
    final examDate = _getAdjustedExamDate(exam, targetYear);
    if (examDate == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final daysLeft = examDate.difference(now).inDays;
    final color = daysLeft <= 30
        ? AppColors.error
        : daysLeft <= 90
            ? AppColors.streak
            : AppColors.primary;

    final dateStr = '${examDate.year}-${examDate.month.toString().padLeft(2, '0')}-${examDate.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.timer_outlined, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Days until ${exam.name}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateStr (${examDate.year})',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$daysLeft',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'days',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(context, 'Current Streak', '$_streakDays days', Icons.local_fire_department, AppColors.streak),
        const SizedBox(width: 12),
        _buildStatCard(context, 'Focus Hours', '${_focusHours.toStringAsFixed(1)}h', Icons.access_time, AppColors.primary),
        const SizedBox(width: 12),
        _buildStatCard(context, 'Badges', '$_badgeCount', Icons.emoji_events, AppColors.badge),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderOf(context)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondaryOf(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySchedule(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Schedule",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/schedule'),
              child: const Text('View All'),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceOf(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderOf(context)),
          ),
          child: _todayItems.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No schedule items for today',
                    style: TextStyle(color: AppColors.textSecondaryOf(context)),
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < _todayItems.length; i++) ...[
                      if (i > 0) const Divider(height: 24),
                      _buildScheduleItem(
                        context,
                        _todayItems[i].title,
                        '${_todayItems[i].startTime ?? ''} - ${_todayItems[i].endTime ?? ''}',
                        _todayItems[i].status == ScheduleItemStatus.completed,
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(BuildContext context, String title, String time, bool completed) {
    return Row(
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? AppColors.success : AppColors.textHintOf(context),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: completed ? TextDecoration.lineThrough : null,
                  color: completed ? AppColors.textHintOf(context) : AppColors.textPrimaryOf(context),
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'icon': Icons.play_arrow_rounded, 'label': 'Start\nFocus', 'route': '/focus', 'color': AppColors.primary, 'isTab': true},
      {'icon': Icons.quiz_outlined, 'label': 'Take\nTest', 'route': '/tests', 'color': AppColors.secondary, 'isTab': true},
      {'icon': Icons.school_outlined, 'label': 'Exam\nPrep', 'route': '/profile/exam-checklist', 'color': AppColors.warning, 'isTab': false},
      {'icon': Icons.style_outlined, 'label': 'Flash\nCards', 'route': '/focus/flashcards', 'color': AppColors.accent, 'isTab': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: actions.map((action) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  final route = action['route'] as String;
                  final isTab = action['isTab'] as bool;
                  if (isTab) {
                    context.go(route);
                  } else {
                    context.push(route);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (action['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        action['icon'] as IconData,
                        color: action['color'] as Color,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: action['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_recentSessions.isEmpty && _todayItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderOf(context)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.textSecondaryOf(context), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Complete tasks to see activity here', style: TextStyle(color: AppColors.textSecondaryOf(context))),
                ),
              ],
            ),
          )
        else
          ..._recentSessions.map((session) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderOf(context)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.access_time, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Focus Session', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(
                        '${session.durationMins} min • ${session.status}',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context)),
                      ),
                    ],
                  ),
                ),
                Icon(
                  session.status == 'completed' ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: session.status == 'completed' ? AppColors.success : AppColors.textHintOf(context),
                  size: 20,
                ),
              ],
            ),
          )),
      ],
    );
  }
}
