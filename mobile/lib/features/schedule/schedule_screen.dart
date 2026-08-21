import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  final _scheduleService = ScheduleService();
  Schedule? _activeSchedule;
  List<ScheduleItem> _todayItems = [];
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
      final schedule = await _scheduleService.getActiveSchedule(auth.user!.id);
      if (schedule != null) {
        final items = await _scheduleService.getScheduleItems(
          schedule.id,
          date: DateTime.now(),
        );
        setState(() {
          _activeSchedule = schedule;
          _todayItems = items;
        });
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _todayItems
        .where((i) => i.status == ScheduleItemStatus.completed)
        .length;
    final totalCount = _todayItems.length;
    final pct = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressCard(pct, completedCount, totalCount),
                  const SizedBox(height: 16),
                  const Text(
                    'Today\'s Tasks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_todayItems.isEmpty)
                    _buildEmptyState()
                  else
                    ...(_todayItems.map((item) => _buildTaskCard(item))),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildProgressCard(double pct, int completed, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 40,
            lineWidth: 6,
            percent: pct,
            backgroundColor: Colors.white24,
            progressColor: Colors.white,
            center: Text(
              '${(pct * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today\'s Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$completed of $total tasks completed',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_available, size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              'No tasks for today',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a schedule to get started',
              style: TextStyle(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(ScheduleItem item) {
    final isCompleted = item.status == ScheduleItemStatus.completed;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: GestureDetector(
          onTap: () {
            _scheduleService.updateItemStatus(
              item.id,
              isCompleted
                  ? ScheduleItemStatus.pending
                  : ScheduleItemStatus.completed,
            );
            _loadData();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.radio_button_unchecked,
              color: isCompleted ? AppColors.success : AppColors.textHint,
            ),
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? AppColors.textHint : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${item.startTime ?? ""} ${item.endTime != null ? "- ${item.endTime}" : ""}',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'reschedule') {
              _scheduleService.rescheduleItem(
                item.id,
                DateTime.now().add(const Duration(days: 1)),
              );
              _loadData();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'reschedule',
              child: Text('Reschedule'),
            ),
          ],
        ),
      ),
    );
  }
}
