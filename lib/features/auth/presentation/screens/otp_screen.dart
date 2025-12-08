import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';
import '../../../../app/theme/app_colors.dart';

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
  int _start = 30;
  Timer? _timer;

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    startTimer();
    super.initState();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textBlack,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verification Code',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.medicalGreen,
                ),
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'We sent a code to your email/phone. Enter it below to verify.',
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
                onCompleted: (v) {
                  // Auto-verify when filled
                  context.push('/profile-setup');
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

              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Didn't receive the code? ",
                    style: const TextStyle(color: Colors.black54, fontSize: 15),
                    children: [
                      TextSpan(
                        text: _start > 0 ? "Resend in $_start s" : "RESEND",
                        style: TextStyle(
                          color: _start > 0
                              ? AppColors.textGray
                              : AppColors.medicalGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        // Add tap handler for resend
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
                      context.push('/profile-setup');
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
