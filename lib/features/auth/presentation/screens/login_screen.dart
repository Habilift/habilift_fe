import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../../app/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;

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
          onPressed: () => context.go('/user-type'),
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
                'Welcome Back',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.medicalGreen,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),

              const SizedBox(height: 8),

              Text(
                'Log in to your account to continue.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textGray),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),

              const SizedBox(height: 40),

              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    // Email or Phone field
                    FormBuilderTextField(
                      name: 'email_or_phone',
                      decoration: const InputDecoration(
                        labelText: 'Email or Phone Number',
                        hintText: 'Enter your email or phone number',
                        prefixIcon: Icon(IconlyLight.message),
                      ),
                      validator: FormBuilderValidators.required(),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 16),

                    // Password field
                    FormBuilderTextField(
                      name: 'password',
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(IconlyLight.lock),
                      ),
                      obscureText: true,
                      validator: FormBuilderValidators.required(),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 8),

                    // Forgot password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.medicalGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms),

                    const SizedBox(height: 16),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.saveAndValidate() ?? false) {
                            final formData = _formKey.currentState!.value;
                            final authRepo = ref.read(authRepositoryProvider);
                            
                            // Validate email/phone and password are not null
                            final emailOrPhone = formData['email_or_phone'] as String?;
                            final password = formData['password'] as String?;
                            
                            if (emailOrPhone == null || emailOrPhone.isEmpty || password == null || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter both email/phone and password'),
                                  backgroundColor: AppColors.errorRed,
                                ),
                              );
                              return;
                            }
                            
                            try {
                              // Show loading indicator
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                              
                              // Authenticate user with Supabase
                              await authRepo.signInWithEmail(emailOrPhone, password);
                              
                              // Close loading dialog
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                
                                // Navigate to dashboard
                                context.go('/dashboard');
                              }
                            } catch (e) {
                              // Close loading dialog
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                
                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Login failed: ${e.toString()}'),
                                    backgroundColor: AppColors.errorRed,
                                  ),
                                );
                              }
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
                          'Log In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Divider
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
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 24),

              // Social auth buttons
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
              ).animate().fadeIn(delay: 800.ms),

              const SizedBox(height: 32),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => context.push('/auth'),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppColors.medicalGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 900.ms),
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
