import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../models/flashcard_model.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen>
    with SingleTickerProviderStateMixin {
  final _syllabusService = SyllabusService();
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  List<Subject> _subjects = [];
  Subject? _selectedSubject;
  List<Flashcard> _flashcards = [];
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isLoading = false;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _loadSubjects();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    final auth = ref.read(authProvider);
    if (auth.user == null || auth.profile == null) return;

    try {
      final exam = await _syllabusService.getExamForCategory(
        auth.profile!.examCategory,
      );
      if (exam == null) return;
      final subjects = await _syllabusService.getSubjects(exam.id);
      setState(() => _subjects = subjects);
    } catch (_) {}
  }

  Future<void> _loadFlashcards(Subject subject) async {
    setState(() {
      _isLoading = true;
      _selectedSubject = subject;
      _isFlipped = false;
    });

    try {
      final modules = await _syllabusService.getModules(subject.id);
      final List<Flashcard> cards = [];

      for (final mod in modules) {
        final chapters = await _syllabusService.getChapters(mod.id);
        for (final chapter in chapters) {
          final topics = await _syllabusService.getTopics(chapter.id);
          for (final topic in topics) {
            final desc = topic.description ?? '';
            final hasGoodDescription = desc.length > 10;

            final front = 'What is ${topic.name}?';
            final back = hasGoodDescription
                ? desc
                : _generateAnswer(topic.name, chapter.name, mod.name, subject.name);

            cards.add(Flashcard(
              id: topic.id,
              front: front,
              back: back,
              subjectName: subject.name,
              chapterName: chapter.name,
            ));
          }
        }
      }

      cards.shuffle(Random());

      setState(() {
        _flashcards = cards;
        _currentIndex = 0;
        _hasLoaded = true;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String _generateAnswer(String topicName, String chapterName, String moduleName, String subjectName) {
    return '$topicName is a key concept in $chapterName '
        'under the module $moduleName in $subjectName. '
        'Review your textbook notes and class materials for the complete definition, '
        'formulas, and examples related to this topic.';
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    _isFlipped = !_isFlipped;
  }

  void _nextCard() {
    if (_currentIndex < _flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }

  void _markAsKnown() {
    _flashcards[_currentIndex].isKnown = true;
    if (_currentIndex < _flashcards.length - 1) {
      _nextCard();
    } else {
      setState(() {});
    }
  }

  void _markForReview() {
    _flashcards[_currentIndex].isKnown = false;
    if (_currentIndex < _flashcards.length - 1) {
      _nextCard();
    } else {
      setState(() {});
    }
  }

  void _shuffleCards() {
    setState(() {
      _flashcards.shuffle(Random());
      _currentIndex = 0;
      _isFlipped = false;
    });
  }

  int get _reviewedCount => _flashcards.where((c) => c.isKnown).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedSubject?.name ?? 'Flashcards'),
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
        actions: [
          if (_flashcards.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.shuffle),
              onPressed: _shuffleCards,
              tooltip: 'Shuffle',
            ),
        ],
      ),
      body: _selectedSubject == null
          ? _buildSubjectPicker()
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _flashcards.isEmpty && _hasLoaded
                  ? _buildEmptyState()
                  : _buildCardView(),
    );
  }

  Widget _buildSubjectPicker() {
    if (_subjects.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'Select a subject',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            'Choose a subject to start reviewing flashcards',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _subjects.length,
            itemBuilder: (context, index) {
              final subject = _subjects[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.style,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    subject.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Tap to study',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                  onTap: () => _loadFlashcards(subject),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.style_outlined,
            size: 80,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'No flashcards available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This subject has no topics yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _selectedSubject = null;
                _hasLoaded = false;
                _flashcards = [];
              });
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Choose another subject'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardView() {
    final card = _flashcards[_currentIndex];
    final progress = _flashcards.isEmpty
        ? 0.0
        : (_currentIndex + 1) / _flashcards.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Text(
                '${_currentIndex + 1} of ${_flashcards.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${_reviewedCount} known)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mastered.withOpacity(0.8),
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress < 0.33
                    ? AppColors.notStarted
                    : progress < 0.66
                        ? AppColors.inProgress
                        : AppColors.mastered,
              ),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle = _flipAnimation.value * pi;
                  final isFront = _flipAnimation.value <= 0.5;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: isFront
                        ? _buildFront(card)
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: _buildBack(card),
                          ),
                  );
                },
              ),
            ),
          ),
        ),
        if (card.chapterName != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                card.chapterName!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                icon: Icons.close,
                label: 'Review Again',
                color: AppColors.notStarted,
                onTap: _currentIndex > 0 ? _markForReview : null,
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isFlipped ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.primary,
                  ),
                  onPressed: _flipCard,
                  tooltip: _isFlipped ? 'Hide answer' : 'Reveal answer',
                ),
              ),
              _buildActionButton(
                icon: Icons.check,
                label: 'Known',
                color: AppColors.mastered,
                onTap: _markAsKnown,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _currentIndex > 0 ? _prevCard : null,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _currentIndex < _flashcards.length - 1 ? _nextCard : null,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFront(Flashcard card) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.help_outline,
                color: Colors.white70,
                size: 28,
              ),
              const SizedBox(height: 16),
              Text(
                card.front,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Tap to reveal answer',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBack(Flashcard card) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.mastered.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.mastered,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                card.back,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDisabled
                  ? AppColors.border.withOpacity(0.5)
                  : color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDisabled ? AppColors.textHint : color,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDisabled ? AppColors.textHint : color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
