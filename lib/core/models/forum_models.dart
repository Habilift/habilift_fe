// Forum Post Model
class ForumPostModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? category;
  final List<String>? tags;
  final bool isAnonymous;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final bool isPinned;
  final bool isLocked;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActivityAt;

  ForumPostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.category,
    this.tags,
    this.isAnonymous = false,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isPinned = false,
    this.isLocked = false,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActivityAt,
  });

  factory ForumPostModel.fromJson(Map<String, dynamic> json) {
    return ForumPostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      isPinned: json['is_pinned'] as bool? ?? false,
      isLocked: json['is_locked'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastActivityAt: DateTime.parse(json['last_activity_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'category': category,
      'tags': tags,
      'is_anonymous': isAnonymous,
      'view_count': viewCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_pinned': isPinned,
      'is_locked': isLocked,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_activity_at': lastActivityAt.toIso8601String(),
    };
  }
}

// Forum Comment Model
class ForumCommentModel {
  final String id;
  final String postId;
  final String userId;
  final String? parentCommentId;
  final String content;
  final bool isAnonymous;
  final int likeCount;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  ForumCommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentCommentId,
    required this.content,
    this.isAnonymous = false,
    this.likeCount = 0,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ForumCommentModel.fromJson(Map<String, dynamic> json) {
    return ForumCommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      parentCommentId: json['parent_comment_id'] as String?,
      content: json['content'] as String,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      likeCount: json['like_count'] as int? ?? 0,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'parent_comment_id': parentCommentId,
      'content': content,
      'is_anonymous': isAnonymous,
      'like_count': likeCount,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
