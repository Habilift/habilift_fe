import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/session_config.dart';
import '../../data/models/chat_message.dart';

class SessionState {
  final SessionStatus status;
  final SessionMode mode;
  final bool isMicEnabled;
  final bool isCameraEnabled;
  final List<Participant> participants;
  final List<ChatMessage> messages;
  final bool isSidePanelOpen;
  final int activeSidePanelTab; // 0: Notes, 1: Chat, 2: Info
  final CameraController? cameraController;
  final String notes;
  final int durationSeconds;

  const SessionState({
    this.status = SessionStatus.connecting,
    this.mode = SessionMode.video,
    this.isMicEnabled = true,
    this.isCameraEnabled = true,
    this.participants = const [],
    this.messages = const [],
    this.isSidePanelOpen = false,
    this.activeSidePanelTab = 1, // Default to Chat
    this.cameraController,
    this.notes = '',
    this.durationSeconds = 0,
  });

  SessionState copyWith({
    SessionStatus? status,
    SessionMode? mode,
    bool? isMicEnabled,
    bool? isCameraEnabled,
    List<Participant>? participants,
    List<ChatMessage>? messages,
    bool? isSidePanelOpen,
    int? activeSidePanelTab,
    CameraController? cameraController,
    String? notes,
    int? durationSeconds,
  }) {
    return SessionState(
      status: status ?? this.status,
      mode: mode ?? this.mode,
      isMicEnabled: isMicEnabled ?? this.isMicEnabled,
      isCameraEnabled: isCameraEnabled ?? this.isCameraEnabled,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      isSidePanelOpen: isSidePanelOpen ?? this.isSidePanelOpen,
      activeSidePanelTab: activeSidePanelTab ?? this.activeSidePanelTab,
      cameraController: cameraController ?? this.cameraController,
      notes: notes ?? this.notes,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  Timer? _timer;

  SessionNotifier() : super(const SessionState());

  @override
  void dispose() {
    _timer?.cancel();
    state.cameraController?.dispose();
    super.dispose();
  }

  void initializeSession(SessionConfig config) {
    // Mock initialization
    state = state.copyWith(
      status: SessionStatus.active,
      mode: config.initialMode,
      participants: [
        const Participant(id: '1', name: 'Me', isMe: true),
        const Participant(id: '2', name: 'Dr. Smith', isMe: false),
      ],
    );
    startTimer();
  }

  void setCameraController(CameraController controller) {
    state = state.copyWith(cameraController: controller);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(durationSeconds: state.durationSeconds + 1);
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void toggleMic() {
    state = state.copyWith(isMicEnabled: !state.isMicEnabled);
    // Update "Me" participant status
    _updateMyStatus(isMuted: !state.isMicEnabled);
  }

  void toggleCamera() {
    state = state.copyWith(isCameraEnabled: !state.isCameraEnabled);
    // Update "Me" participant status
    _updateMyStatus(isVideoOff: !state.isCameraEnabled);
  }

  void _updateMyStatus({bool? isMuted, bool? isVideoOff}) {
    final updatedParticipants = state.participants.map((p) {
      if (p.isMe) {
        return p.copyWith(isMuted: isMuted, isVideoOff: isVideoOff);
      }
      return p;
    }).toList();
    state = state.copyWith(participants: updatedParticipants);
  }

  void toggleSidePanel() {
    state = state.copyWith(isSidePanelOpen: !state.isSidePanelOpen);
  }

  void setActiveTab(int index) {
    state = state.copyWith(activeSidePanelTab: index);
  }

  void sendMessage(String text) {
    final newMessage = ChatMessage(
      id: DateTime.now().toString(),
      senderId: '1',
      senderName: 'Me',
      text: text,
      timestamp: DateTime.now(),
      isMe: true,
    );
    state = state.copyWith(messages: [...state.messages, newMessage]);
  }

  void endSession() {
    stopTimer();
    state = state.copyWith(status: SessionStatus.ended);
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((
  ref,
) {
  return SessionNotifier();
});
