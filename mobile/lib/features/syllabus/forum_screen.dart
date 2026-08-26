import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../theme/app_theme.dart';

const _uuid = Uuid();

class ForumPost {
  final String id;
  final String authorName;
  final String content;
  final DateTime timestamp;
  int likes;
  bool isLiked;

  ForumPost({
    String? id,
    required this.authorName,
    required this.content,
    DateTime? timestamp,
    this.likes = 0,
    this.isLiked = false,
  })  : id = id ?? _uuid.v4(),
        timestamp = timestamp ?? DateTime.now();
}

class ForumScreen extends StatefulWidget {
  final String chapterId;
  final String? chapterName;
  const ForumScreen({super.key, required this.chapterId, this.chapterName});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final _controller = TextEditingController();
  final _nameController = TextEditingController();
  List<ForumPost> _posts = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadSamplePosts();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _loadSamplePosts() {
    if (_initialized) return;
    _initialized = true;
    _posts = [
      ForumPost(
        authorName: 'Priya Sharma',
        content: 'Can someone explain the difference between section 44AD and 44ADA for presumptive taxation?',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 12,
      ),
      ForumPost(
        authorName: 'Rahul Kumar',
        content: 'For the new syllabus, Focus on Amendments from Finance Act 2024. Most questions come from there.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        likes: 24,
        isLiked: true,
      ),
      ForumPost(
        authorName: 'Ananya Patel',
        content: 'I made a mind map for Partnership Accounts. Anyone wants me to share it?',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        likes: 8,
      ),
    ];
  }

  void _createPost() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final authorName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Anonymous Student';

    setState(() {
      _posts.insert(
        0,
        ForumPost(authorName: authorName, content: content),
      );
    });
    _controller.clear();
  }

  void _toggleLike(ForumPost post) {
    setState(() {
      post.isLiked = !post.isLiked;
      post.likes += post.isLiked ? 1 : -1;
    });
  }

  String _timeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterName ?? 'Discussion Forum'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forum_outlined, size: 64, color: AppColors.textHintOf(context)),
                        const SizedBox(height: 16),
                        Text(
                          'No discussions yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryOf(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a conversation about this topic',
                          style: TextStyle(color: AppColors.textHintOf(context)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return _buildPostCard(post);
                    },
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildPostCard(ForumPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    post.authorName[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _timeAgo(post.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textHintOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleLike(post),
                  child: Row(
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: post.isLiked ? AppColors.secondary : AppColors.textHintOf(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likes}',
                        style: TextStyle(
                          fontSize: 13,
                          color: post.isLiked ? AppColors.secondary : AppColors.textHintOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        border: Border(top: BorderSide(color: AppColors.borderOf(context))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Your name',
                  hintStyle: TextStyle(color: AppColors.textHintOf(context), fontSize: 12),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.borderOf(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.borderOf(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Write a post...',
                  hintStyle: TextStyle(color: AppColors.textHintOf(context)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.borderOf(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.borderOf(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _createPost(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _createPost,
              icon: const Icon(Icons.send),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
