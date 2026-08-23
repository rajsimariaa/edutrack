import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  final _gamificationService = GamificationService();
  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = true;
  String _selectedTab = 'weekly';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = ref.read(authProvider);
    if (auth.profile == null) return;

    try {
      _entries = await _gamificationService.getLeaderboard(
        examCategory: auth.profile!.examCategory,
        boardType: _selectedTab,
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
        title: const Text('Leaderboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/gamification');
            }
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildTab('weekly', 'Weekly'),
                const SizedBox(width: 8),
                _buildTab('monthly', 'Monthly'),
                const SizedBox(width: 8),
                _buildTab('all_time', 'All Time'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? const Center(child: Text('No entries yet'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return _buildLeaderboardEntry(entry, index + 1);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String value, String label) {
    final isSelected = _selectedTab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = value;
            _isLoading = true;
          });
          _loadData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardEntry(Map<String, dynamic> entry, int rank) {
    final user = entry['users'] as Map<String, dynamic>?;
    final pinnedBadges = entry['pinned_badges'] as List<dynamic>?;
    final score = (entry['score'] as num?)?.toDouble() ?? 0;
    final isTop3 = rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTop3
            ? _rankColor(rank).withOpacity(0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTop3 ? _rankColor(rank) : AppColors.border,
          width: isTop3 ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: isTop3
                ? Icon(Icons.emoji_events, color: _rankColor(rank), size: 28)
                : Text(
                    '#$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              (user?['full_name'] as String? ?? 'U')[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?['full_name'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (pinnedBadges != null && pinnedBadges.isNotEmpty)
                  Row(
                    children: pinnedBadges.take(3).map((b) {
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.badge.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          size: 10,
                          color: AppColors.badge,
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          Text(
            '${score.toStringAsFixed(0)} pts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.textHint;
    }
  }
}
