import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class ChapterScreen extends ConsumerStatefulWidget {
  final String chapterId;
  final String chapterName;
  const ChapterScreen({super.key, required this.chapterId, this.chapterName = 'Chapter'});

  @override
  ConsumerState<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends ConsumerState<ChapterScreen> {
  final _syllabusService = SyllabusService();
  List<Topic> _topics = [];
  Map<String, UserTopicProgress> _progress = {};
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
      final topics = await _syllabusService.getTopics(widget.chapterId);
      final userProgress = await _syllabusService.getUserProgress(auth.user!.id);
      final progressMap = <String, UserTopicProgress>{};
      for (final p in userProgress) {
        progressMap[p.topicId] = p;
      }

      setState(() {
        _topics = topics;
        _progress = progressMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(Topic topic, TopicStatus status) async {
    final auth = ref.read(authProvider);
    if (auth.user == null) return;

    await _syllabusService.updateTopicProgress(
      userId: auth.user!.id,
      topicId: topic.id,
      status: status,
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _topics.isEmpty
              ? const Center(child: Text('No topics available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _topics.length,
                  itemBuilder: (context, index) {
                    final topic = _topics[index];
                    final progress = _progress[topic.id];
                    final status = progress?.status ?? TopicStatus.notStarted;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _statusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _statusIcon(status),
                            color: _statusColor(status),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          topic.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          _statusLabel(status),
                          style: TextStyle(
                            fontSize: 12,
                            color: _statusColor(status),
                          ),
                        ),
                        trailing: PopupMenuButton<TopicStatus>(
                          onSelected: (s) => _updateStatus(topic, s),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: TopicStatus.notStarted,
                              child: Text('Not Started'),
                            ),
                            const PopupMenuItem(
                              value: TopicStatus.inProgress,
                              child: Text('In Progress'),
                            ),
                            const PopupMenuItem(
                              value: TopicStatus.mastered,
                              child: Text('Mastered'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Color _statusColor(TopicStatus status) {
    switch (status) {
      case TopicStatus.notStarted:
        return AppColors.notStarted;
      case TopicStatus.inProgress:
        return AppColors.inProgress;
      case TopicStatus.mastered:
        return AppColors.mastered;
    }
  }

  IconData _statusIcon(TopicStatus status) {
    switch (status) {
      case TopicStatus.notStarted:
        return Icons.radio_button_unchecked;
      case TopicStatus.inProgress:
        return Icons.access_time;
      case TopicStatus.mastered:
        return Icons.check_circle;
    }
  }

  String _statusLabel(TopicStatus status) {
    switch (status) {
      case TopicStatus.notStarted:
        return 'Not Started';
      case TopicStatus.inProgress:
        return 'In Progress';
      case TopicStatus.mastered:
        return 'Mastered';
    }
  }
}
