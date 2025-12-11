import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';

class TermsPrivacyScreen extends ConsumerWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surfaceGray,
        appBar: AppBar(
          title: const Text('Legal'),
          backgroundColor: Colors.white,
          leading: const BackButton(color: AppColors.textBlack),
          bottom: const TabBar(
            labelColor: AppColors.medicalGreen,
            unselectedLabelColor: AppColors.textGray,
            indicatorColor: AppColors.medicalGreen,
            tabs: [
              Tab(text: 'Terms'),
              Tab(text: 'Privacy'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PolicyView(
              title: 'Terms of Service',
              content: '''
1. Acceptance of Terms
By accessing and using HabiLift, you accept and agree to be bound by the terms and provision of this agreement.

2. Description of Service
HabiLift provides users with habit tracking and mental wellness tools. You understand and agree that the Service is provided "AS-IS".

3. User Conduct
You agree to use the service in compliance with all applicable local, state, national, and international laws, rules and regulations.

4. Privacy Policy
Your use of the Service is also governed by our Privacy Policy.

5. Modifications to Service
HabiLift reserves the right to modify or discontinue, temporarily or permanently, the Service (or any part thereof) with or without notice.

6. Termination
You agree that HabiLift may, under certain circumstances and without prior notice, immediately terminate your account.
              ''',
            ),
            _PolicyView(
              title: 'Privacy Policy',
              content: '''
1. Information Collection
We collect information you provide directly to us, such as when you create or modify your account.

2. Use of Information
We use the information we collect to provide, maintain, and improve our services, to develop new ones, and to protect HabiLift and our users.

3. Sharing of Information
We do not share your personal information with companies, organizations, or individuals outside of HabiLift except in specific circumstances.

4. Data Security
We work hard to protect HabiLift and our users from unauthorized access to or unauthorized alteration, disclosure, or destruction of information we hold.

5. Changes
Our Privacy Policy may change from time to time. We will post any privacy policy changes on this page.
              ''',
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyView extends StatelessWidget {
  final String title;
  final String content;

  const _PolicyView({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
