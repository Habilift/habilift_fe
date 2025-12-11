import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';
import '../../../../app/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  bool hasError = false;
  String currentText = "";
  int _start = 300; // 5 minutes (300 seconds) - matches Supabase OTP expiration
  Timer? _timer;
  bool _isResending = false;

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    startTimer();
    super.initState();
  }

  void startTimer() {
    _start = 300; // Reset to 5 minutes
    const oneSec = Duration(seconds: 1);
    _timer?.cancel(); // Cancel existing timer if any
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    errorController?.close();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get email or phone from navigation
    final routeExtra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final emailOrPhone = routeExtra?['emailOrPhone'] ?? 'your email';
    final isEmail = routeExtra?['isEmail'] ?? true;
    final userType = routeExtra?['userType'] ?? 'individual';
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textBlack),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Verification Code',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'We sent a code to ${isEmail ? emailOrPhone : '+237$emailOrPhone'}. Enter it below to verify.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textGray),
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 48),

              PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                  inactiveFillColor: AppColors.surfaceGray,
                  selectedFillColor: Colors.white,
                  activeColor: AppColors.medicalGreen,
                  inactiveColor: Colors.transparent,
                  selectedColor: AppColors.medicalBlue,
                ),
                animationDuration: const Duration(milliseconds: 300),
                backgroundColor: Colors.transparent,
                enableActiveFill: true,
                errorAnimationController: errorController,
                controller: textEditingController,
                onCompleted: (v) async {
                  // Auto-verify when filled
                  final authRepo = ref.read(authRepositoryProvider);
                  try {
                    // Use the actual email or phone from navigation
                    await authRepo.verifyOtp(emailOrPhone, v);
                    
                    if (context.mounted) {
                      context.push('/profile-setup?userType=$userType');
                    }
                  } catch (e) {
                    errorController!.add(ErrorAnimationType.shake);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid OTP. Please try again.')),
                      );
                    }
                  }
                },
                onChanged: (value) {
                  setState(() {
                    currentText = value;
                  });
                },
                beforeTextPaste: (text) {
                  return true;
                },
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 24),

              // Resend OTP section
              Center(
                child: _isResending
                    ? const CircularProgressIndicator()
                    : RichText(
                        text: TextSpan(
                          text: "Didn't receive the code? ",
                          style: const TextStyle(color: Colors.black54, fontSize: 15),
                          children: [
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: _start == 0 ? () async {
                                  setState(() {
                                    _isResending = true;
                                  });
                                  
                                  try {
                                    final authRepo = ref.read(authRepositoryProvider);
                                    
                                    // Resend OTP
                                    if (isEmail) {
                                      await authRepo.sendEmailOTP(emailOrPhone);
                                    } else {
                                      await authRepo.signInWithOtp(emailOrPhone);
                                    }
                                    
                                    // Restart timer
                                    startTimer();
                                    
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('OTP sent successfully!'),
                                          backgroundColor: AppColors.medicalGreen,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error sending OTP: $e'),
                                          backgroundColor: AppColors.errorRed,
                                        ),
                                      );
                                    }
                                  } finally {
                                    setState(() {
                                      _isResending = false;
                                    });
                                  }
                                } : null,
                                child: Text(
                                  _start > 0 
                                      ? "Resend in ${_start ~/ 60}:${(_start % 60).toString().padLeft(2, '0')}" 
                                      : "RESEND",
                                  style: TextStyle(
                                    color: _start > 0
                                        ? AppColors.textGray
                                        : AppColors.medicalGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    decoration: _start == 0 ? TextDecoration.underline : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (currentText.length == 6) {
                      context.push('/profile-setup?userType=$userType');
                    } else {
                      errorController!.add(ErrorAnimationType.shake);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
