import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  // Mock state
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _remindersEnabled = true;
  bool _updatesEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        leading: const BackButton(color: AppColors.textBlack),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSwitchTile(
              title: 'Push Notifications',
              subtitle: 'Receive push notifications on your device',
              value: _pushEnabled,
              onChanged: (v) => setState(() => _pushEnabled = v),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Email Digests',
              subtitle: 'Receive weekly summary emails',
              value: _emailEnabled,
              onChanged: (v) => setState(() => _emailEnabled = v),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Session Reminders',
              subtitle: 'Get reminded before your sessions start',
              value: _remindersEnabled,
              onChanged: (v) => setState(() => _remindersEnabled = v),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Community Updates',
              subtitle: 'Stay updated with forum activity',
              value: _updatesEnabled,
              onChanged: (v) => setState(() => _updatesEnabled = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
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
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.medicalGreen,
          ),
        ],
      ),
    );
  }
}
