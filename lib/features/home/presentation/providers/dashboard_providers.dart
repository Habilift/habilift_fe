import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/repositories/profile_repository.dart';
import '../../../../core/repositories/mood_repository.dart';
import '../../../../core/models/profile_model.dart';

// Export profile repository provider for use in other screens
export '../../../../core/repositories/profile_repository.dart' show ProfileRepository;


// Navigation State
final dashboardIndexProvider = StateProvider<int>((ref) => 0);

// Profile Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

// Mood Repository Provider
final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return MoodRepository();
});

// Weekly Mood Trend Provider
final weeklyMoodTrendProvider = FutureProvider<Map<String, double>>((ref) async {
  final moodRepo = ref.read(moodRepositoryProvider);
  return await moodRepo.getWeeklyMoodTrend();
});

// Real User Profile Provider
final userProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final profileRepo = ref.read(profileRepositoryProvider);
  return await profileRepo.getCurrentUserProfile();
});

// User Data class for backward compatibility
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

// User data provider that uses real profile data
final userDataProvider = Provider<AsyncValue<UserData>>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  
  return profileAsync.when(
    data: (profile) {
      if (profile == null) {
        return AsyncValue.data(UserData(
          name: 'User',
          email: 'user@example.com',
          sessionsCompleted: 0,
          assessmentsCompleted: 0,
          wellnessScore: 0.0,
          currentMood: 'Unknown',
        ));
      }
      
      return AsyncValue.data(UserData(
        name: profile.name,
        email: profile.email,
        sessionsCompleted: 0, // TODO: Fetch from sessions table
        assessmentsCompleted: 0, // TODO: Fetch from assessments table
        wellnessScore: profile.wellnessScore ?? 0.0,
        currentMood: profile.currentMood ?? 'Unknown',
      ));
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Weekly Progress Data from Database
class WeeklyProgress {
  final List<double> moodScores;
  final List<String> days;

  WeeklyProgress({required this.moodScores, required this.days});
}

final weeklyProgressProvider = FutureProvider<WeeklyProgress>((ref) async {
  final moodRepo = ref.read(moodRepositoryProvider);
  final moodTrendData = await moodRepo.getWeeklyMoodTrend();
  
  // Generate last 7 days
  final last7Days = List.generate(7, (i) {
    final date = DateTime.now().subtract(Duration(days: 6 - i));
    return date;
  });
  
  // Map to day labels and scores
  final days = last7Days.map((date) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return dayNames[date.weekday - 1];
  }).toList();
  
  final moodScores = last7Days.map((date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return moodTrendData[dateStr] ?? 0.0;
  }).toList();
  
  return WeeklyProgress(
    moodScores: moodScores,
    days: days,
  );
});

// Monthly Stats from Database
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

final monthlyStatsProvider = FutureProvider<MonthlyStats>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) {
    return MonthlyStats(
      totalSessions: 0,
      completedAssessments: 0,
      averageMood: 0.0,
      streakDays: 0,
    );
  }

  final supabase = Supabase.instance.client;
  
  // Get current month's start and end dates
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1).toIso8601String();
  final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59).toIso8601String();
  
  // Fetch total sessions this month
  final sessionsResponse = await supabase
      .from('sessions')
      .select('id')
      .eq('user_id', userId)
      .gte('session_time', monthStart)
      .lte('session_time', monthEnd);
  
  final totalSessions = (sessionsResponse as List).length;
  
  // Fetch completed assessments this month
  final assessmentsResponse = await supabase
      .from('assessments')
      .select('id')
      .eq('user_id', userId)
      .gte('completed_at', monthStart)
      .lte('completed_at', monthEnd);
  
  final completedAssessments = (assessmentsResponse as List).length;
  
  // Calculate streak days from mood entries
  final moodRepo = ref.read(moodRepositoryProvider);
  final streakDays = await _calculateStreak(userId, supabase);
  
  // Calculate average mood for this month
  final moodEntriesResponse = await supabase
      .from('mood_entries')
      .select('mood_score')
      .eq('user_id', userId)
      .gte('entry_date', monthStart.split('T')[0])
      .lte('entry_date', monthEnd.split('T')[0]);
  
  double averageMood = 0.0;
  if (moodEntriesResponse is List && moodEntriesResponse.isNotEmpty) {
    final scores = moodEntriesResponse.map((e) => (e['mood_score'] as num).toDouble()).toList();
    averageMood = scores.reduce((a, b) => a + b) / scores.length;
  }
  
  return MonthlyStats(
    totalSessions: totalSessions,
    completedAssessments: completedAssessments,
    averageMood: averageMood,
    streakDays: streakDays,
  );
});

// Helper function to calculate consecutive streak days
Future<int> _calculateStreak(String userId, SupabaseClient supabase) async {
  // Get all mood entry dates ordered by date descending
  final response = await supabase
      .from('mood_entries')
      .select('entry_date')
      .eq('user_id', userId)
      .order('entry_date', ascending: false);
  
  if (response is! List || response.isEmpty) return 0;
  
  final dates = response.map((e) => DateTime.parse(e['entry_date'] as String)).toList();
  
  // Calculate streak
  int streak = 0;
  DateTime? previousDate;
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  
  for (var date in dates) {
    final entryDate = DateTime(date.year, date.month, date.day);
    
    if (streak == 0) {
      // First entry - check if it's today or yesterday
      final daysDiff = todayDate.difference(entryDate).inDays;
      if (daysDiff <= 1) {
        streak = 1;
        previousDate = entryDate;
      } else {
        break; // Streak is broken
      }
    } else {
      // Check if this date is consecutive with previous
      final daysDiff = previousDate!.difference(entryDate).inDays;
      if (daysDiff == 1) {
        streak++;
        previousDate = entryDate;
      } else {
        break; // Streak is broken
      }
    }
  }
  
  return streak;
}
