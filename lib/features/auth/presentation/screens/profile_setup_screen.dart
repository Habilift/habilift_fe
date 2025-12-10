import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../home/presentation/providers/dashboard_providers.dart';


class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  int _currentStep = 0;

  final List<String> _steps = ['Basic Info', 'Details', 'Goals'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile Setup',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.medicalGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(_steps.length, (index) {
                  bool isActive = index <= _currentStep;
                  return Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.medicalGreen
                                : AppColors.surfaceGray,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textGray,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (index != _steps.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: isActive
                                  ? AppColors.medicalGreen
                                  : AppColors.surfaceGray,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: FormBuilder(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentStep == 0) _buildBasicInfoStep(),
                      if (_currentStep == 1) _buildDetailsStep(),
                      if (_currentStep == 2) _buildGoalsStep(),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.medicalGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.medicalGreen,
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          if (_currentStep < _steps.length - 1) {
                            setState(() {
                              _currentStep++;
                            });
                          } else {
                            // Complete setup - Save to database
                            final formData = _formKey.currentState!.value;
                            final profileRepo = ref.read(profileRepositoryProvider);
                            
                            try {
                              // Prepare profile data
                              final profileUpdates = {
                                'name': formData['full_name'],
                                'gender': formData['gender'],
                                'age_range': formData['age_range'],
                                'country': formData['country'],
                                'preferred_language': formData['preferred_language'],
                                'goals': formData['goals'] ?? [],
                                'updated_at': DateTime.now().toIso8601String(),
                              };
                              
                              // Save to database
                              await profileRepo.updateProfile(profileUpdates);
                              
                              // Navigate to dashboard
                              if (context.mounted) {
                                context.go('/dashboard');
                              }
                            } catch (e) {
                              // Show error
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error saving profile: $e'),
                                    backgroundColor: AppColors.errorRed,
                                  ),
                                );
                              }
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
                      child: Text(
                        _currentStep == _steps.length - 1
                            ? 'Complete Setup'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us about yourself',
          style: Theme.of(context).textTheme.headlineMedium,
        ).animate().fadeIn(),
        const SizedBox(height: 24),
        FormBuilderTextField(
          name: 'full_name',
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(IconlyLight.profile),
          ),
          validator: FormBuilderValidators.required(),
        ),
        const SizedBox(height: 16),
        FormBuilderDropdown(
          name: 'gender',
          decoration: const InputDecoration(
            labelText: 'Gender',
            prefixIcon: Icon(IconlyLight.user2),
          ),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Male')),
            DropdownMenuItem(value: 'female', child: Text('Female')),
            DropdownMenuItem(value: 'non-binary', child: Text('Non-binary')),
            DropdownMenuItem(value: 'prefer_not_to_say', child: Text('Prefer not to say')),
          ],
          validator: FormBuilderValidators.required(),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A few more details',
          style: Theme.of(context).textTheme.headlineMedium,
        ).animate().fadeIn(),
        const SizedBox(height: 24),
        FormBuilderDropdown(
          name: 'age_range',
          decoration: const InputDecoration(
            labelText: 'Age Range',
            prefixIcon: Icon(IconlyLight.calendar),
          ),
          items: ['13-17', '18-24', '25-34', '35-44', '45-54', '55-64', '65+']
              .map(
                (range) => DropdownMenuItem(value: range, child: Text(range)),
              )
              .toList(),
          validator: FormBuilderValidators.required(),
        ),
        const SizedBox(height: 16),
        FormBuilderDropdown(
          name: 'preferred_language',
          decoration: const InputDecoration(
            labelText: 'Preferred Language',
            prefixIcon: Icon(IconlyLight.chat),
          ),
          items:
              [
                    'English',
                    'French',
                    'Pidgin English',
                    'Hausa',
                    'Yoruba',
                    'Igbo',
                    'Other',
                  ]
                  .map(
                    (lang) => DropdownMenuItem(value: lang, child: Text(lang)),
                  )
                  .toList(),
          validator: FormBuilderValidators.required(),
        ),
        const SizedBox(height: 16),
        FormBuilderDropdown(
          name: 'country',
          decoration: const InputDecoration(
            labelText: 'Country',
            prefixIcon: Icon(IconlyLight.location),
          ),
          items: ['Cameroon', 'Nigeria', 'Ghana', 'Kenya', 'South Africa']
              .map(
                (country) =>
                    DropdownMenuItem(value: country, child: Text(country)),
              )
              .toList(),
          validator: FormBuilderValidators.required(),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildGoalsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What brings you here?',
          style: Theme.of(context).textTheme.headlineMedium,
        ).animate().fadeIn(),
        const SizedBox(height: 24),
        FormBuilderCheckboxGroup<String>(
          name: 'goals',
          decoration: const InputDecoration(
            labelText: 'Select your primary goals',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          options: const [
            FormBuilderFieldOption(value: 'Mental health assessment'),
            FormBuilderFieldOption(value: 'Talk to a specialist'),
            FormBuilderFieldOption(value: 'Learn about special needs'),
            FormBuilderFieldOption(value: 'Parenting guidance'),
            FormBuilderFieldOption(value: 'Emotional support'),
          ],
          validator: FormBuilderValidators.required(),
        ),
      ],
    ).animate().fadeIn();
  }
}
