import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';
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
  DateTime _selectedDate = DateTime.now();

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
          date: _selectedDate,
        );
        setState(() {
          _activeSchedule = schedule;
          _todayItems = items;
        });
      } else {
        setState(() {
          _activeSchedule = null;
          _todayItems = [];
        });
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2029),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
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
            onPressed: _pickDate,
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
                  if (_activeSchedule != null)
                    _buildProgressCard(pct, completedCount, totalCount),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isToday(_selectedDate)
                            ? "Today's Tasks"
                            : DateFormat('MMM d, yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedDate = DateTime.now());
                          _loadData();
                        },
                        child: const Text('Today'),
                      ),
                    ],
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
        onPressed: () {
          if (_activeSchedule != null) {
            _showAddTaskDialog();
          } else {
            _showCreateScheduleDialog();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_activeSchedule != null ? 'Add Task' : 'Create Schedule'),
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
              'No tasks for this day',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _activeSchedule == null
                  ? 'Create a schedule to get started'
                  : 'Tap + to add a task',
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
              _showRescheduleDialog(item);
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

  void _showCreateScheduleDialog() {
    final titleController = TextEditingController(text: 'My Study Plan');
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: titleController, decoration: const InputDecoration(hintText: 'Schedule title')),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.play_arrow, color: AppColors.primary),
                title: const Text('Start Date'),
                subtitle: Text(DateFormat('MMM d, yyyy').format(startDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2029),
                  );
                  if (picked != null) setModalState(() => startDate = picked);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.stop, color: AppColors.error),
                title: const Text('End Date'),
                subtitle: Text(DateFormat('MMM d, yyyy').format(endDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: endDate,
                    firstDate: startDate,
                    lastDate: DateTime(2029),
                  );
                  if (picked != null) setModalState(() => endDate = picked);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final auth = ref.read(authProvider);
                  if (auth.user == null || titleController.text.isEmpty) return;
                  await _scheduleService.createSchedule(
                    userId: auth.user!.id,
                    title: titleController.text,
                    startDate: startDate,
                    endDate: endDate,
                  );
                  Navigator.pop(context);
                  _loadData();
                },
                child: const Text('Create Schedule'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    if (_activeSchedule == null) return;
    final titleController = TextEditingController();
    DateTime taskDate = _selectedDate;
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: titleController, decoration: const InputDecoration(hintText: 'Task title')),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                title: const Text('Date'),
                subtitle: Text(DateFormat('MMM d, yyyy').format(taskDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: taskDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2029),
                  );
                  if (picked != null) setModalState(() => taskDate = picked);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time, color: AppColors.primary),
                title: const Text('Start Time'),
                subtitle: Text(startTime.format(context)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );
                  if (picked != null) setModalState(() => startTime = picked);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time, color: AppColors.secondary),
                title: const Text('End Time'),
                subtitle: Text(endTime.format(context)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );
                  if (picked != null) setModalState(() => endTime = picked);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty) return;
                  await _scheduleService.createScheduleItem(
                    scheduleId: _activeSchedule!.id,
                    title: titleController.text,
                    scheduledDate: taskDate,
                    startTime: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                    endTime: '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                  );
                  Navigator.pop(context);
                  _loadData();
                },
                child: const Text('Add Task'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showRescheduleDialog(ScheduleItem item) {
    DateTime newDate = item.scheduledDate;
    TimeOfDay newTime = TimeOfDay(
      hour: item.startTime != null ? int.tryParse(item.startTime!.split(':')[0]) ?? 9 : 9,
      minute: item.startTime != null ? int.tryParse(item.startTime!.split(':')[1]) ?? 0 : 0,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reschedule Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(item.title, style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                title: const Text('New Date'),
                subtitle: Text(DateFormat('MMM d, yyyy').format(newDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: newDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2029),
                  );
                  if (picked != null) setModalState(() => newDate = picked);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time, color: AppColors.primary),
                title: const Text('New Time'),
                subtitle: Text(newTime.format(context)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: newTime,
                  );
                  if (picked != null) setModalState(() => newTime = picked);
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final dateTime = DateTime(
                    newDate.year, newDate.month, newDate.day,
                    newTime.hour, newTime.minute,
                  );
                  await _scheduleService.rescheduleItem(
                    item.id,
                    dateTime,
                    startTime: '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}',
                  );
                  Navigator.pop(context);
                  _loadData();
                },
                child: const Text('Reschedule'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
