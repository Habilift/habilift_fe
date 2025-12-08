import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../../../app/theme/app_colors.dart';

class UserTypeScreen extends ConsumerWidget {
  const UserTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textBlack,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Who are you?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.medicalGreen,
                ),
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'Select your role to get a personalized experience.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textGray),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 32),

              _UserTypeCard(
                icon: IconlyBold.heart,
                title: 'Client / Patient',
                description:
                    'I am looking for mental health support or guidance.',
                color: AppColors.medicalGreen,
                delay: 400.ms,
                onTap: () => context.push('/auth'),
              ),
              _UserTypeCard(
                icon: IconlyBold.user3, // Specialist icon
                title: 'Specialist',
                description:
                    'I am a Psychologist, Psychiatrist, or Special Educator.',
                color: AppColors.medicalBlue,
                delay: 500.ms,
                onTap: () => context.push('/auth'),
              ),
              _UserTypeCard(
                icon: IconlyBold.work, // Lay counsellor
                title: 'Lay Counsellor',
                description: 'I am a community worker or lay counsellor.',
                color: AppColors.warningOrange,
                delay: 600.ms,
                onTap: () => context.push('/auth'),
              ),
              _UserTypeCard(
                icon: IconlyBold.user2, // Parent icon
                title: 'Parent / Caregiver',
                description: 'I am caring for a child with special needs.',
                color: const Color(0xFF9C27B0), // Purple for parents
                delay: 700.ms,
                onTap: () => context.push('/auth'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Duration delay;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textGray,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay).slideY(begin: 0.2, end: 0);
  }
}
