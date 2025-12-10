import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

class AssessmentProgressBar extends StatelessWidget {
  final double progress;

  const AssessmentProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceGray,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.medicalGreen,
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              colors: [
                AppColors.medicalGreen,
                Color(0xFF4CAF50),
              ], // Example gradient
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
    );
  }
}
