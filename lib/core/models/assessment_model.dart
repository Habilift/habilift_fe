// Assessment Model for mental health assessments
class AssessmentModel {
  final String id;
  final String userId;
  final String assessmentType;
  final String title;
  final String? description;
  final double? score;
  final double? maxScore;
  final double? percentage;
  final String? severityLevel;
  final Map<String, dynamic>? results;
  final List<String>? recommendations;
  final DateTime completedAt;
  final DateTime createdAt;

  AssessmentModel({
    required this.id,
    required this.userId,
    required this.assessmentType,
    required this.title,
    this.description,
    this.score,
    this.maxScore,
    this.percentage,
    this.severityLevel,
    this.results,
    this.recommendations,
    required this.completedAt,
    required this.createdAt,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      assessmentType: json['assessment_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      maxScore: json['max_score'] != null
          ? (json['max_score'] as num).toDouble()
          : null,
      percentage: json['percentage'] != null
          ? (json['percentage'] as num).toDouble()
          : null,
      severityLevel: json['severity_level'] as String?,
      results: json['results'] as Map<String, dynamic>?,
      recommendations: json['recommendations'] != null
          ? List<String>.from(json['recommendations'] as List)
          : null,
      completedAt: DateTime.parse(json['completed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'assessment_type': assessmentType,
      'title': title,
      'description': description,
      'score': score,
      'max_score': maxScore,
      'percentage': percentage,
      'severity_level': severityLevel,
      'results': results,
      'recommendations': recommendations,
      'completed_at': completedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
