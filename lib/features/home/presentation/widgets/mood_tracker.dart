import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';

class MoodTracker extends StatefulWidget {
  const MoodTracker({super.key});

  @override
  State<MoodTracker> createState() => _MoodTrackerState();
}

class _MoodTrackerState extends State<MoodTracker> {
  String? _selectedMood;
  bool _showThankYou = false;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'label': 'Great', 'color': Colors.green},
    {'emoji': '🙂', 'label': 'Good', 'color': AppColors.medicalGreen},
    {'emoji': '😐', 'label': 'Okay', 'color': AppColors.warningOrange},
    {'emoji': '😔', 'label': 'Bad', 'color': Colors.orange},
    {'emoji': '😢', 'label': 'Awful', 'color': AppColors.errorRed},
  ];

  void _selectMood(String mood) {
    setState(() {
      _selectedMood = mood;
      _showThankYou = true;
    });

    // Hide thank you message after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showThankYou = false;
        });
      }
    });
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
              return GestureDetector(
                    onTap: () => _selectMood(mood['label']),
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
