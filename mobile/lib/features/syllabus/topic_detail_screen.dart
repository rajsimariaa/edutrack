import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class TopicDetailScreen extends ConsumerStatefulWidget {
  final String topicId;
  final String? topicName;
  final String? topicDescription;
  const TopicDetailScreen({
    super.key,
    required this.topicId,
    this.topicName,
    this.topicDescription,
  });

  @override
  ConsumerState<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends ConsumerState<TopicDetailScreen> {
  TopicStatus _status = TopicStatus.notStarted;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final auth = ref.read(authProvider);
    if (auth.user == null) return;

    try {
      final progress = await SyllabusService().getUserProgress(auth.user!.id);
      final topicProgress = progress.where((p) => p.topicId == widget.topicId);
      if (topicProgress.isNotEmpty) {
        setState(() {
          _status = topicProgress.first.status;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(TopicStatus status) async {
    final auth = ref.read(authProvider);
    if (auth.user == null) return;

    try {
      await SyllabusService().updateTopicProgress(
        userId: auth.user!.id,
        topicId: widget.topicId,
        status: status,
      );
      setState(() => _status = status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Topic marked as ${status.name}')),
        );
      }
    } catch (_) {}
  }

  Color _statusColor(TopicStatus status) {
    switch (status) {
      case TopicStatus.notStarted:
        return AppColors.notStarted;
      case TopicStatus.inProgress:
        return AppColors.inProgress;
      case TopicStatus.mastered:
        return AppColors.mastered;
    }
  }

  String _statusLabel(TopicStatus status) {
    switch (status) {
      case TopicStatus.notStarted:
        return 'Not Started';
      case TopicStatus.inProgress:
        return 'In Progress';
      case TopicStatus.mastered:
        return 'Mastered';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicName ?? 'Topic Detail'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.topic_outlined,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.topicName ?? 'Topic',
                                style: TextStyle(
                                   fontSize: 20,
                                   fontWeight: FontWeight.bold,
                                   color: AppColors.textPrimaryOf(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (widget.topicDescription != null && widget.topicDescription!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            widget.topicDescription!,
                            style: TextStyle(
                              fontSize: 14,
                               color: AppColors.textSecondaryOf(context),
                              height: 1.5,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _statusColor(_status).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusLabel(_status),
                            style: TextStyle(
                              color: _statusColor(_status),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildActionCard(
                    title: 'Study Flashcards',
                    subtitle: 'Review key concepts with interactive flashcards',
                    icon: Icons.style_outlined,
                    color: AppColors.primary,
                    onTap: () => context.push('/focus/flashcards'),
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    title: 'View Forum',
                    subtitle: 'Discuss this topic with other students',
                    icon: Icons.forum_outlined,
                    color: AppColors.accent,
                    onTap: () => context.push('/syllabus/forum/${widget.topicId}', extra: widget.topicName),
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    title: 'Study Notes',
                    subtitle: 'Access your notes for this topic',
                    icon: Icons.note_add_outlined,
                    color: AppColors.secondary,
                    onTap: () => context.push('/focus/notes'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Update Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusButton(
                          context,
                          'Not Started',
                          TopicStatus.notStarted,
                          AppColors.notStarted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatusButton(
                          context,
                          'In Progress',
                          TopicStatus.inProgress,
                          AppColors.inProgress,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatusButton(
                          context,
                          'Mastered',
                          TopicStatus.mastered,
                          AppColors.mastered,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textHintOf(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context, String label, TopicStatus status, Color color) {
    final isSelected = _status == status;
    return GestureDetector(
      onTap: () => _updateStatus(status),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : AppColors.borderOf(context),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? color : AppColors.textHintOf(context),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : AppColors.textSecondaryOf(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
