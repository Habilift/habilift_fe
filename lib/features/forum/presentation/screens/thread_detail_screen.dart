import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('Content Review'),
            ],
          ),
          content: Text(
            result.reason ?? 'Your content has been flagged for review.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Edit Post'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // In a real app, this would submit for manual review
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comment submitted for review')),
                );
                _commentController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.medicalBlue,
              ),
              child: const Text(
                'Submit Anyway',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      setState(() => _isSubmitting = true);

      // Mock submission delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comment posted successfully!'),
              backgroundColor: AppColors.medicalGreen,
            ),
          );
          _commentController.clear();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final thread = ref.watch(selectedThreadProvider);
    final comments = ref.watch(threadCommentsProvider(widget.threadId));

    if (thread == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Thread not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textBlack),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Discussion',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.bookmark, color: AppColors.textBlack),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thread bookmarked!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textBlack),
            onPressed: () {
              // TODO: Show options menu
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
                  // Thread Content
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
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
                              radius: 20,
                              backgroundColor: AppColors.medicalBlue
                                  .withOpacity(0.1),
                              child: Text(
                                thread.authorName[0].toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.medicalBlue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    thread.authorName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                  Text(
                                    timeago.format(thread.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          thread.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Content
                        Text(
                          thread.content,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textGray,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Actions
                        Row(
                          children: [
                            _ActionButton(
                              icon: IconlyLight.heart,
                              label: '${thread.likeCount}',
                              onTap: () {},
                            ),
                            const SizedBox(width: 16),
                            _ActionButton(
                              icon: IconlyLight.chat,
                              label: '${thread.commentCount}',
                              onTap: () {},
                            ),
                            const SizedBox(width: 16),
                            _ActionButton(
                              icon: IconlyLight.send,
                              label: 'Share',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Comments Section
                  Text(
                    'Comments (${comments.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Comments List
                  ...comments.map((comment) => _CommentTile(comment: comment)),
                ],
              ),
            ),
          ),

          // Comment Input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: TextStyle(color: AppColors.textGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceGray,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: AppColors.medicalGreen,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: _isSubmitting ? null : _submitComment,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              IconlyBold.send,
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textGray),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: AppColors.textGray),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final ForumComment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceGray,
                child: Text(
                  comment.authorName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                comment.authorName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• ${timeago.format(comment.createdAt)}',
                style: TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment.content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(IconlyLight.heart, size: 16, color: AppColors.textGray),
              const SizedBox(width: 4),
              Text(
                '${comment.likeCount}',
                style: TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
              const SizedBox(width: 16),
              Text(
                'Reply',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.medicalBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
