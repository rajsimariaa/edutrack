import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class GamificationScreen extends ConsumerStatefulWidget {
  const GamificationScreen({super.key});

  @override
  ConsumerState<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends ConsumerState<GamificationScreen> {
  final _badgeService = BadgeService();
  List<Badge> _allBadges = [];
  List<UserBadge> _userBadges = [];
  List<HeatmapEntry> _heatmap = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = ref.read(authProvider);
    if (auth.user == null) return;

    try {
      _allBadges = await _badgeService.getAllBadges();
      _userBadges = await _badgeService.getUserBadges(auth.user!.id);
      _heatmap = await GamificationService().getHeatmapData(
        auth.user!.id,
        startDate: DateTime.now().subtract(const Duration(days: 365)),
      );
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeatmap(),
                  const SizedBox(height: 24),
                  _buildBadgeShelf(),
                  const SizedBox(height: 24),
                  _buildAllBadges(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeatmap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Streak',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStreakStat('Current Streak', '5 days', AppColors.streak),
                  _buildStreakStat('Longest Streak', '12 days', AppColors.primary),
                  _buildStreakStat('Total Days', '45 days', AppColors.accent),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: _buildHeatmapGrid(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreakStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildHeatmapGrid() {
    final days = List.generate(90, (i) => DateTime.now().subtract(Duration(days: 89 - i)));
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 15,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final date = days[index];
        final entry = _heatmap.where(
          (h) => h.activityDate.day == date.day &&
              h.activityDate.month == date.month &&
              h.activityDate.year == date.year,
        ).firstOrNull;

        final intensity = entry == null
            ? 0
            : entry.tasksCompleted > 3
                ? 3
                : entry.tasksCompleted > 1
                    ? 2
                    : 1;

        return Container(
          decoration: BoxDecoration(
            color: _heatmapColor(intensity),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }

  Color _heatmapColor(int intensity) {
    switch (intensity) {
      case 0:
        return AppColors.border;
      case 1:
        return AppColors.primary.withOpacity(0.3);
      case 2:
        return AppColors.primary.withOpacity(0.6);
      case 3:
        return AppColors.primary;
      default:
        return AppColors.border;
    }
  }

  Widget _buildBadgeShelf() {
    final pinnedBadges = _userBadges.where((b) => b.isPinned).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Featured Badges',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: pinnedBadges.isEmpty
              ? Center(
                  child: Text(
                    'Pin up to 3 badges to showcase',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pinnedBadges.length,
                  itemBuilder: (context, index) {
                    final userBadge = pinnedBadges[index];
                    final badge = _allBadges
                        .where((b) => b.id == userBadge.badgeId)
                        .firstOrNull;
                    if (badge == null) return const SizedBox();
                    return _buildBadgeItem(badge, isPinned: true);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAllBadges() {
    final unlockedIds = _userBadges.map((b) => b.badgeId).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Badges',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _allBadges.map((badge) {
            final isUnlocked = unlockedIds.contains(badge.id);
            return _buildBadgeItem(badge, isUnlocked: isUnlocked);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBadgeItem(Badge badge, {bool isUnlocked = false, bool isPinned = false}) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(badge, isUnlocked),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? _rarityColor(badge.rarityTier).withOpacity(0.2)
                  : AppColors.border,
              shape: BoxShape.circle,
              border: Border.all(
                color: isPinned
                    ? AppColors.badge
                    : isUnlocked
                        ? _rarityColor(badge.rarityTier)
                        : AppColors.border,
                width: isPinned ? 3 : 1,
              ),
            ),
            child: Icon(
              isUnlocked ? Icons.emoji_events : Icons.lock_outline,
              color: isUnlocked ? _rarityColor(badge.rarityTier) : AppColors.textHint,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isUnlocked ? AppColors.textPrimary : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Color _rarityColor(String tier) {
    switch (tier) {
      case 'common':
        return Colors.grey;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return AppColors.badge;
      default:
        return Colors.grey;
    }
  }

  void _showBadgeDetails(Badge badge, bool isUnlocked) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _rarityColor(badge.rarityTier).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUnlocked ? Icons.emoji_events : Icons.lock_outline,
                  size: 40,
                  color: _rarityColor(badge.rarityTier),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                badge.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _rarityColor(badge.rarityTier).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge.rarityTier.toUpperCase(),
                  style: TextStyle(
                    color: _rarityColor(badge.rarityTier),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.description ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
