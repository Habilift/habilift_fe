// Resource Model for educational content
class ResourceModel {
  final String id;
  final String title;
  final String? description;
  final String? content;
  final String category;
  final String? thumbnailUrl;
  final String? contentUrl;
  final String? videoUrl;
  final int? durationMinutes;
  final List<String>? tags;
  final List<String>? targetAudience;
  final String? difficultyLevel;
  final int viewCount;
  final int likeCount;
  final int bookmarkCount;
  final String? authorId;
  final String? authorName;
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ResourceModel({
    required this.id,
    required this.title,
    this.description,
    this.content,
    required this.category,
    this.thumbnailUrl,
    this.contentUrl,
    this.videoUrl,
    this.durationMinutes,
    this.tags,
    this.targetAudience,
    this.difficultyLevel,
    this.viewCount = 0,
    this.likeCount = 0,
    this.bookmarkCount = 0,
    this.authorId,
    this.authorName,
    this.isPublished = false,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      content: json['content'] as String?,
      category: json['category'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      contentUrl: json['content_url'] as String?,
      videoUrl: json['video_url'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      targetAudience: json['target_audience'] != null
          ? List<String>.from(json['target_audience'] as List)
          : null,
      difficultyLevel: json['difficulty_level'] as String?,
      viewCount: json['view_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      bookmarkCount: json['bookmark_count'] as int? ?? 0,
      authorId: json['author_id'] as String?,
      authorName: json['author_name'] as String?,
      isPublished: json['is_published'] as bool? ?? false,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'category': category,
      'thumbnail_url': thumbnailUrl,
      'content_url': contentUrl,
      'video_url': videoUrl,
      'duration_minutes': durationMinutes,
      'tags': tags,
      'target_audience': targetAudience,
      'difficulty_level': difficultyLevel,
      'view_count': viewCount,
      'like_count': likeCount,
      'bookmark_count': bookmarkCount,
      'author_id': authorId,
      'author_name': authorName,
      'is_published': isPublished,
      'published_at': publishedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
