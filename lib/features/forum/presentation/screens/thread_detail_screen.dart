import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/models/forum_models.dart';
import '../providers/forum_provider.dart';

class ThreadDetailScreen extends ConsumerStatefulWidget {
  final String threadId;

  const ThreadDetailScreen({super.key, required this.threadId});

  @override
  ConsumerState<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends ConsumerState<ThreadDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  String _filter = 'all'; // all, specialist, regular

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    final moderationCheck = ref.read(aiModerationProvider);
    final result = moderationCheck(_commentController.text);

    if (result.isFlagged) {
      _showFlaggedDialog(result.reason);
    } else {
      _actuallySubmitComment();
    }
  }

  void _showFlaggedDialog(String? reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Content Review'),
        content: Text(reason ?? 'Your content has been flagged.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _actuallySubmitComment(); // Allow override for demo
            },
            child: const Text(
              'Submit Anyway',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _actuallySubmitComment() {
    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        final newComment = ForumComment(
          id: const Uuid().v4(),
          threadId: widget.threadId,
          content: _commentController.text.trim(),
          authorName: 'You',
          createdAt: DateTime.now(),
          likeCount: 0,
          isSpecialist: false, // Regular user by default
        );

        // Update Comment List
        ref
            .read(threadCommentsProvider(widget.threadId).notifier)
            .update((state) => [...state, newComment]);

        // Update Thread Comment Count (Both selected and global list)
        ref
            .read(selectedThreadProvider.notifier)
            .update((t) => t?.copyWith(commentCount: (t.commentCount) + 1));

        ref.read(forumThreadsProvider.notifier).update((threads) {
          return threads.map((t) {
            if (t.id == widget.threadId) {
              return t.copyWith(commentCount: t.commentCount + 1);
            }
            return t;
          }).toList();
        });

        _commentController.clear();
        setState(() => _isSubmitting = false);
      }
    });
  }

  void _toggleLike(ForumThread? thread) {
    if (thread == null) return;

    // Optimistic update
    final newLikeCount =
        thread.likeCount + 1; // Simplify: just increment for demo

    ref
        .read(selectedThreadProvider.notifier)
        .update((t) => t?.copyWith(likeCount: newLikeCount));

    ref.read(forumThreadsProvider.notifier).update((threads) {
      return threads.map((t) {
        if (t.id == widget.threadId) {
          return t.copyWith(likeCount: newLikeCount);
        }
        return t;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final thread = ref.watch(selectedThreadProvider);
    final allComments = ref.watch(threadCommentsProvider(widget.threadId));

    // Filter & Sort Logic
    List<ForumComment> comments = List.from(allComments);

    if (_filter == 'specialist') {
      comments = comments.where((c) => c.isSpecialist).toList();
    } else if (_filter == 'regular') {
      comments = comments.where((c) => !c.isSpecialist).toList();
    }

    // Sort: Specialist first, then by date (newest first)
    comments.sort((a, b) {
      if (_filter == 'all') {
        if (a.isSpecialist && !b.isSpecialist) return -1;
        if (!a.isSpecialist && b.isSpecialist) return 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    if (thread == null) {
      return const Scaffold(body: Center(child: Text('Thread not found')));
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      appBar: AppBar(
        title: const Text(
          'Discussion',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textBlack),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.upload, color: AppColors.textBlack),
            onPressed: () {
              Share.share(
                'Check out this discussion: "${thread.title}" on HabiLift Forum!',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thread Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.medicalBlue.withValues(
                                alpha: 0.1,
                              ),
                              child: Text(
                                thread.authorName[0],
                                style: const TextStyle(
                                  color: AppColors.medicalBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  thread.authorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  timeago.format(thread.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textGray,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Content
                        Text(
                          thread.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          thread.content,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: AppColors.textGray,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Images
                        if (thread.images.isNotEmpty) ...[
                          SizedBox(
                            height: 200,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: thread.images.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final path = thread.images[index];
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: path.startsWith('http')
                                        ? Image.network(path, fit: BoxFit.cover)
                                        : Image.file(
                                            File(path),
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Actions
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton.icon(
                              onPressed: () => _toggleLike(thread),
                              icon: const Icon(IconlyLight.heart),
                              label: Text('${thread.likeCount} Likes'),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(IconlyLight.chat),
                              label: Text('${thread.commentCount} Comments'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Filter Toggles
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildFilterOption('All', 'all'),
                            _buildFilterOption('Special', 'specialist'),
                            _buildFilterOption('Regular', 'regular'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Comments List
                  if (comments.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'No comments yet. Be the first!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...comments.map(
                      (c) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (c.isSpecialist)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.medicalBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Specialist',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.medicalBlue,
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  c.authorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  timeago.format(c.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(c.content),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Comment Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      filled: true,
                      fillColor: AppColors.surfaceGray,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isSubmitting ? null : _submitComment,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          IconlyBold.send,
                          color: AppColors.medicalBlue,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.textBlack : AppColors.textGray,
          ),
        ),
      ),
    );
  }
}
