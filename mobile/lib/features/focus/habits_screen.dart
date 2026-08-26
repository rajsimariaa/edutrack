import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});
  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  final _focusService = FocusService();
  List<Habit> _habits = [];
  Map<String, List<HabitEntry>> _entries = {};
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
      _habits = await _focusService.getHabits(auth.user!.id);
      _entries = {};
      for (final habit in _habits) {
        _entries[habit.id] = await _focusService.getHabitEntries(
          habit.id,
          startDate: DateTime.now().subtract(const Duration(days: 7)),
        );
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/focus');
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _habits.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _habits.length,
                    itemBuilder: (context, index) => _buildHabitCard(_habits[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateHabitDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist_outlined, size: 64, color: AppColors.textHintOf(context)),
          const SizedBox(height: 16),
          Text('No habits yet', style: TextStyle(fontSize: 18, color: AppColors.textSecondaryOf(context))),
          const SizedBox(height: 8),
          Text('Create your first habit to start tracking', style: TextStyle(color: AppColors.textHintOf(context))),
        ],
      ),
    );
  }

  Widget _buildHabitCard(Habit habit) {
    final entries = _entries[habit.id] ?? [];
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final checkedToday = entries.any((e) => e.checkinDate.toIso8601String().split('T')[0] == todayStr);

    final last7 = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final dateStr = date.toIso8601String().split('T')[0];
      return entries.any((e) => e.checkinDate.toIso8601String().split('T')[0] == dateStr);
    });

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (checkedToday ? AppColors.success : AppColors.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    checkedToday ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: checkedToday ? AppColors.success : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      Text(habit.frequency, style: TextStyle(fontSize: 12, color: AppColors.textSecondaryOf(context))),
                    ],
                  ),
                ),
                if (!checkedToday)
                  TextButton(
                    onPressed: () => _checkIn(habit),
                    child: const Text('Check In'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final date = DateTime.now().subtract(Duration(days: 6 - i));
                final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return Column(
                  children: [
                    Text(dayLabels[date.weekday - 1], style: TextStyle(fontSize: 10, color: AppColors.textHintOf(context))),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: last7[i] ? AppColors.success : AppColors.borderOf(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: last7[i] ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkIn(Habit habit) async {
    try {
      await _focusService.checkInHabit(habitId: habit.id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${habit.name} checked in!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check-in failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showCreateHabitDialog() {
    final nameController = TextEditingController();
    String frequency = 'daily';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16, right: 16, top: 16,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Habit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Habit name (e.g. Read 30 mins)'),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'daily', label: Text('Daily')),
                  ButtonSegment(value: 'weekly', label: Text('Weekly')),
                ],
                selected: {frequency},
                onSelectionChanged: (s) => setModalState(() => frequency = s.first),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final auth = ref.read(authProvider);
                  if (auth.user == null || nameController.text.isEmpty) return;
                  try {
                    await _focusService.createHabit(
                      userId: auth.user!.id,
                      name: nameController.text,
                      frequency: frequency,
                    );
                    Navigator.pop(context);
                    _loadData();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create habit: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                child: const Text('Create Habit'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
