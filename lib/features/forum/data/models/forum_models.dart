// Forum Models

class ForumCategory {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int threadCount;
  final String color;

  const ForumCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.threadCount = 0,
    this.color = '#0066CC',
  });
}

class ForumThread {
  final String id;
  final String categoryId;
  final String title;
  final String content;
  final String authorName;
  final String authorAvatar;
  final DateTime createdAt;
  final int commentCount;
  final int likeCount;
  final bool isPinned;
  final bool isLocked;
  final ModerationStatus moderationStatus;

  const ForumThread({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.content,
    required this.authorName,
    this.authorAvatar = 'assets/profile/default_avatar.png',
    required this.createdAt,
    this.commentCount = 0,
    this.likeCount = 0,
    this.isPinned = false,
    this.isLocked = false,
    this.moderationStatus = ModerationStatus.approved,
  });
}

class ForumComment {
  final String id;
  final String threadId;
  final String content;
  final String authorName;
  final String authorAvatar;
  final DateTime createdAt;
  final int likeCount;
  final ModerationStatus moderationStatus;

  const ForumComment({
    required this.id,
    required this.threadId,
    required this.content,
    required this.authorName,
    this.authorAvatar = 'assets/profile/default_avatar.png',
    required this.createdAt,
    this.likeCount = 0,
    this.moderationStatus = ModerationStatus.approved,
  });
}

enum ModerationStatus { pending, approved, flagged, removed }
