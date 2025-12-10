import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../../../app/theme/app_theme.dart';

class AssessmentIntroScreen extends StatelessWidget {
  const AssessmentIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textBlack),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.medicalGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                IconlyBold.heart,
                size: 64,
                color: AppColors.medicalGreen,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 32),
            Text(
              'AI Mental Health\nAssessment',
              style: AppTypography.lightTextTheme.displayLarge?.copyWith(
                color: AppColors.textBlack,
                height: 1.2,
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(),
            const SizedBox(height: 16),
            Text(
              'Take a quick assessment to understand your current mental well-being. Our AI-powered tool will analyze your responses and provide personalized recommendations.',
              style: AppTypography.lightTextTheme.bodyLarge?.copyWith(
                color: AppColors.textGray,
              ),
            ).animate().fadeIn(delay: 400.ms).slideX(),
            const SizedBox(height: 32),
            _buildFeatureItem(
              icon: IconlyBold.timeCircle,
              title: 'Quick & Easy',
              subtitle: 'Takes less than 2 minutes',
              delay: 600,
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              icon: IconlyBold.shieldDone,
              title: 'Private & Secure',
              subtitle: 'Your data is processed locally',
              delay: 700,
            ),
            const Spacer(flex: 2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/assessment/question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.medicalGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Start Assessment',
                  style: AppTypography.lightTextTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required int delay,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Icon(icon, color: AppColors.medicalGreen),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.lightTextTheme.titleLarge?.copyWith(
                fontSize: 16,
              ),
            ),
            Text(
              subtitle,
              style: AppTypography.lightTextTheme.bodyMedium?.copyWith(
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: delay.ms).slideX();
  }
}
