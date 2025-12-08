import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      image: 'assets/images/onboardings/onboard1.png',
      title: 'Welcome to HabiLift',
      description:
          'Your companion for mental wellness and inclusive education support.',
    ),
    OnboardingContent(
      image: 'assets/images/onboardings/onboard2.png', // User added this
      title: 'Expert Support',
      description:
          'Connect with licensed psychologists, special educators, and counselors.',
    ),
    OnboardingContent(
      image: 'assets/images/onboardings/onboard3.png',
      title: 'Safe & Private',
      description:
          'A secure space for you to heal, learn, and grow at your own pace.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image container - full width, no padding, no top space
                      Container(
                            height: MediaQuery.of(context).size.height * 0.52,
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.58,
                              minHeight: 280,
                            ),
                            child: Stack(
                              children: [
                                // Main image with cover fit
                                Positioned.fill(
                                  child: Image.asset(
                                    _contents[index].image,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                  ),
                                ),
                                // Extremely aggressive gradient to completely hide image outline
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        center: Alignment.center,
                                        radius: 0.65,
                                        colors: [
                                          Colors.transparent,
                                          Colors.transparent,
                                          Colors.white.withValues(alpha: 0.1),
                                          Colors.white.withValues(alpha: 0.25),
                                          Colors.white.withValues(alpha: 0.4),
                                          Colors.white.withValues(alpha: 0.55),
                                          Colors.white.withValues(alpha: 0.7),
                                          Colors.white.withValues(alpha: 0.85),
                                          Colors.white.withValues(alpha: 0.95),
                                          Colors.white,
                                        ],
                                        stops: const [
                                          0.0,
                                          0.2,
                                          0.35,
                                          0.48,
                                          0.58,
                                          0.67,
                                          0.75,
                                          0.83,
                                          0.92,
                                          1.0,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Additional bottom gradient to close bottom edge
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.center,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withValues(alpha: 0.3),
                                          Colors.white.withValues(alpha: 0.7),
                                          Colors.white,
                                        ],
                                        stops: const [0.0, 0.7, 0.9, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .scale(duration: 500.ms, curve: Curves.easeOut)
                          .fadeIn(duration: 400.ms),
                      const SizedBox(height: 40),
                      // Title with padding
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.06,
                        ),
                        child: Text(
                          _contents[index].title,
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                color: AppColors.medicalGreen,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                      ),
                      const SizedBox(height: 16),
                      // Description with padding
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.1,
                        ),
                        child:
                            Text(
                                  _contents[index].description,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: AppColors.textGray,
                                        height: 1.5,
                                        fontSize: 16,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                )
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .slideY(begin: 0.2, end: 0),
                      ),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
              child: Column(
                children: [
                  // Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _contents.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.medicalGreen
                              : AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Buttons
                  Row(
                    children: [
                      if (_currentPage != _contents.length - 1)
                        TextButton(
                          onPressed: () {
                            context.go('/user-type'); // Skip to user type
                          },
                          child: Text(
                            'Skip',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: AppColors.textGray),
                          ),
                        ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _contents.length - 1) {
                            context.push(
                              '/mission',
                            ); // Go to mission screen first
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.medicalGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: Text(
                          _currentPage == _contents.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent {
  final String image;
  final String title;
  final String description;

  OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}
