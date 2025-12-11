import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/session_provider.dart';

class SessionControls extends ConsumerWidget {
  const SessionControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionProvider);
    final notifier = ref.read(sessionProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Mic Toggle
            _buildControlButton(
              icon: state.isMicEnabled ? IconlyBold.voice : IconlyBold.voice2,
              isActive: state.isMicEnabled,
              onTap: notifier.toggleMic,
              activeColor: Colors.white,
              inactiveColor: Colors.white,
              backgroundColor: state.isMicEnabled
                  ? Colors.white.withOpacity(0.2)
                  : Colors.red,
            ),

            // Camera Toggle
            _buildControlButton(
              icon: state.isCameraEnabled
                  ? IconlyBold.video
                  : IconlyBold.video, // Iconly doesn't have video off?
              isActive: state.isCameraEnabled,
              onTap: notifier.toggleCamera,
              activeColor: Colors.white,
              inactiveColor: Colors.white,
              backgroundColor: state.isCameraEnabled
                  ? Colors.white.withOpacity(0.2)
                  : Colors.red,
            ),

            // End Call
            _buildControlButton(
              icon: IconlyBold
                  .callMissed, // Using call missed as end call icon proxy
              isActive: true,
              onTap: () {
                if (state.durationSeconds < 360) {
                  final remaining = 360 - state.durationSeconds;
                  final minutes = remaining ~/ 60;
                  final seconds = remaining % 60;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Session must last at least 6 minutes. '
                        'Please wait ${minutes}m ${seconds}s.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  notifier.endSession();
                }
              },
              activeColor: Colors.white,
              backgroundColor: Colors.red,
              size: 64,
            ),

            // Chat Toggle
            _buildControlButton(
              icon: IconlyBold.chat,
              isActive: state.isSidePanelOpen && state.activeSidePanelTab == 1,
              onTap: () {
                if (!state.isSidePanelOpen) {
                  notifier.toggleSidePanel();
                }
                notifier.setActiveTab(1); // Chat tab
              },
              activeColor:
                  state.isSidePanelOpen && state.activeSidePanelTab == 1
                  ? AppColors.medicalBlue
                  : Colors.white,
              backgroundColor: Colors.white.withOpacity(0.2),
            ),

            // Notes Toggle (Specialist/Educator only usually, but allowed for all per requirements)
            _buildControlButton(
              icon: IconlyBold.paper,
              isActive: state.isSidePanelOpen && state.activeSidePanelTab == 0,
              onTap: () {
                if (!state.isSidePanelOpen) {
                  notifier.toggleSidePanel();
                }
                notifier.setActiveTab(0); // Notes tab
              },
              activeColor:
                  state.isSidePanelOpen && state.activeSidePanelTab == 0
                  ? AppColors.medicalBlue
                  : Colors.white,
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    Color activeColor = Colors.white,
    Color inactiveColor = Colors.white,
    Color backgroundColor = Colors.transparent,
    double size = 48,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? activeColor : inactiveColor,
          size: size * 0.5,
        ),
      ),
    );
  }
}
