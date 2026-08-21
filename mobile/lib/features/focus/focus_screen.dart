import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../theme/app_theme.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  final _focusService = FocusService();
  bool _isRunning = false;
  int _remainingSeconds = 25 * 60;
  int _totalSeconds = 25 * 60;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _stopTimer();
          _completeSession();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  Future<void> _completeSession() async {
    final auth = ref.read(authProvider);
    if (auth.user == null) return;
    await _focusService.startPomodoro(
      userId: auth.user!.id,
      durationMins: _totalSeconds ~/ 60,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Focus session completed!')),
      );
    }
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_remainingSeconds / _totalSeconds);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Mode'),
        actions: [
          TextButton(
            onPressed: () => context.go('/focus/notes'),
            child: const Text('Notes'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularPercentIndicator(
                radius: 120,
                lineWidth: 12,
                percent: progress,
                backgroundColor: AppColors.border,
                progressColor: AppColors.primary,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _isRunning ? 'Focus Time' : 'Ready to Focus',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _stopTimer,
                    icon: const Icon(Icons.stop_circle_outlined),
                    iconSize: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 32),
                  IconButton(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    icon: Icon(
                      _isRunning
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                    ),
                    iconSize: 64,
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 48),
              _buildDurationSelector(),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickAction('Notes', Icons.note_add_outlined, () => context.go('/focus/notes')),
                  _buildQuickAction('Badges', Icons.emoji_events_outlined, () => context.go('/gamification')),
                  _buildQuickAction('Habits', Icons.checklist_outlined, () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    final durations = [15, 25, 45, 60];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: durations.map((mins) {
        final isSelected = _totalSeconds == mins * 60;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: ChoiceChip(
            label: Text('${mins}m'),
            selected: isSelected,
            onSelected: _isRunning
                ? null
                : (_) {
                    setState(() {
                      _totalSeconds = mins * 60;
                      _remainingSeconds = mins * 60;
                    });
                  },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
