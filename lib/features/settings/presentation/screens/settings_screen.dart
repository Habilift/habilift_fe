import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.medicalGreen,
                      AppColors.medicalGreen.withValues(alpha: 0.85),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 4),
                    Text(
                          'Manage your account and preferences',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 100.ms)
                        .slideX(begin: -0.2, end: 0),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Profile Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingCard(
                          icon: IconlyBold.profile,
                          title: 'Edit Profile',
                          subtitle: 'Update your personal information',
                          onTap: () {},
                        )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideX(begin: 0.1, end: 0),
                    const SizedBox(height: 12),
                    _buildSettingCard(
                          icon: IconlyBold.lock,
                          title: 'Change Password',
                          subtitle: 'Update your security credentials',
                          onTap: () {},
                        )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .slideX(begin: 0.1, end: 0),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Preferences Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingCard(
                          icon: IconlyBold.notification,
                          title: 'Notifications',
                          subtitle: 'Manage notification preferences',
                          onTap: () {},
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideX(begin: 0.1, end: 0),
                    const SizedBox(height: 12),
                    _buildSettingCard(
                          icon: IconlyBold.show,
                          title: 'Privacy',
                          subtitle: 'Control your privacy settings',
                          onTap: () {},
                        )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .slideX(begin: 0.1, end: 0),
                    const SizedBox(height: 12),
                    _buildSettingCard(
                          icon: IconlyBold.document,
                          title: 'Language',
                          subtitle: 'English',
                          onTap: () {},
                        )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideX(begin: 0.1, end: 0),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // App Settings Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingCard(
                          icon: IconlyBold.infoSquare,
                          title: 'About',
                          subtitle: 'App version and information',
                          onTap: () {},
                        )
                        .animate()
                        .fadeIn(delay: 700.ms)
                        .slideX(begin: 0.1, end: 0),
                    const SizedBox(height: 12),
                    _buildSettingCard(
                          icon: IconlyBold.shieldDone,
                          title: 'Terms & Privacy Policy',
                          subtitle: 'Read our terms and policies',
                          onTap: () {},
                        )
                        .animate()
                        .fadeIn(delay: 800.ms)
                        .slideX(begin: 0.1, end: 0),
                    const SizedBox(height: 12),
                    _buildSettingCard(
                          icon: IconlyBold.message,
                          title: 'Help & Support',
                          subtitle: 'Get help or contact support',
                          onTap: () {},
                        )
                        .animate()
                        .fadeIn(delay: 900.ms)
                        .slideX(begin: 0.1, end: 0),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement logout
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(IconlyBold.logout, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 1000.ms).scale(duration: 400.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.medicalGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.medicalGreen, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: AppColors.textGray),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGray),
          ],
        ),
      ),
    );
  }
}
