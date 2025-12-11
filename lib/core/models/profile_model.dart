// Enhanced Profile Model with all new fields from optimized schema
class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? phone;
  
  // Extended Profile Data
  final String? gender;
  final String? ageRange;
  final DateTime? dateOfBirth;
  
  // Location & Language
  final String? country;
  final String? city;
  final String? timezone;
  final String preferredLanguage;
  
  // User Type & Goals
  final String userType;
  final List<String>? goals;
  final String? bio;
  
  // Wellness Metrics
  final double? wellnessScore;
  final String? currentMood;
  final int streakDays;
  
  // Privacy & Preferences
  final bool isProfilePublic;
  final bool allowAnonymousForum;
  final Map<String, dynamic>? notificationPreferences;
  
  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActiveAt;

  ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.phone,
    this.gender,
    this.ageRange,
    this.dateOfBirth,
    this.country,
    this.city,
    this.timezone,
    this.preferredLanguage = 'English',
    this.userType = 'individual',
    this.goals,
    this.bio,
    this.wellnessScore,
    this.currentMood,
    this.streakDays = 0,
    this.isProfilePublic = false,
    this.allowAnonymousForum = true,
    this.notificationPreferences,
    required this.createdAt,
    required this.updatedAt,
    this.lastActiveAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      ageRange: json['age_range'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      country: json['country'] as String?,
      city: json['city'] as String?,
      timezone: json['timezone'] as String?,
      preferredLanguage: json['preferred_language'] as String? ?? 'English',
      userType: json['user_type'] as String? ?? 'individual',
      goals: json['goals'] != null
          ? List<String>.from(json['goals'] as List)
          : null,
      bio: json['bio'] as String?,
      wellnessScore: json['wellness_score'] != null
          ? (json['wellness_score'] as num).toDouble()
          : null,
      currentMood: json['current_mood'] as String?,
      streakDays: json['streak_days'] as int? ?? 0,
      isProfilePublic: json['is_profile_public'] as bool? ?? false,
      allowAnonymousForum: json['allow_anonymous_forum'] as bool? ?? true,
      notificationPreferences:
          json['notification_preferences'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'phone': phone,
      'gender': gender,
      'age_range': ageRange,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'country': country,
      'city': city,
      'timezone': timezone,
      'preferred_language': preferredLanguage,
      'user_type': userType,
      'goals': goals,
      'bio': bio,
      'wellness_score': wellnessScore,
      'current_mood': currentMood,
      'streak_days': streakDays,
      'is_profile_public': isProfilePublic,
      'allow_anonymous_forum': allowAnonymousForum,
      'notification_preferences': notificationPreferences,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? name,
    String? avatarUrl,
    String? phone,
    String? gender,
    String? ageRange,
    DateTime? dateOfBirth,
    String? country,
    String? city,
    String? timezone,
    String? preferredLanguage,
    String? userType,
    List<String>? goals,
    String? bio,
    double? wellnessScore,
    String? currentMood,
    int? streakDays,
    bool? isProfilePublic,
    bool? allowAnonymousForum,
    Map<String, dynamic>? notificationPreferences,
    DateTime? lastActiveAt,
  }) {
    return ProfileModel(
      id: id,
      name: name ?? this.name,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      ageRange: ageRange ?? this.ageRange,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      country: country ?? this.country,
      city: city ?? this.city,
      timezone: timezone ?? this.timezone,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      userType: userType ?? this.userType,
      goals: goals ?? this.goals,
      bio: bio ?? this.bio,
      wellnessScore: wellnessScore ?? this.wellnessScore,
      currentMood: currentMood ?? this.currentMood,
      streakDays: streakDays ?? this.streakDays,
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      allowAnonymousForum: allowAnonymousForum ?? this.allowAnonymousForum,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}
