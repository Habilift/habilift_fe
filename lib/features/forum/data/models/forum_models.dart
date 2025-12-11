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
    this.images = const [],
  });

  final List<String> images;

  ForumThread copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? content,
    String? authorName,
    String? authorAvatar,
    DateTime? createdAt,
    int? commentCount,
    int? likeCount,
    bool? isPinned,
    bool? isLocked,
    ModerationStatus? moderationStatus,
    List<String>? images,
  }) {
    return ForumThread(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      createdAt: createdAt ?? this.createdAt,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      images: images ?? this.images,
    );
  }
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
  final bool isSpecialist;

  const ForumComment({
    required this.id,
    required this.threadId,
    required this.content,
    required this.authorName,
    this.authorAvatar = 'assets/profile/default_avatar.png',
    required this.createdAt,
    this.likeCount = 0,
    this.moderationStatus = ModerationStatus.approved,
    this.isSpecialist = false,
  });

  ForumComment copyWith({
    String? id,
    String? threadId,
    String? content,
    String? authorName,
    String? authorAvatar,
    DateTime? createdAt,
    int? likeCount,
    ModerationStatus? moderationStatus,
    bool? isSpecialist,
  }) {
    return ForumComment(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      isSpecialist: isSpecialist ?? this.isSpecialist,
    );
  }
}

enum ModerationStatus { pending, approved, flagged, removed }
