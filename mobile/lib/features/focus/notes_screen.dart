import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _focusService = FocusService();
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final auth = ref.read(authProvider);
    if (auth.user == null) return;

    try {
      _notes = await _focusService.getNotes(auth.user!.id);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
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
          : _notes.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return _buildNoteCard(note);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add_outlined, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first note to get started',
            style: TextStyle(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            note.isPinned ? Icons.push_pin : Icons.note,
            color: AppColors.accent,
            size: 20,
          ),
        ),
        title: Text(
          note.title ?? 'Untitled',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          note.contentMd.length > 80
              ? '${note.contentMd.substring(0, 80)}...'
              : note.contentMd,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => _showEditNoteDialog(note),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditNoteDialog(note);
            } else if (value == 'delete') {
              _focusService.deleteNote(note.id);
              _loadNotes();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  void _showCreateNoteDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Note',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: const InputDecoration(hintText: 'Write your note...'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final auth = ref.read(authProvider);
                if (auth.user == null) return;
                await _focusService.createNote(
                  userId: auth.user!.id,
                  chapterId: null,
                  title: titleController.text,
                  contentMd: contentController.text,
                );
                Navigator.pop(context);
                _loadNotes();
              },
              child: const Text('Save Note'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditNoteDialog(Note note) {
    final titleController = TextEditingController(text: note.title ?? '');
    final contentController = TextEditingController(text: note.contentMd);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Note',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: const InputDecoration(hintText: 'Write your note...'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _focusService.updateNote(
                  noteId: note.id,
                  title: titleController.text,
                  contentMd: contentController.text,
                );
                Navigator.pop(context);
                _loadNotes();
              },
              child: const Text('Update Note'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
