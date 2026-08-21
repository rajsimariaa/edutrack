import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  final _resourceService = ResourceService();
  List<Map<String, dynamic>> _pastPapers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = ref.read(authProvider);
    if (auth.profile == null) return;

    try {
      final exams = await SyllabusService().getExams();
      if (exams.isNotEmpty) {
        _pastPapers = await _resourceService.getPastPapers(exams.first.id);
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
        title: const Text('Resources'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Past Papers'),
                      Tab(text: 'YouTube'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildPastPapers(),
                        _buildYouTubeLinks(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPastPapers() {
    if (_pastPapers.isEmpty) {
      return const Center(child: Text('No past papers available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pastPapers.length,
      itemBuilder: (context, index) {
        final paper = _pastPapers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.picture_as_pdf, color: AppColors.error),
            ),
            title: Text(
              paper['title'] ?? 'Untitled',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${paper['year'] ?? ""} ${paper['term'] ?? ""}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                final url = paper['file_url'];
                if (url != null) {
                  await launchUrl(Uri.parse(url));
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildYouTubeLinks() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              'YouTube Resources',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse your syllabus chapters to find curated video resources linked to each topic.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
