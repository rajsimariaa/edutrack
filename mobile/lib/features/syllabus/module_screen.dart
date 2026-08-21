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
  List<Module> _modules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    try {
      final modules = await _syllabusService.getModules(widget.subjectId);
      setState(() {
        _modules = modules;
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
        title: Text(widget.subjectName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _modules.isEmpty
              ? const Center(child: Text('No modules available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _modules.length,
                  itemBuilder: (context, index) {
                    final module = _modules[index];
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
                            Icons.folder,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          module.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: module.description != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  module.description!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : null,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go(
                            '/syllabus/chapter/${module.id}/${Uri.encodeComponent(module.name)}'),
                      ),
                    );
                  },
                ),
    );
  }
}
