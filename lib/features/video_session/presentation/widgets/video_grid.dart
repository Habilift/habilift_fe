import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:camera/camera.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/models/session_config.dart';
import '../providers/session_provider.dart';

class VideoGrid extends ConsumerWidget {
  const VideoGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participants = ref.watch(
      sessionProvider.select((s) => s.participants),
    );
    final state = ref.watch(sessionProvider);

    // For now, we assume 1-on-1 session: 1 remote, 1 local (me)
    final remoteParticipant = participants.firstWhere(
      (p) => !p.isMe,
      orElse: () =>
          const Participant(id: 'remote', name: 'Waiting...', isMe: false),
    );

    final localParticipant = participants.firstWhere(
      (p) => p.isMe,
      orElse: () => const Participant(id: 'local', name: 'Me', isMe: true),
    );

    return Stack(
      children: [
        // Main Tile (Remote Participant)
        Container(
          color: AppColors.textBlack,
          width: double.infinity,
          height: double.infinity,
          child: remoteParticipant.isVideoOff
              ? _buildAvatarPlaceholder(remoteParticipant)
              : _buildMockVideoFeed(remoteParticipant),
        ),

        // Draggable Self-View (Local Participant)
        Positioned(
          right: 16,
          bottom: 100, // Above control bar
          child: Draggable(
            feedback: _buildSelfView(localParticipant, state, isDragging: true),
            childWhenDragging: Container(),
            child: _buildSelfView(localParticipant, state),
          ),
        ),
      ],
    );
  }

  Widget _buildSelfView(
    Participant participant,
    SessionState state, {
    bool isDragging = false,
  }) {
    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          participant.isVideoOff
              ? Container(
                  color: AppColors.surfaceGray,
                  child: const Center(
                    child: Icon(IconlyBold.profile, color: AppColors.textGray),
                  ),
                )
              : (state.cameraController != null &&
                    state.cameraController!.value.isInitialized)
              ? _buildCameraPreview(state.cameraController!)
              : _buildMockVideoFeed(participant, isSelf: true),

          if (participant.isMuted)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  IconlyBold.voice2,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(Participant participant) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.surfaceGray,
            child: Text(
              participant.name[0].toUpperCase(),
              style: const TextStyle(fontSize: 32, color: AppColors.textBlack),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            participant.name,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Camera Off',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMockVideoFeed(Participant participant, {bool isSelf = false}) {
    // In a real app, this would be a Texture widget from flutter_webrtc or camera
    if (isSelf) {
      // For self, we'd ideally show the camera again, but for now we'll keep the icon
      // or we could pass the camera controller down if we wanted to be fancy.
      return Container(
        color: Colors.grey[800],
        child: Center(
          child: Icon(
            Icons.videocam,
            color: Colors.white.withOpacity(0.1),
            size: 32,
          ),
        ),
      );
    } else {
      // For remote (Specialist), show the asset image
      return Image.asset(
        'assets/video_screen_img/specialist.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[900],
            child: Center(
              child: Icon(
                Icons.videocam,
                color: Colors.white.withOpacity(0.1),
                size: 64,
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildCameraPreview(CameraController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedOverflowBox(
        size: const Size(120, 160),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.previewSize!.height,
            height: controller.value.previewSize!.width,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}
