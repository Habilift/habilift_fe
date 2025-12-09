import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../app/theme/app_theme.dart';
import '../../data/models/forum_models.dart';
import '../providers/forum_provider.dart';

class CategoryThreadsScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryThreadsScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(selectedCategoryProvider);
    final allThreads = ref.watch(forumThreadsProvider);
    final threads = allThreads
        .where((t) => t.categoryId == categoryId)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textBlack),
          onPressed: () => context.pop(),
        ),
        title: Text(
          category?.name ?? 'Threads',
          style: const TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.filter, color: AppColors.textBlack),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],
      ),
      body: threads.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    IconlyLight.paper,
                    size: 64,
                    color: AppColors.textGray.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No threads yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Be the first to start a discussion!',
                    style: TextStyle(fontSize: 14, color: AppColors.textGray),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: threads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final thread = threads[index];
                return _ThreadCard(thread: thread);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/forum/create?categoryId=$categoryId');
        },
        backgroundColor: AppColors.medicalGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ThreadCard extends ConsumerWidget {
  final ForumThread thread;

  const _ThreadCard({required this.thread});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.read(selectedThreadProvider.notifier).state = thread;
        context.push('/forum/thread/${thread.id}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Pinned Badge
            if (thread.isPinned)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.medicalBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.push_pin,
                      size: 12,
                      color: AppColors.medicalBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pinned',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.medicalBlue,
                      ),
                    ),
                  ],
                ),
              ),

            // Title
            Text(
              thread.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Preview
            Text(
              thread.content,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Author and Stats
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.surfaceGray,
                  child: Text(
                    thread.authorName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  thread.authorName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '• ${timeago.format(thread.createdAt)}',
                  style: TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      IconlyLight.heart,
                      size: 16,
                      color: AppColors.textGray,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${thread.likeCount}',
                      style: TextStyle(fontSize: 12, color: AppColors.textGray),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Icon(IconlyLight.chat, size: 16, color: AppColors.textGray),
                    const SizedBox(width: 4),
                    Text(
                      '${thread.commentCount}',
                      style: TextStyle(fontSize: 12, color: AppColors.textGray),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
