import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/models/forum_models.dart';
import '../providers/forum_provider.dart';

class ForumHomeScreen extends ConsumerStatefulWidget {
  const ForumHomeScreen({super.key});

  @override
  ConsumerState<ForumHomeScreen> createState() => _ForumHomeScreenState();
}

class _ForumHomeScreenState extends ConsumerState<ForumHomeScreen> {
  String _selectedCategoryId = 'all';

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(forumCategoriesProvider);
    final allThreads = ref.watch(forumThreadsProvider);

    // Filter logic
    final threads = _selectedCategoryId == 'all'
        ? allThreads
        : allThreads.where((t) => t.categoryId == _selectedCategoryId).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      appBar: AppBar(
        title: const Text(
          'Community',
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.search, color: AppColors.textBlack),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              IconlyLight.notification,
              color: AppColors.textBlack,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filters
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _FilterChip(
                    label: 'All',
                    isSelected: _selectedCategoryId == 'all',
                    onTap: () => setState(() => _selectedCategoryId = 'all'),
                  );
                }
                final category = categories[index - 1];
                return _FilterChip(
                  label: category.name,
                  isSelected: _selectedCategoryId == category.id,
                  onTap: () =>
                      setState(() => _selectedCategoryId = category.id),
                );
              },
            ),
          ),

          // Threads List
          Expanded(
            child: threads.isEmpty
                ? _EmptyState(categoryName: _getCategoryName(categories))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: threads.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final thread = threads[index];
                      return _ThreadCard(thread: thread);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 80.0,
        ), // Avoid overlap with bottom nav
        child: SizedBox(
          height: 56, // Standard FAB size
          width: 56,
          child: FloatingActionButton(
            onPressed: () {
              // Pass current category if specific one is selected
              context.push(
                '/forum/create',
                extra: _selectedCategoryId == 'all'
                    ? null
                    : _selectedCategoryId,
              );
            },
            backgroundColor: AppColors.medicalGreen,
            elevation: 4,
            child: const Icon(IconlyBold.edit, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  String _getCategoryName(List<ForumCategory> categories) {
    if (_selectedCategoryId == 'all') return 'this category';
    return categories.firstWhere((c) => c.id == _selectedCategoryId).name;
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.medicalGreen : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.medicalGreen : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textGray,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String categoryName;

  const _EmptyState({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.medicalGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconlyBold.chat,
              size: 48,
              color: AppColors.medicalGreen.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No discussions yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to post in $categoryName!',
            style: TextStyle(color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}

class _ThreadCard extends ConsumerWidget {
  final ForumThread thread;

  const _ThreadCard({required this.thread});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedThreadProvider.notifier).state = thread;
        context.push('/forum/thread/${thread.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author row
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.medicalGreen.withOpacity(0.1),
                  child: Text(
                    thread.authorName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.medicalGreen,
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
                const SizedBox(width: 4),
                Text(
                  '• ${timeago.format(thread.createdAt)}',
                  style: TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
                if (thread.isPinned) ...[
                  const Spacer(),
                  Icon(Icons.push_pin, size: 16, color: AppColors.medicalGreen),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Title & Preview
            Text(
              thread.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
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

            // Images Preview (if any)
            if (thread.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: thread.images.length.clamp(0, 3), // Show max 3
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final imagePath = thread.images[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: imagePath.startsWith('http')
                            ? Image.network(
                                imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : Image.file(
                                File(imagePath),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                _StatItem(
                  icon: IconlyLight.heart,
                  count: thread.likeCount,
                  color: Colors.red.withOpacity(0.7),
                ),
                const SizedBox(width: 16),
                _StatItem(
                  icon: IconlyLight.chat,
                  count: thread.commentCount,
                  color: AppColors.medicalGreen.withOpacity(0.7),
                ),
                const Spacer(),
                const Text(
                  'Read More',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.medicalGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textGray),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
