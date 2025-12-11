import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/forum_models.dart';

// Mock Categories
final forumCategoriesProvider = Provider<List<ForumCategory>>((ref) {
  return [
    const ForumCategory(
      id: '1',
      name: 'Mental Wellness',
      description:
          'Discuss mental health tips, coping strategies, and support.',
      iconName: 'heart',
      threadCount: 24,
      color: '#4CAF50',
    ),
    const ForumCategory(
      id: '2',
      name: 'Therapy Experiences',
      description: 'Share your therapy journey and learn from others.',
      iconName: 'chat',
      threadCount: 18,
      color: '#2196F3',
    ),
    const ForumCategory(
      id: '3',
      name: 'Self-Care',
      description: 'Tips and ideas for self-care routines and practices.',
      iconName: 'star',
      threadCount: 32,
      color: '#FF9800',
    ),
    const ForumCategory(
      id: '4',
      name: 'Relationships',
      description: 'Navigating relationships and building healthy connections.',
      iconName: 'users',
      threadCount: 15,
      color: '#E91E63',
    ),
    const ForumCategory(
      id: '5',
      name: 'Anxiety & Stress',
      description: 'A safe space to discuss anxiety and stress management.',
      iconName: 'activity',
      threadCount: 28,
      color: '#9C27B0',
    ),
    const ForumCategory(
      id: '6',
      name: 'General Discussion',
      description: 'Talk about anything related to wellness and lifestyle.',
      iconName: 'message-circle',
      threadCount: 41,
      color: '#607D8B',
    ),
  ];
});

// Mock Threads
final forumThreadsProvider = StateProvider<List<ForumThread>>((ref) {
  return [
    ForumThread(
      id: 't1',
      categoryId: '1',
      title: 'How do you manage daily anxiety?',
      content:
          'I have been struggling with daily anxiety and would love to hear how others cope. What techniques have worked for you?',
      authorName: 'Sarah M.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      commentCount: 12,
      likeCount: 34,
      isPinned: true,
    ),
    ForumThread(
      id: 't2',
      categoryId: '1',
      title: 'Meditation apps that actually work',
      content:
          'Looking for recommendations on meditation apps. I have tried a few but none seem to stick.',
      authorName: 'John D.',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      commentCount: 8,
      likeCount: 21,
    ),
    ForumThread(
      id: 't3',
      categoryId: '2',
      title: 'My first therapy session - what to expect?',
      content:
          'I am about to have my first therapy session next week. Any tips on what to expect and how to prepare?',
      authorName: 'Emily R.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      commentCount: 15,
      likeCount: 45,
    ),
    ForumThread(
      id: 't4',
      categoryId: '3',
      title: 'Morning routines that changed my life',
      content:
          'Sharing my morning self-care routine that helped me become more productive and calm throughout the day.',
      authorName: 'Michael T.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      commentCount: 22,
      likeCount: 67,
      images: [
        'https://img.freepik.com/premium-photo/portrait-young-african-woman-selling-fruits_665346-78583.jpg',
        'https://images.unsplash.com/photo-1515023115689-589c33041d3c',
      ],
    ),
  ];
});

// Selected Category
final selectedCategoryProvider = StateProvider<ForumCategory?>((ref) => null);

// Selected Thread
final selectedThreadProvider = StateProvider<ForumThread?>((ref) => null);

// Mock Comments
final threadCommentsProvider = StateProvider.family<List<ForumComment>, String>((
  ref,
  threadId,
) {
  return [
    ForumComment(
      id: 'c1',
      threadId: threadId,
      content:
          'This is really helpful! I have been dealing with the same thing.',
      authorName: 'Alex P.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      likeCount: 5,
    ),
    ForumComment(
      id: 'c2',
      threadId: threadId,
      content:
          'Have you tried journaling? It really helped me process my thoughts.',
      authorName: 'Lisa M.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      likeCount: 8,
    ),
    ForumComment(
      id: 'c3',
      threadId: threadId,
      content:
          'Thank you for sharing this. It takes courage to open up about these things.',
      authorName: 'David K.',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      likeCount: 12,
    ),
  ];
});

// AI Moderation Check (Mock)
class ModerationResult {
  final bool isFlagged;
  final String? reason;
  final double confidenceScore;

  const ModerationResult({
    required this.isFlagged,
    this.reason,
    required this.confidenceScore,
  });
}

final aiModerationProvider = Provider<ModerationResult Function(String)>((ref) {
  return (String content) {
    // Mock AI moderation logic
    final lowerContent = content.toLowerCase();

    // Check for potentially harmful content (simplified mock)
    if (lowerContent.contains('suicide') ||
        lowerContent.contains('self-harm')) {
      return const ModerationResult(
        isFlagged: true,
        reason:
            'Content may contain crisis-related topics. Please contact a crisis helpline if you need immediate support.',
        confidenceScore: 0.95,
      );
    }

    if (lowerContent.contains('hate') || lowerContent.contains('abuse')) {
      return const ModerationResult(
        isFlagged: true,
        reason:
            'Content may violate community guidelines. Please review our terms of service.',
        confidenceScore: 0.85,
      );
    }

    return const ModerationResult(isFlagged: false, confidenceScore: 0.1);
  };
});
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/forum_models.dart';

// Mock Categories
final forumCategoriesProvider = Provider<List<ForumCategory>>((ref) {
  return [
    const ForumCategory(
      id: '1',
      name: 'Mental Wellness',
      description:
          'Discuss mental health tips, coping strategies, and support.',
      iconName: 'heart',
      threadCount: 24,
      color: '#4CAF50',
    ),
    const ForumCategory(
      id: '2',
      name: 'Therapy Experiences',
      description: 'Share your therapy journey and learn from others.',
      iconName: 'chat',
      threadCount: 18,
      color: '#2196F3',
    ),
    const ForumCategory(
      id: '3',
      name: 'Self-Care',
      description: 'Tips and ideas for self-care routines and practices.',
      iconName: 'star',
      threadCount: 32,
      color: '#FF9800',
    ),
    const ForumCategory(
      id: '4',
      name: 'Relationships',
      description: 'Navigating relationships and building healthy connections.',
      iconName: 'users',
      threadCount: 15,
      color: '#E91E63',
    ),
    const ForumCategory(
      id: '5',
      name: 'Anxiety & Stress',
      description: 'A safe space to discuss anxiety and stress management.',
      iconName: 'activity',
      threadCount: 28,
      color: '#9C27B0',
    ),
    const ForumCategory(
      id: '6',
      name: 'General Discussion',
      description: 'Talk about anything related to wellness and lifestyle.',
      iconName: 'message-circle',
      threadCount: 41,
      color: '#607D8B',
    ),
  ];
});

// Mock Threads
final forumThreadsProvider = StateProvider<List<ForumThread>>((ref) {
  return [
    ForumThread(
      id: 't1',
      categoryId: '1',
      title: 'How do you manage daily anxiety?',
      content:
          'I have been struggling with daily anxiety and would love to hear how others cope. What techniques have worked for you?',
      authorName: 'Sarah M.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      commentCount: 12,
      likeCount: 34,
      isPinned: true,
    ),
    ForumThread(
      id: 't2',
      categoryId: '1',
      title: 'Meditation apps that actually work',
      content:
          'Looking for recommendations on meditation apps. I have tried a few but none seem to stick.',
      authorName: 'John D.',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      commentCount: 8,
      likeCount: 21,
    ),
    ForumThread(
      id: 't3',
      categoryId: '2',
      title: 'My first therapy session - what to expect?',
      content:
          'I am about to have my first therapy session next week. Any tips on what to expect and how to prepare?',
      authorName: 'Emily R.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      commentCount: 15,
      likeCount: 45,
    ),
    ForumThread(
      id: 't4',
      categoryId: '3',
      title: 'Morning routines that changed my life',
      content:
          'Sharing my morning self-care routine that helped me become more productive and calm throughout the day.',
      authorName: 'Michael T.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      commentCount: 22,
      likeCount: 67,
    ),
  ];
});

// Selected Category
final selectedCategoryProvider = StateProvider<ForumCategory?>((ref) => null);

// Selected Thread
final selectedThreadProvider = StateProvider<ForumThread?>((ref) => null);

// Mock Comments
final threadCommentsProvider = Provider.family<List<ForumComment>, String>((
  ref,
  threadId,
) {
  return [
    ForumComment(
      id: 'c1',
      threadId: threadId,
      content:
          'This is really helpful! I have been dealing with the same thing.',
      authorName: 'Alex P.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      likeCount: 5,
    ),
    ForumComment(
      id: 'c2',
      threadId: threadId,
      content:
          'Have you tried journaling? It really helped me process my thoughts.',
      authorName: 'Lisa M.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      likeCount: 8,
    ),
    ForumComment(
      id: 'c3',
      threadId: threadId,
      content:
          'Thank you for sharing this. It takes courage to open up about these things.',
      authorName: 'David K.',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      likeCount: 12,
    ),
  ];
});

// AI Moderation Check (Mock)
class ModerationResult {
  final bool isFlagged;
  final String? reason;
  final double confidenceScore;

  const ModerationResult({
    required this.isFlagged,
    this.reason,
    required this.confidenceScore,
  });
}

final aiModerationProvider = Provider<ModerationResult Function(String)>((ref) {
  return (String content) {
    // Mock AI moderation logic
    final lowerContent = content.toLowerCase();

    // Check for potentially harmful content (simplified mock)
    if (lowerContent.contains('suicide') ||
        lowerContent.contains('self-harm')) {
      return const ModerationResult(
        isFlagged: true,
        reason:
            'Content may contain crisis-related topics. Please contact a crisis helpline if you need immediate support.',
        confidenceScore: 0.95,
      );
    }

    if (lowerContent.contains('hate') || lowerContent.contains('abuse')) {
      return const ModerationResult(
        isFlagged: true,
        reason:
            'Content may violate community guidelines. Please review our terms of service.',
        confidenceScore: 0.85,
      );
    }

    return const ModerationResult(isFlagged: false, confidenceScore: 0.1);
  };
});
