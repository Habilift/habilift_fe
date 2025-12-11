import 'package:supabase_flutter/supabase_flutter.dart';

class MoodRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Save a mood entry and update current mood in profile
  Future<void> saveMoodEntry({
    required int moodScore,
    String? moodLabel,
    String? notes,
    List<String>? activities,
    List<String>? triggers,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final today = DateTime.now().toIso8601String().split('T')[0];

    // Save mood entry
    await _supabase.from('mood_entries').insert({
      'user_id': userId,
      'mood_score': moodScore,
      'mood_label': moodLabel,
      'notes': notes,
      'activities': activities,
      'triggers': triggers,
      'entry_date': today,
    });

    // Update current mood in profile
    await _supabase.from('profiles').update({
      'current_mood': moodLabel,
      'last_active_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  /// Get weekly mood data with daily means
  Future<Map<String, double>> getWeeklyMoodTrend() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    // Get last 7 days
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 6));

    final response = await _supabase
        .from('mood_entries')
        .select('entry_date, mood_score')
        .eq('user_id', userId)
        .gte('entry_date', startDate.toIso8601String().split('T')[0])
        .lte('entry_date', endDate.toIso8601String().split('T')[0])
        .order('entry_date');

    // Group by date and calculate mean
    final Map<String, List<int>> groupedByDate = {};
    for (var entry in response) {
      final date = entry['entry_date'] as String;
      final score = entry['mood_score'] as int;
      groupedByDate.putIfAbsent(date, () => []).add(score);
    }

    // Calculate daily means
    final Map<String, double> dailyMeans = {};
    groupedByDate.forEach((date, scores) {
      final mean = scores.reduce((a, b) => a + b) / scores.length;
      dailyMeans[date] = mean;
    });

    return dailyMeans;
  }

  /// Get all mood entries for today
  Future<List<Map<String, dynamic>>> getTodayMoodEntries() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final today = DateTime.now().toIso8601String().split('T')[0];

    final response = await _supabase
        .from('mood_entries')
        .select()
        .eq('user_id', userId)
        .eq('entry_date', today)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get today's average mood score
  Future<double?> getTodayAverageMood() async {
    final entries = await getTodayMoodEntries();
    if (entries.isEmpty) return null;

    final scores = entries.map((e) => e['mood_score'] as int).toList();
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Get mood label from score
  String getMoodLabel(int score) {
    if (score >= 9) return 'Excellent';
    if (score >= 7) return 'Good';
    if (score >= 5) return 'Okay';
    if (score >= 3) return 'Not Great';
    return 'Poor';
  }

  /// Get mood emoji from score
  String getMoodEmoji(int score) {
    if (score >= 9) return '😁';
    if (score >= 7) return '😊';
    if (score >= 5) return '😐';
    if (score >= 3) return '😕';
    return '😢';
  }
}
