import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../theme/app_theme.dart';

class DailyChallengesScreen extends ConsumerStatefulWidget {
  const DailyChallengesScreen({super.key});

  @override
  ConsumerState<DailyChallengesScreen> createState() => _DailyChallengesScreenState();
}

class _DailyChallengesScreenState extends ConsumerState<DailyChallengesScreen> {
  bool _isLoading = true;
  bool _challenge1 = false;
  bool _challenge2 = false;
  bool _challenge3 = false;
  bool _allCompletedToday = false;
  bool _badgeAwarded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadData() async {
    final auth = ref.read(authProvider);
    if (auth.user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = _todayKey();
      final stored = prefs.getString('daily_challenges_$todayStr');

      if (stored != null) {
        final parts = stored.split(',');
        _challenge1 = parts.isNotEmpty && parts[0] == '1';
        _challenge2 = parts.length > 1 && parts[1] == '1';
        _challenge3 = parts.length > 2 && parts[2] == '1';
        _badgeAwarded = prefs.getBool('daily_challenges_badge_$todayStr') ?? false;
      } else {
        await _checkAutomaticCompletions(auth.user!.id);
      }

      _allCompletedToday = _challenge1 && _challenge2 && _challenge3;

      if (_allCompletedToday && !_badgeAwarded) {
        await prefs.setBool('daily_challenges_badge_$todayStr', true);
        _badgeAwarded = true;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkAutomaticCompletions(String userId) async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final sessions = await FocusService().getUserSessions(userId);
      for (final session in sessions) {
        if (session.startedAt.isAfter(todayStart) &&
            session.startedAt.isBefore(todayEnd) &&
            session.durationMins >= 25) {
          _challenge1 = true;
          break;
        }
      }

      final submissions = await TestService().getUserSubmissions(userId, limit: 50);
      for (final sub in submissions) {
        if (sub.submittedAt.isAfter(todayStart) &&
            sub.submittedAt.isBefore(todayEnd) &&
            sub.score != null &&
            sub.score! >= 70) {
          _challenge2 = true;
          break;
        }
      }

      _challenge3 = false;
    } catch (_) {}
  }

  Future<void> _toggleChallenge(int index) async {
    final auth = ref.read(authProvider);
    if (auth.user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = _todayKey();

      switch (index) {
        case 0:
          _challenge1 = !_challenge1;
          break;
        case 1:
          _challenge2 = !_challenge2;
          break;
        case 2:
          _challenge3 = !_challenge3;
          break;
      }

      _allCompletedToday = _challenge1 && _challenge2 && _challenge3;

      if (_allCompletedToday && !_badgeAwarded) {
        await prefs.setBool('daily_challenges_badge_$todayStr', true);
        _badgeAwarded = true;
      }

      final data = '${_challenge1 ? 1 : 0},${_challenge2 ? 1 : 0},${_challenge3 ? 1 : 0}';
      await prefs.setString('daily_challenges_$todayStr', data);

      setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Challenges'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_allCompletedToday)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.badge, AppColors.badge.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.emoji_events, size: 48, color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            'All Challenges Complete!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Bonus badge earned!',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  const Text(
                    'Today\'s Challenges',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete all 3 to earn a bonus badge',
                    style: TextStyle(color: AppColors.textSecondaryOf(context), fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  _buildChallengeCard(
                    index: 0,
                    title: 'Complete a Focus Session',
                    subtitle: 'Study for 25+ minutes in a focus session',
                    icon: Icons.timer,
                    isCompleted: _challenge1,
                  ),
                  const SizedBox(height: 12),
                  _buildChallengeCard(
                    index: 1,
                    title: 'Score 70%+ on Any Test',
                    subtitle: 'Pass any test with 70% or higher',
                    icon: Icons.quiz,
                    isCompleted: _challenge2,
                  ),
                  const SizedBox(height: 12),
                  _buildChallengeCard(
                    index: 2,
                    title: 'Master 5 Flashcard Topics',
                    subtitle: 'Review and master 5 flashcard topics',
                    icon: Icons.style,
                    isCompleted: _challenge3,
                  ),
                  const SizedBox(height: 32),
                  _buildProgressRing(),
                ],
              ),
            ),
    );
  }

  Widget _buildChallengeCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
  }) {
    return GestureDetector(
      onTap: () => _toggleChallenge(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.success.withOpacity(0.05)
              : AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
                color: isCompleted ? AppColors.success : AppColors.borderOf(context),
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: isCompleted ? 1.0 : 0.0,
                    strokeWidth: 3,
                    backgroundColor: AppColors.borderOf(context),
                    valueColor: AlwaysStoppedAnimation(
                      isCompleted ? AppColors.success : AppColors.primary,
                    ),
                  ),
                  Icon(
                    isCompleted ? Icons.check : icon,
                    color: isCompleted ? AppColors.success : AppColors.primary,
                    size: 22,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? AppColors.textSecondaryOf(context) : AppColors.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHintOf(context),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
            color: isCompleted ? AppColors.success : AppColors.borderOf(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.radio_button_unchecked,
                color: isCompleted ? Colors.white : AppColors.textHintOf(context),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRing() {
    final completedCount = [_challenge1, _challenge2, _challenge3]
        .where((c) => c)
        .length;
    final progress = completedCount / 3.0;

    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: AppColors.borderOf(context),
                    valueColor: AlwaysStoppedAnimation(
                      _allCompletedToday ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$completedCount/3',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _allCompletedToday ? AppColors.success : AppColors.primary,
                      ),
                    ),
                    Text(
                      'completed',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryOf(context),
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
}
