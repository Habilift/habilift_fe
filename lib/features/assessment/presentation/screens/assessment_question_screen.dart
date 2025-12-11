import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/assessment_provider.dart';
import '../widgets/assessment_progress_bar.dart';

class AssessmentQuestionScreen extends ConsumerWidget {
  const AssessmentQuestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assessmentProvider);
    final notifier = ref.read(assessmentProvider.notifier);
    final question = state.questions[state.currentQuestionIndex];

    // Check if we have a result, if so, navigate to result screen
    ref.listen(assessmentProvider, (previous, next) {
      if (next.result != null && previous?.result == null) {
        context.replace('/assessment/result');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textBlack),
          onPressed: () {
            if (state.currentQuestionIndex > 0) {
              notifier.previousQuestion();
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          'Question ${state.currentQuestionIndex + 1}/${state.totalQuestions}',
          style: AppTypography.lightTextTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AssessmentProgressBar(progress: state.progress),
            const SizedBox(height: 40),
            Text(
              question.text,
              style: AppTypography.lightTextTheme.headlineMedium?.copyWith(
                height: 1.3,
              ),
            ).animate(key: ValueKey(question.id)).fadeIn().slideX(),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  final isSelected = state.answers[question.id] == option.score;

                  return InkWell(
                        onTap: () {
                          notifier.answerQuestion(question.id, option.score);
                          Future.delayed(const Duration(milliseconds: 300), () {
                            notifier.nextQuestion();
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.medicalGreen.withOpacity(0.1)
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.medicalGreen
                                  : AppColors.divider,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: AppTypography.lightTextTheme.bodyLarge
                                      ?.copyWith(
                                        color: isSelected
                                            ? AppColors.medicalGreen
                                            : AppColors.textBlack,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  IconlyBold.tickSquare,
                                  color: AppColors.medicalGreen,
                                )
                              else
                                const Icon(
                                  IconlyLight.tickSquare,
                                  color: AppColors.textGray,
                                ),
                            ],
                          ),
                        ),
                      )
                      .animate(delay: (index * 100).ms)
                      .fadeIn()
                      .slideY(begin: 0.2);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
