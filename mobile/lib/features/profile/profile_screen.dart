import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _badgeCount = 0;
  int _streakDays = 0;
  double _focusHours = 0.0;

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
        BadgeService().getUserBadges(userId),
        GamificationService().getHeatmapData(
          userId,
          startDate: DateTime.now().subtract(const Duration(days: 90)),
        ),
        FocusService().getTotalFocusHours(userId),
      ]);

      if (!mounted) return;
      setState(() {
        _badgeCount = (results[0] as List).length;
        _streakDays = _computeStreak(results[1] as List<HeatmapEntry>);
        _focusHours = results[2] as double;
      });
    } catch (e) {
      // Silently handle errors - data stays at defaults
    }
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
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showEditProfileDialog(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(auth),
            const SizedBox(height: 24),
            _buildStatsRow(auth),
            const SizedBox(height: 24),
            _buildMenuSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthState auth) {
    final name = auth.user?.userMetadata?['full_name'] ?? 'Student';
    final email = auth.user?.email ?? '';
    final completion = auth.profile?.profileCompletion ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 50,
            lineWidth: 6,
            percent: completion / 100,
            backgroundColor: AppColors.border,
            progressColor: AppColors.primary,
            center: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${auth.profile?.examCategory ?? "Not set"} • ${auth.profile?.targetYear ?? ""}',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AuthState auth) {
    return Row(
      children: [
        _buildStatCard('Badges', '$_badgeCount', Icons.emoji_events, AppColors.badge),
        const SizedBox(width: 12),
        _buildStatCard('Streak', '${_streakDays}d', Icons.local_fire_department, AppColors.streak),
        const SizedBox(width: 12),
        _buildStatCard('Hours', '${_focusHours.toStringAsFixed(1)}', Icons.access_time, AppColors.primary),
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authProvider);
    final nameController = TextEditingController(text: auth.user?.userMetadata?['full_name'] ?? '');
    final institutionController = TextEditingController(text: auth.profile?.institution ?? '');
    final cityController = TextEditingController(text: auth.profile?.city ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: institutionController,
                decoration: const InputDecoration(labelText: 'Institution'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final userId = auth.user?.id;
              if (userId == null) return;
              final updates = <String, dynamic>{};
              if (nameController.text.isNotEmpty) updates['full_name'] = nameController.text;
              updates['institution'] = institutionController.text;
              updates['city'] = cityController.text;
              
              await ref.read(authProvider.notifier).updateProfile(updates);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated!'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            Icons.badge_outlined,
            'My Badges',
            () => context.go('/gamification'),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            Icons.leaderboard_outlined,
            'Leaderboard',
            () => context.go('/gamification/leaderboard'),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            Icons.group_outlined,
            'Peer Rooms',
            () => context.go('/profile/peer-rooms'),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            Icons.sticky_note_2_outlined,
            'My Notes',
            () => context.go('/focus/notes'),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            Icons.history,
            'Test History',
            () => context.go('/tests'),
          ),
          const Divider(height: 1),
          _buildMenuItem(
            Icons.logout,
            'Sign Out',
            () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go('/login');
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textHint,
      ),
      onTap: onTap,
    );
  }
}
