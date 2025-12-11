import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/models/session_config.dart';
import '../providers/session_provider.dart';
import '../widgets/video_grid.dart';
import '../widgets/session_controls.dart';
import '../widgets/side_panel.dart';

class ActiveSessionScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const ActiveSessionScreen({super.key, required this.sessionId});

  @override
  ConsumerState<ActiveSessionScreen> createState() =>
      _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();

    // Initialize session (mock)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(sessionProvider.notifier)
          .initializeSession(SessionConfig(sessionId: widget.sessionId));
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionProvider);

    // Listen for session end
    ref.listen(sessionProvider, (previous, next) {
      if (next.status == SessionStatus.ended) {
        context.go('/session/post/${widget.sessionId}');
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Video Grid (Background)
          const Positioned.fill(child: VideoGrid()),

          // 2. Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // Minimize logic (mock)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Session minimized')),
                        );
                        context
                            .pop(); // Or go back to dashboard while keeping session active
                      },
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            IconlyBold.timeCircle,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDuration(state.durationSeconds),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.medicalGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ),

          // 3. Side Panel (Right)
          if (state.isSidePanelOpen)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 60,
                    bottom: 100,
                  ), // Avoid top bar and bottom controls
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                    child: const SidePanel(),
                  ),
                ),
              ),
            ),

          // 4. Bottom Controls
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SessionControls(),
          ),
        ],
      ),
    );
  }
}
