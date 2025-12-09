import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:noise_meter/noise_meter.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/models/session_config.dart';
import '../providers/session_provider.dart';

class PreSessionCheckScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const PreSessionCheckScreen({super.key, required this.sessionId});

  @override
  ConsumerState<PreSessionCheckScreen> createState() =>
      _PreSessionCheckScreenState();
}

class _PreSessionCheckScreenState extends ConsumerState<PreSessionCheckScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isMicPermissionGranted = false;
  bool _consentGiven = false;
  SessionMode _selectedMode = SessionMode.video;
  bool _isJoining = false;

  // Mic level
  double _micLevel = 0.0;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? _noiseMeter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePermissionsAndCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopListening();
    if (!_isJoining) {
      _cameraController?.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializePermissionsAndCamera() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses[Permission.microphone] == PermissionStatus.granted) {
      setState(() {
        _isMicPermissionGranted = true;
      });
      _startListening();
    }

    if (statuses[Permission.camera] == PermissionStatus.granted) {
      _initializeCamera();
    }
  }

  void _startListening() {
    try {
      _noiseMeter ??= NoiseMeter();
      _noiseSubscription = _noiseMeter?.noise.listen(
        (NoiseReading noiseReading) {
          if (mounted) {
            setState(() {
              // Normalize dB to 0.0 - 1.0 range for the progress bar
              // Assuming typical range 30dB (silence) to 90dB (loud)
              double db = noiseReading.meanDecibel;
              _micLevel = ((db - 30) / 60).clamp(0.0, 1.0);
            });
          }
        },
        onError: (Object error) {
          debugPrint('NoiseMeter Error: $error');
        },
      );
    } catch (e) {
      debugPrint('Error starting noise meter: $e');
    }
  }

  void _stopListening() {
    _noiseSubscription?.cancel();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Use the first front camera if available, otherwise first camera
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false, // We handle audio separately or via WebRTC later
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _joinSession() {
    if (_consentGiven) {
      setState(() {
        _isJoining = true;
      });

      // Pass camera controller to provider if initialized
      if (_cameraController != null && _isCameraInitialized) {
        ref
            .read(sessionProvider.notifier)
            .setCameraController(_cameraController!);
      }

      // Navigate to active session
      context.go('/session/active/${widget.sessionId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textBlack),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              'Pre-Session Check',
              style: AppTypography.lightTextTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'with Dr. Sarah Chen • 10:00 AM', // TODO: Fetch real data
              style: AppTypography.lightTextTheme.bodyMedium?.copyWith(
                color: AppColors.textGray,
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Help?',
              style: TextStyle(color: AppColors.medicalBlue),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Camera Preview Section
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_isCameraInitialized &&
                      _selectedMode == SessionMode.video)
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _cameraController!.value.previewSize!.height,
                        height: _cameraController!.value.previewSize!.width,
                        child: CameraPreview(_cameraController!),
                      ),
                    )
                  else
                    Container(
                      color: AppColors.surfaceGray,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedMode == SessionMode.audio
                                ? IconlyBold.voice
                                : IconlyBold.chat,
                            size: 64,
                            color: AppColors.textGray,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedMode == SessionMode.video
                                ? 'Camera Off'
                                : _selectedMode == SessionMode.audio
                                ? 'Audio Only Mode'
                                : 'Chat Only Mode',
                            style: AppTypography.lightTextTheme.bodyLarge
                                ?.copyWith(color: AppColors.textGray),
                          ),
                        ],
                      ),
                    ),

                  // Overlays
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Mic Meter
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isMicPermissionGranted
                                    ? IconlyBold.voice
                                    : IconlyBold.voice2,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 60,
                                height: 4,
                                child: LinearProgressIndicator(
                                  value: _micLevel,
                                  backgroundColor: Colors.white24,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        AppColors.medicalGreen,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Network Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                IconlyBold.graph,
                                color: AppColors.medicalGreen,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Excellent',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Mode Selection
            Text('Select Mode', style: AppTypography.lightTextTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildModeOption(
                  mode: SessionMode.video,
                  icon: IconlyBold.video,
                  label: 'Video',
                ),
                const SizedBox(width: 12),
                _buildModeOption(
                  mode: SessionMode.audio,
                  icon: IconlyBold.voice,
                  label: 'Audio',
                ),
                const SizedBox(width: 12),
                _buildModeOption(
                  mode: SessionMode.chat,
                  icon: IconlyBold.chat,
                  label: 'Chat',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Consent Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.infoBlue.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _consentGiven,
                      onChanged: (value) {
                        setState(() {
                          _consentGiven = value ?? false;
                        });
                      },
                      activeColor: AppColors.medicalBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'I agree to HabiLift’s tele-consultation guidelines.',
                          style: AppTypography.lightTextTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textBlack,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'I understand crisis emergencies should not rely on this platform.',
                          style: AppTypography.lightTextTheme.bodyMedium
                              ?.copyWith(color: AppColors.textGray),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Join Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _consentGiven ? _joinSession : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.medicalGreen,
                  disabledBackgroundColor: AppColors.textGray.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Join Session',
                  style: AppTypography.lightTextTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption({
    required SessionMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMode = mode;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.medicalBlue : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.medicalBlue : AppColors.divider,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.medicalBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.textGray),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.lightTextTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.white : AppColors.textGray,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
