import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = ref.read(authProvider);
    final userId = auth.user?.id;
    if (userId == null) return;

    try {
      final results = await Future.wait([
        FocusService().getTotalFocusHours(userId),
        BadgeService().getUserBadges(userId),
        GamificationService().getHeatmapData(
          userId,
          startDate: DateTime.now().subtract(const Duration(days: 90)),
        ),
        _loadTodayItems(userId),
      ]);

      if (!mounted) return;
      setState(() {
        _focusHours = results[0] as double;
        _badgeCount = (results[1] as List).length;
        _streakDays = _computeStreak(results[2] as List<HeatmapEntry>);
        _todayItems = results[3] as List<ScheduleItem>;
      });
    } catch (e) {
      // Silently handle errors - data stays at defaults
    }
  }

  Future<List<ScheduleItem>> _loadTodayItems(String userId) async {
    final schedule = await ScheduleService().getActiveSchedule(userId);
    if (schedule == null) return [];
    return ScheduleService().getScheduleItems(schedule.id, date: DateTime.now());
  }

  int _computeStreak(List<HeatmapEntry> heatmap) {
    if (heatmap.isEmpty) return 0;
    final today = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final hasEntry = heatmap.any((h) =>
          h.activityDate.year == date.year &&
          h.activityDate.month == date.month &&
          h.activityDate.day == date.day);
      if (hasEntry) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
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
            onPressed: () {},
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
                  exam.isNotEmpty ? 'Preparing for $exam' : 'Complete your profile',
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

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        _buildStatCard('Current Streak', '$_streakDays days', Icons.local_fire_department, AppColors.streak),
        const SizedBox(width: 12),
        _buildStatCard('Focus Hours', '${_focusHours.toStringAsFixed(1)}h', Icons.access_time, AppColors.primary),
        const SizedBox(width: 12),
        _buildStatCard('Badges', '$_badgeCount', Icons.emoji_events, AppColors.badge),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
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
                color: AppColors.textSecondary,
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
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: _todayItems.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No schedule items for today',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < _todayItems.length; i++) ...[
                      if (i > 0) const Divider(height: 24),
                      _buildScheduleItem(
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

  Widget _buildScheduleItem(String title, String time, bool completed) {
    return Row(
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? AppColors.success : AppColors.textHint,
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
                  color: completed ? AppColors.textHint : AppColors.textPrimary,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
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
      {'icon': Icons.play_arrow_rounded, 'label': 'Start\nFocus', 'route': '/focus', 'color': AppColors.primary},
      {'icon': Icons.quiz_outlined, 'label': 'Take\nTest', 'route': '/tests', 'color': AppColors.secondary},
      {'icon': Icons.sticky_note_2_outlined, 'label': 'Quick\nNotes', 'route': '/focus/notes', 'color': AppColors.accent},
      {'icon': Icons.leaderboard_outlined, 'label': 'Leader\nBoard', 'route': '/gamification/leaderboard', 'color': AppColors.streak},
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
                onTap: () => context.go(action['route'] as String),
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Complete tasks to see activity here',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
