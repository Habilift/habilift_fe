import 'package:flutter_riverpod/flutter_riverpod.dart';

// Navigation State
final dashboardIndexProvider = StateProvider<int>((ref) => 0);

// Mock User Data
class UserData {
  final String name;
  final String email;
  final int sessionsCompleted;
  final int assessmentsCompleted;
  final double wellnessScore;
  final String currentMood;

  UserData({
    required this.name,
    required this.email,
    required this.sessionsCompleted,
    required this.assessmentsCompleted,
    required this.wellnessScore,
    required this.currentMood,
  });
}

// Mock user provider
final userDataProvider = Provider<UserData>((ref) {
  return UserData(
    name: 'Alex Johnson',
    email: 'alex.johnson@example.com',
    sessionsCompleted: 12,
    assessmentsCompleted: 5,
    wellnessScore: 7.5,
    currentMood: 'Good',
  );
});

// Mock Weekly Progress Data
class WeeklyProgress {
  final List<double> moodScores;
  final List<String> days;

  WeeklyProgress({required this.moodScores, required this.days});
}

final weeklyProgressProvider = Provider<WeeklyProgress>((ref) {
  return WeeklyProgress(
    moodScores: [6.5, 7.0, 6.8, 7.5, 8.0, 7.2, 7.5],
    days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  );
});

// Mock Monthly Stats
class MonthlyStats {
  final int totalSessions;
  final int completedAssessments;
  final double averageMood;
  final int streakDays;

  MonthlyStats({
    required this.totalSessions,
    required this.completedAssessments,
    required this.averageMood,
    required this.streakDays,
  });
}

final monthlyStatsProvider = Provider<MonthlyStats>((ref) {
  return MonthlyStats(
    totalSessions: 12,
    completedAssessments: 5,
    averageMood: 7.2,
    streakDays: 14,
  );
});
