import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/dashboard_providers.dart';

class MoodTracker extends ConsumerStatefulWidget {
  const MoodTracker({super.key});

  @override
  ConsumerState<MoodTracker> createState() => _MoodTrackerState();
}

class _MoodTrackerState extends ConsumerState<MoodTracker> {
  String? _selectedMood;
  bool _showThankYou = false;
  bool _isSaving = false;

  static const List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'label': 'Great', 'color': Colors.green, 'score': 10},
    {'emoji': '🙂', 'label': 'Good', 'color': Colors.green, 'score': 8},
    {'emoji': '😐', 'label': 'Okay', 'color': Colors.orange, 'score': 6},
    {'emoji': '😔', 'label': 'Bad', 'color': Colors.orange, 'score': 4},
    {'emoji': '😢', 'label': 'Awful', 'color': Colors.red, 'score': 2},
  ];

  void _selectMood(String moodLabel, int moodScore) async {
    if (_isSaving) return;

    setState(() {
      _selectedMood = moodLabel;
      _isSaving = true;
    });

    try {
      // Save mood entry to database
      final moodRepo = ref.read(moodRepositoryProvider);
      await moodRepo.saveMoodEntry(
        moodScore: moodScore,
        moodLabel: moodLabel,
      );

      // Refresh weekly trend and user profile
      ref.invalidate(weeklyMoodTrendProvider);
      ref.invalidate(userProfileProvider);

      setState(() {
        _showThankYou = true;
        _isSaving = false;
      });

      // Hide thank you message after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showThankYou = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving mood: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.medicalGreen.withValues(alpha: 0.1),
            AppColors.lightGreen.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.medicalGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.medicalGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: AppColors.medicalGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mood Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _moods.map((mood) {
              final isSelected = _selectedMood == mood['label'];
              final moodScore = (mood['score'] ?? 5) as int;
              final moodLabel = (mood['label'] ?? 'Unknown') as String;
              return GestureDetector(
                    onTap: _isSaving ? null : () => _selectMood(moodLabel, moodScore),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? mood['color'].withValues(alpha: 0.2)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? mood['color'] : AppColors.divider,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: mood['color'].withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        children: [
                          Text(
                            mood['emoji'],
                            style: TextStyle(fontSize: isSelected ? 32 : 28),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mood['label'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? mood['color']
                                  : AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate(target: isSelected ? 1 : 0)
                  .scale(
                    duration: 300.ms,
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                  );
            }).toList(),
          ),

          // Thank you message
          if (_showThankYou)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.medicalGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.medicalGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Thanks for sharing! We\'re here for you.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.medicalGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),
        ],
      ),
    );
  }
}
