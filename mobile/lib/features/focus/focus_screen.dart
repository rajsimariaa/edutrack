import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../theme/app_theme.dart';

const _motivationalQuotes = [
  "The secret of getting ahead is getting started. — Mark Twain",
  "It always seems impossible until it's done. — Nelson Mandela",
  "Don't watch the clock; do what it does. Keep going. — Sam Levenson",
  "Focus on being productive instead of busy. — Tim Ferriss",
  "The way to get started is to quit talking and begin doing. — Walt Disney",
  "You don't have to be great to start, but you have to start to be great. — Zig Ziglar",
  "Concentrate all your thoughts upon the work at hand. — Alexander Graham Bell",
  "Action is the foundational key to all success. — Pablo Picasso",
  "It is not enough to be busy. The question is: what are we busy about? — Henry David Thoreau",
  "Your focus determines your reality. — George Lucas",
  "Do the hard jobs first. The easy jobs will take care of themselves. — Dale Carnegie",
  "Motivation is what gets you started. Habit is what keeps you going. — Jim Ryun",
  "The successful warrior is the average person, with laser-like focus. — Bruce Lee",
  "Start where you are. Use what you have. Do what you can. — Arthur Ashe",
  "Discipline is choosing between what you want now and what you want most. — Abraham Lincoln",
];

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
  String? _currentSessionId;

  int _sessionCount = 4;
  int _currentSession = 0;
  bool _isBreak = false;
  bool _focusModeActive = false;
  String _currentQuote = '';
  int _longBreakMinutes = 15;
  int _shortBreakMinutes = 5;
  int _defaultSessionMinutes = 25;
  bool _isFocusModeFullscreen = false;

  @override
  void initState() {
    super.initState();
    _currentQuote = _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];
    _loadPreferences();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_isFocusModeFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _defaultSessionMinutes = prefs.getInt('pomodoro_duration') ?? 25;
        _shortBreakMinutes = prefs.getInt('short_break') ?? 5;
        _longBreakMinutes = prefs.getInt('long_break') ?? 15;
        _sessionCount = prefs.getInt('session_count') ?? 4;
        _totalSeconds = _defaultSessionMinutes * 60;
        _remainingSeconds = _totalSeconds;
      });
    } catch (_) {}
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('pomodoro_duration', _defaultSessionMinutes);
      await prefs.setInt('short_break', _shortBreakMinutes);
      await prefs.setInt('long_break', _longBreakMinutes);
      await prefs.setInt('session_count', _sessionCount);
    } catch (_) {}
  }

  void _startLocalTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        if (_isBreak) {
          _completeBreak();
        } else {
          _completeSession();
        }
      }
    });
  }

  Future<void> _startTimer() async {
    if (_isRunning) return;

    final auth = ref.read(authProvider);
    if (auth.user == null) {
      _startLocalTimer();
      if (mounted) setState(() => _isRunning = true);
      return;
    }

    if (!_isBreak) {
      try {
        final session = await _focusService.startPomodoro(
          userId: auth.user!.id,
          durationMins: _totalSeconds ~/ 60,
        );
        _currentSessionId = session.id;
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _isRunning = true);
    _startLocalTimer();
  }

  Future<void> _pauseTimer() async {
    _timer?.cancel();
    final auth = ref.read(authProvider);
    if (_currentSessionId != null && auth.user != null && !_isBreak) {
      final elapsedMins = (_totalSeconds - _remainingSeconds) ~/ 60;
      if (elapsedMins > 0) {
        try {
          await GamificationService().updateHeatmapEntry(
            userId: auth.user!.id,
            date: DateTime.now(),
            focusMins: elapsedMins,
          );
        } catch (_) {}
      }
    }
    _currentSessionId = null;
    if (mounted) setState(() => _isRunning = false);
  }

  Future<void> _stopTimer() async {
    _timer?.cancel();
    final auth = ref.read(authProvider);
    if (_currentSessionId != null) {
      try {
        await _focusService.completePomodoro(_currentSessionId!);
        if (auth.user != null) {
          final elapsedMins = (_totalSeconds - _remainingSeconds) ~/ 60;
          if (elapsedMins > 0) {
            await GamificationService().updateHeatmapEntry(
              userId: auth.user!.id,
              date: DateTime.now(),
              focusMins: elapsedMins,
            );
          }
        }
      } catch (_) {}
      _currentSessionId = null;
    }
    if (!mounted) return;
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _currentSession = 0;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _completeSession() {
    final auth = ref.read(authProvider);
    final userId = auth.user?.id;

    if (_currentSessionId != null) {
      try {
        _focusService.completePomodoro(_currentSessionId!);
        if (userId != null) {
          GamificationService().updateHeatmapEntry(
            userId: userId,
            date: DateTime.now(),
            focusMins: _totalSeconds ~/ 60,
          );
          BadgeService().evaluateAndAwardBadges(userId);
        }
      } catch (_) {}
      _currentSessionId = null;
    }

    if (!mounted) return;
    setState(() {
      _isRunning = false;
      _currentSession++;
    });

    if (_currentSession >= _sessionCount) {
      _showBreakDialog(isLong: true);
    } else {
      _showBreakDialog(isLong: false);
    }
  }

  void _completeBreak() {
    if (!mounted) return;
    setState(() {
      _isRunning = false;
      _isBreak = false;
      if (_currentSession >= _sessionCount) {
        _currentSession = 0;
      }
      _remainingSeconds = _totalSeconds;
      _currentQuote = _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Break is over! Ready for next session?')),
      );
    }
  }

  void _showBreakDialog({required bool isLong}) {
    final breakMins = isLong ? _longBreakMinutes : _shortBreakMinutes;
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(isLong ? 'Long Break Time!' : 'Short Break Time!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLong ? Icons.coffee : Icons.free_breakfast,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Take a $breakMins minute break.\nSession $_currentSession of $_sessionCount completed.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startBreak(breakMins);
            },
            child: const Text('Take Break'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isBreak = false;
                _currentSession = 0;
                _remainingSeconds = _totalSeconds;
              });
            },
            child: const Text('Skip Break'),
          ),
        ],
      ),
    );
  }

  void _startBreak(int minutes) {
    setState(() {
      _isBreak = true;
      _totalSeconds = minutes * 60;
      _remainingSeconds = _totalSeconds;
    });
    _startTimer();
  }

  void _toggleFocusMode() {
    setState(() {
      _focusModeActive = !_focusModeActive;
    });
    if (_focusModeActive) {
      _enterFullscreenFocusMode();
    } else {
      _exitFullscreenFocusMode();
    }
  }

  void _enterFullscreenFocusMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    setState(() {
      _isFocusModeFullscreen = true;
      _currentQuote = _motivationalQuotes[Random().nextInt(_motivationalQuotes.length)];
    });
  }

  void _exitFullscreenFocusMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    setState(() {
      _isFocusModeFullscreen = false;
    });
  }

  void _handleBackPress() {
    if (_isFocusModeFullscreen && _isRunning) {
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Exit Focus Mode?'),
          content: const Text('Are you sure you want to exit focus mode? Your session will be paused.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Exit', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ).then((shouldExit) {
        if (shouldExit == true && mounted) {
          _pauseTimer();
          _exitFullscreenFocusMode();
          setState(() {
            _focusModeActive = false;
            _isFocusModeFullscreen = false;
          });
        }
      });
    } else {
      _pauseTimer();
      _exitFullscreenFocusMode();
      setState(() {
        _focusModeActive = false;
        _isFocusModeFullscreen = false;
      });
    }
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0 ? 1 - (_remainingSeconds / _totalSeconds) : 0.0;

    if (_isFocusModeFullscreen) {
      return _buildFocusModeUI(progress);
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (_isFocusModeFullscreen) {
          _handleBackPress();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Focus Mode'),
          actions: [
            if (_isBreak)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'BREAK',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
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
                _buildSessionCounter(),
                const SizedBox(height: 16),
                _buildFocusModeToggle(),
                const SizedBox(height: 24),
                CircularPercentIndicator(
                  radius: 120,
                  lineWidth: 12,
                  percent: progress.clamp(0.0, 1.0),
                  backgroundColor: AppColors.borderOf(context),
                  progressColor: _isBreak ? AppColors.warning : AppColors.primary,
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
                        _isBreak
                            ? 'Break Time'
                            : _isRunning
                                ? 'Focus Time'
                                : 'Ready to Focus',
                        style: TextStyle(
                          color: AppColors.textSecondaryOf(context),
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
                const SizedBox(height: 32),
                if (!_isBreak) _buildDurationSelector(),
                const SizedBox(height: 32),
                _buildBreakOptions(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction('Notes', Icons.note_add_outlined, () => context.push('/focus/notes')),
                    _buildQuickAction('Cards', Icons.style_outlined, () => context.push('/focus/flashcards')),
                    _buildQuickAction('Habits', Icons.checklist_outlined, () => context.go('/focus/habits')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFocusModeUI(double progress) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'FOCUS MODE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  CircularPercentIndicator(
                    radius: 120,
                    lineWidth: 12,
                    percent: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    progressColor: _isBreak ? AppColors.warning : AppColors.primaryLight,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _isBreak ? 'Break Time' : 'Focus',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    _currentQuote,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _stopTimer,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.stop_circle_outlined, color: AppColors.error, size: 32),
                        ),
                      ),
                      const SizedBox(width: 32),
                      GestureDetector(
                        onTap: _isRunning ? _pauseTimer : _startTimer,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isRunning ? Icons.pause_circle_filled : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onDoubleTap: () {
                      _pauseTimer();
                      _exitFullscreenFocusMode();
                      setState(() {
                        _focusModeActive = false;
                        _isFocusModeFullscreen = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Double tap to exit focus mode',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                      ),
                    ),
                  ),
                  if (_isRunning) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Session $_currentSession of $_sessionCount',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_sessionCount, (index) {
        final isCompleted = index < _currentSession;
        final isCurrent = index == _currentSession && !_isBreak;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.success
                : isCurrent
                    ? AppColors.primary
                    : AppColors.borderOf(context),
          ),
        );
      }),
    );
  }

  Widget _buildFocusModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _focusModeActive ? Icons.fullscreen : Icons.fullscreen_exit,
          size: 16,
          color: _focusModeActive ? AppColors.primary : AppColors.textHintOf(context),
        ),
        const SizedBox(width: 8),
        Text(
          _focusModeActive ? 'Focus Mode On' : 'Focus Mode Off',
          style: TextStyle(
            fontSize: 12,
            color: _focusModeActive ? AppColors.primary : AppColors.textSecondaryOf(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: _focusModeActive,
          onChanged: (_) => _toggleFocusMode(),
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    final durations = [15, 25, 45, 60, 90];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: durations.map((mins) {
            final isSelected = _totalSeconds == mins * 60;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text('${mins}m'),
                selected: isSelected,
                onSelected: _isRunning
                    ? null
                    : (_) {
                        setState(() {
                          _defaultSessionMinutes = mins;
                          _totalSeconds = mins * 60;
                          _remainingSeconds = mins * 60;
                        });
                        _savePreferences();
                      },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBreakOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBreakChip('Short Break (${_shortBreakMinutes}m)', () {
          if (!_isRunning) _startBreak(_shortBreakMinutes);
        }),
        const SizedBox(width: 12),
        _buildBreakChip('Long Break (${_longBreakMinutes}m)', () {
          if (!_isRunning) _startBreak(_longBreakMinutes);
        }),
      ],
    );
  }

  Widget _buildBreakChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.warning,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}
