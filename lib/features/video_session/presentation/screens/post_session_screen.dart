import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // We might need to add this dependency or build custom
import '../../../../app/theme/app_theme.dart';

class PostSessionScreen extends StatefulWidget {
  final String sessionId;

  const PostSessionScreen({super.key, required this.sessionId});

  @override
  State<PostSessionScreen> createState() => _PostSessionScreenState();
}

class _PostSessionScreenState extends State<PostSessionScreen> {
  double _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textBlack),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Session Summary',
          style: AppTypography.lightTextTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.medicalGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                IconlyBold.tickSquare,
                size: 64,
                color: AppColors.medicalGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Session Completed',
              style: AppTypography.lightTextTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: 45:00', // Mock duration
              style: AppTypography.lightTextTheme.bodyLarge?.copyWith(
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 40),

            // Rating
            Text(
              'How was your session?',
              style: AppTypography.lightTextTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? IconlyBold.star : IconlyLight.star,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 32),

            // Feedback Input
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your feedback (optional)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                filled: true,
                fillColor: AppColors.surfaceGray,
              ),
            ),

            const SizedBox(height: 32),

            // Next Steps Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        IconlyBold.calendar,
                        color: AppColors.medicalBlue,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Next Steps',
                        style: AppTypography.lightTextTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your specialist recommends scheduling a follow-up session in 2 weeks.',
                    style: AppTypography.lightTextTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to booking
                        context.push('/booking');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.medicalBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Schedule Next Appointment'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Done Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.medicalGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
