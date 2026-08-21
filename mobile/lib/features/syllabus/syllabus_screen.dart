import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class SyllabusScreen extends ConsumerStatefulWidget {
  const SyllabusScreen({super.key});

  @override
  ConsumerState<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends ConsumerState<SyllabusScreen> {
  final _syllabusService = SyllabusService();
  List<Subject> _subjects = [];
  Map<String, Map<String, double>> _progress = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = ref.read(authProvider);
    if (auth.user == null || auth.profile == null) return;

    try {
      final exam = await _syllabusService.getExamForCategory(auth.profile!.examCategory);
      if (exam == null) {
        setState(() => _isLoading = false);
        return;
      }

      final subjects = await _syllabusService.getSubjects(exam.id);
      final progress = <String, Map<String, double>>{};

      for (final subject in subjects) {
        progress[subject.id] = await _syllabusService.getSubjectProgress(
          auth.user?.id ?? '',
          subject.id,
        );
      }

      setState(() {
        _subjects = subjects;
        _progress = progress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syllabus'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _subjects.isEmpty
                  ? const Center(
                      child: Text('No syllabus available yet'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _subjects.length,
                      itemBuilder: (context, index) {
                        final subject = _subjects[index];
                        final progress = _progress[subject.id];
                        final total = progress?['total'] ?? 0;
                        final mastered = progress?['mastered'] ?? 0;
                        final pct = total > 0 ? mastered / total : 0.0;

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
                                Icons.book,
                                color: AppColors.primary,
                              ),
                            ),
                            title: Text(
                              subject.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      backgroundColor: AppColors.border,
                                      valueColor: AlwaysStoppedAnimation(
                                        pct >= 1.0
                                            ? AppColors.mastered
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(pct * 100).toInt()}% mastered',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.go('/syllabus/modules/${subject.id}/${Uri.encodeComponent(subject.name)}'),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
