import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isEmail = true;

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo/logo.png',
                height: 80,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.health_and_safety,
                  size: 80,
                  color: AppColors.medicalGreen,
                ),
              ).animate().fadeIn().scale(duration: 500.ms),

              const SizedBox(height: 24),

              Text(
                'Let\'s get you started',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.medicalGreen,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'Create an account or log in to continue.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textGray),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 32),

              // Toggle Switch
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isEmail = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isEmail ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _isEmail
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'Email',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isEmail
                                    ? AppColors.medicalGreen
                                    : AppColors.textGray,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isEmail = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isEmail
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: !_isEmail
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'Phone Number',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: !_isEmail
                                    ? AppColors.medicalGreen
                                    : AppColors.textGray,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 32),

              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    if (_isEmail)
                      FormBuilderTextField(
                        name: 'email',
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(IconlyLight.message),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                      ).animate().fadeIn()
                    else
                      FormBuilderTextField(
                        name: 'phone',
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(IconlyLight.call),
                          prefixText: '+237 ',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric(),
                        ]),
                      ).animate().fadeIn(),

                    const SizedBox(height: 16),

                    // Password field
                    FormBuilderTextField(
                      name: 'password',
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(IconlyLight.lock),
                        hintText: 'Enter your password',
                      ),
                      obscureText: true,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(
                          6,
                          errorText: 'Password must be at least 6 characters',
                        ),
                      ]),
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 16),

                    // Confirm Password field
                    FormBuilderTextField(
                      name: 'confirm_password',
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(IconlyLight.lock),
                        hintText: 'Re-enter your password',
                      ),
                      obscureText: true,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        (val) {
                          if (val !=
                              _formKey
                                  .currentState
                                  ?.fields['password']
                                  ?.value) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ]),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.saveAndValidate() ??
                              false) {
                            final formData = _formKey.currentState!.value;
                            final authRepo = ref.read(authRepositoryProvider);
                            try {
                              if (_isEmail) {
                                // Sign up with email and password
                                await authRepo.signUpWithEmail(
                                  formData['email'],
                                  formData['password'],
                                );
                                
                                // Send OTP to email for verification
                                await authRepo.sendEmailOTP(formData['email']);
                                
                                // Navigate to OTP screen with email
                                context.push('/otp', extra: {
                                  'emailOrPhone': formData['email'],
                                  'isEmail': true,
                                });
                              } else {
                                // Send OTP to phone
                                await authRepo.signInWithOtp(
                                  formData['phone'],
                                );
                                
                                // Navigate to OTP screen with phone
                                context.push('/otp', extra: {
                                  'emailOrPhone': formData['phone'],
                                  'isEmail': false,
                                });
                              }
                            } catch (e) {
                              // Handle error, e.g., show snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 32),

              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Or continue with',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textGray,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SocialButton(
                    icon: 'assets/icons/google.png',
                    label: 'Google',
                    onTap: () {
                      // TODO: Implement Google Sign In
                    },
                  ),
                  _SocialButton(
                    icon: 'assets/icons/apple.png',
                    label: 'Apple',
                    onTap: () {
                      // TODO: Implement Apple Sign In
                    },
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 32),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => context.push('/login'),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: AppColors.medicalGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              icon,
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.login, size: 24, color: AppColors.textGray),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
