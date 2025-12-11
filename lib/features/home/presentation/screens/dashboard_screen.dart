import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/mood_tracker.dart';
import '../widgets/specialist_carousel.dart';
import '../widgets/kpi_card.dart';
import '../widgets/weekly_mood_chart.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../specialists/presentation/screens/specialists_screen.dart';
import '../../../booking/presentation/screens/booking_screen.dart';
import '../../../forum/presentation/screens/forum_home_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(userDataProvider);
    final weeklyProgressAsync = ref.watch(weeklyProgressProvider);
    final monthlyStatsAsync = ref.watch(monthlyStatsProvider);
    final activeIndex = ref.watch(dashboardIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.medicalGreen,
      body: SafeArea(
        child: userDataAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Error loading data: $error',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          data: (userData) {
            return weeklyProgressAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error loading progress: $error',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              data: (weeklyProgress) {
                return monthlyStatsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading stats: $error',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  data: (monthlyStats) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: IndexedStack(
                        key: ValueKey<int>(activeIndex),
                        index: activeIndex,
                        children: [
                          _buildHomeTab(context, userData, weeklyProgress, monthlyStats),
                          const SpecialistsScreen(), // Index 1: Specialists
                          _buildPlaceholderTab('Forum', IconlyBold.chat), // Index 2: Forum
                          const SettingsScreen(), // Index 3: Settings
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingSpecialistButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildFloatingSpecialistButton() {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
      child:
          Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.medicalGreen,
                      AppColors.medicalGreen.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.medicalGreen.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Animate button press
                      _fabAnimationController.reverse().then((_) {
                        _fabAnimationController.forward();
                      });
                      // Navigate to booking screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BookingScreen(),
                        ),
                      );
                    },
                    customBorder: const CircleBorder(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          IconlyBold.user2,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Book',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(
                duration: 2000.ms,
                color: Colors.white.withValues(alpha: 0.3),
              ),
    );
  }

  Widget _buildHomeTab(
    BuildContext context,
    UserData userData,
    WeeklyProgress weeklyProgress,
    MonthlyStats monthlyStats,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Header Section with Medical Green Background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
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
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profile Picture and Name
                    Row(
                      children: [
                        // Circular Profile Picture
                        Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/profile/profile1.webp',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.white,
                                      child: Icon(
                                        Icons.person,
                                        color: AppColors.medicalGreen,
                                        size: 30,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(delay: 100.ms, duration: 500.ms),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                  _getGreeting(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .slideX(begin: -0.3, end: 0),
                            const SizedBox(height: 4),
                            Text(
                                  userData.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 100.ms, duration: 600.ms)
                                .slideX(begin: -0.3, end: 0),
                          ],
                        ),
                      ],
                    ),
                    Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              IconlyBold.notification,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .scale(delay: 200.ms, duration: 400.ms),
                  ],
                ),

                const SizedBox(height: 24),

                // Wellness Score Card
                Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Score Circle with pulse animation
                          Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.medicalGreen,
                                      AppColors.lightGreen,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        userData.wellnessScore.toStringAsFixed(
                                          1,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Text(
                                        '/10',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true),
                              )
                              .scale(
                                duration: 2000.ms,
                                begin: const Offset(1, 1),
                                end: const Offset(1.05, 1.05),
                              ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Wellness Score',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'You\'re doing great! Keep it up.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textGray,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                      children: [
                                        Icon(
                                          Icons.trending_up,
                                          size: 16,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '+0.5 from last week',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    )
                                    .animate()
                                    .fadeIn(delay: 600.ms)
                                    .slideX(begin: -0.2, end: 0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0)
                    .scale(delay: 300.ms, duration: 600.ms),
              ],
            ),
          ),

          // Content Section with White Background
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surfaceGray,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Cards
                  const Text(
                    'Your Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          title: 'Sessions',
                          value: monthlyStats.totalSessions.toString(),
                          subtitle: 'This month',
                          icon: IconlyBold.video,
                          color: AppColors.medicalBlue,
                          trend: '+3',
                          isPositive: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KpiCard(
                          title: 'Streak',
                          value: '${monthlyStats.streakDays}d',
                          subtitle: 'Daily check-ins',
                          icon: IconlyBold.tickSquare,
                          color: AppColors.warningOrange,
                          trend: '+2',
                          isPositive: true,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  _buildJoinSessionCard(context),

                  const SizedBox(height: 24),

                  // Weekly Mood Chart
                  WeeklyMoodChart(
                    moodScores: weeklyProgress.moodScores,
                    days: weeklyProgress.days,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  // Interactive Mood Tracker
                  const MoodTracker()
                      .animate()
                      .fadeIn(delay: 700.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2, end: 0),

                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      QuickActionCard(
                        title: 'Assessment',
                        icon: IconlyBold.paper,
                        color: AppColors.medicalBlue,
                        onTap: () => context.push('/assessment'),
                      ),
                      QuickActionCard(
                        title: 'Book Session',
                        icon: IconlyBold.video,
                        color: AppColors.medicalGreen,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'Resources',
                        icon: IconlyBold.document,
                        color: AppColors.warningOrange,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        title: 'Emergency',
                        icon: IconlyBold.shieldDone,
                        color: AppColors.errorRed,
                        onTap: () {},
                      ),
                    ],
                  ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  // Specialist Carousel
                  const SpecialistCarousel()
                      .animate()
                      .fadeIn(delay: 1000.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Container(
      color: AppColors.surfaceGray,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.medicalGreen,
            ).animate().fadeIn().scale(duration: 600.ms),
            const SizedBox(height: 16),
            Text(
              '$title Screen',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              'Coming soon...',
              style: TextStyle(fontSize: 14, color: AppColors.textGray),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: IconlyLight.home,
                activeIcon: IconlyBold.home,
                label: 'Home',
                index: 0,
                isActive: ref.watch(dashboardIndexProvider) == 0,
              ),
              _buildNavItem(
                icon: IconlyLight.search,
                activeIcon: IconlyBold.search,
                label: 'Specialists',
                index: 1,
                isActive: ref.watch(dashboardIndexProvider) == 1,
              ),
              const SizedBox(width: 60), // Space for FAB
              _buildNavItem(
                icon: IconlyLight.chat,
                activeIcon: IconlyBold.chat,
                label: 'Forum',
                index: 2,
                isActive: ref.watch(dashboardIndexProvider) == 2,
              ),
              _buildNavItem(
                icon: IconlyLight.setting,
                activeIcon: IconlyBold.setting,
                label: 'Settings',
                index: 3,
                isActive: ref.watch(dashboardIndexProvider) == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(dashboardIndexProvider.notifier).state = index;
        // Only animate FAB when nav items are clicked, not when navigating via FAB
        if (index != 2) {
          _fabAnimationController.reverse().then((_) {
            _fabAnimationController.forward();
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.medicalGreen.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.medicalGreen : AppColors.textGray,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? AppColors.medicalGreen : AppColors.textGray,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.medicalGreen,
                  shape: BoxShape.circle,
                ),
              ).animate().scale(duration: 300.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildJoinSessionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.medicalBlue, Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.medicalBlue.withOpacity(0.3),
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
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(IconlyBold.video, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Session',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dr. Sarah Smith',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Starts in 10 mins',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/session/pre-check/session_123'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.medicalBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}
