enum SessionMode { video, audio, chat }

enum SessionStatus { connecting, active, poorConnection, ended }

class SessionConfig {
  final String sessionId;
  final SessionMode initialMode;
  final bool isSpecialist;

  const SessionConfig({
    required this.sessionId,
    this.initialMode = SessionMode.video,
    this.isSpecialist = false,
  });
}

class Participant {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isMe;
  final bool isMuted;
  final bool isVideoOff;

  const Participant({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isMe = false,
    this.isMuted = false,
    this.isVideoOff = false,
  });

  Participant copyWith({bool? isMuted, bool? isVideoOff}) {
    return Participant(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      isMe: isMe,
      isMuted: isMuted ?? this.isMuted,
      isVideoOff: isVideoOff ?? this.isVideoOff,
    );
  }
}
