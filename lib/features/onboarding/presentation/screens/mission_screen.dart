import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../../../app/theme/app_colors.dart';

class MissionScreen extends ConsumerWidget {
  const MissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                'Our Mission',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.medicalGreen,
                ),
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'Lifting Lives, Unlocking Potential.',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.textBlack),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 32),

              // Mission Image - full width, no padding
              // Container(
              //   height: MediaQuery.of(context).size.height * 0.45,
              //   width: double.infinity,
              //   constraints: BoxConstraints(
              //     minHeight: 250,
              //     maxHeight: MediaQuery.of(context).size.height * 0.5,
              //   ),
              //   child: Stack(
              //     children: [
              //       // Main image with cover fit
              //       Positioned.fill(
              //         child: Image.asset(
              //           'assets/images/onboardings/mission.png',
              //           fit: BoxFit.cover,
              //           alignment: Alignment.center,
              //         ),
              //       ),
              //       // Extremely aggressive gradient to completely hide image outline
              //       Positioned.fill(
              //         child: DecoratedBox(
              //           decoration: BoxDecoration(
              //             gradient: RadialGradient(
              //               center: Alignment.center,
              //               radius: 0.65,
              //               colors: [
              //                 Colors.transparent,
              //                 Colors.transparent,
              //                 Colors.white.withValues(alpha: 0.1),
              //                 Colors.white.withValues(alpha: 0.25),
              //                 Colors.white.withValues(alpha: 0.4),
              //                 Colors.white.withValues(alpha: 0.55),
              //                 Colors.white.withValues(alpha: 0.7),
              //                 Colors.white.withValues(alpha: 0.85),
              //                 Colors.white.withValues(alpha: 0.95),
              //                 Colors.white,
              //               ],
              //               stops: const [
              //                 0.0,
              //                 0.2,
              //                 0.35,
              //                 0.48,
              //                 0.58,
              //                 0.67,
              //                 0.75,
              //                 0.83,
              //                 0.92,
              //                 1.0,
              //               ],
              //             ),
              //           ),
              //         ),
              //       ),
              //       // Additional bottom gradient to close bottom edge
              //       Positioned.fill(
              //         child: DecoratedBox(
              //           decoration: BoxDecoration(
              //             gradient: LinearGradient(
              //               begin: Alignment.center,
              //               end: Alignment.bottomCenter,
              //               colors: [
              //                 Colors.transparent,
              //                 Colors.white.withValues(alpha: 0.3),
              //                 Colors.white.withValues(alpha: 0.7),
              //                 Colors.white,
              //               ],
              //               stops: const [0.0, 0.7, 0.9, 1.0],
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ).animate().fadeIn(delay: 400.ms).scale(duration: 600.ms),
              const SizedBox(height: 32),

              // Impact Cards
              _ImpactCard(
                icon: IconlyBold.video,
                title: 'Access to Professionals',
                description:
                    'Connect with licensed specialists anytime, anywhere.',
                color: AppColors.medicalBlue,
                delay: 500.ms,
              ),
              _ImpactCard(
                icon: IconlyBold.swap,
                title: 'Low-Bandwidth Support',
                description:
                    'Works seamlessly even with poor internet connection.',
                color: AppColors.warningOrange,
                delay: 600.ms,
              ),
              _ImpactCard(
                icon: IconlyBold.lock,
                title: 'Safe & Confidential',
                description:
                    'Your privacy is our top priority. End-to-end encrypted.',
                color: AppColors.medicalGreen,
                delay: 700.ms,
              ),
              _ImpactCard(
                icon: IconlyBold.heart,
                title: 'Inclusive Support',
                description:
                    'Specialized care for mental health and special needs.',
                color: const Color(0xFFE91E63),
                delay: 800.ms,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/user-type'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Duration delay;

  const _ImpactCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay).slideX(begin: 0.1, end: 0);
  }
}
