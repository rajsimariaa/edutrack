import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class ModuleScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final String subjectName;

  const ModuleScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  ConsumerState<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends ConsumerState<ModuleScreen> {
  final _syllabusService = SyllabusService();
  List<_ModuleWithChapters> _modulesWithChapters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final modules = await _syllabusService.getModules(widget.subjectId);
      final List<_ModuleWithChapters> result = [];
      for (final module in modules) {
        final chapters = await _syllabusService.getChapters(module.id);
        result.add(_ModuleWithChapters(module: module, chapters: chapters));
      }
      if (!mounted) return;
      setState(() {
        _modulesWithChapters = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/syllabus');
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _modulesWithChapters.isEmpty
              ? const Center(child: Text('No content available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _modulesWithChapters.length,
                  itemBuilder: (context, index) {
                    final mc = _modulesWithChapters[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_modulesWithChapters.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, top: 8),
                            child: Text(
                              mc.module.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ...mc.chapters.map(
                          (chapter) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
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
                                  Icons.menu_book,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: Text(
                                chapter.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push(
                                  '/syllabus/chapter/${chapter.id}/${Uri.encodeComponent(chapter.name)}'),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}

class _ModuleWithChapters {
  final Module module;
  final List<Chapter> chapters;
  _ModuleWithChapters({required this.module, required this.chapters});
}
