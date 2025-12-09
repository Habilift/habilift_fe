import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/assessment_question.dart';
import '../../data/models/assessment_result.dart';
import '../../data/repositories/assessment_repository.dart';

// Repository Provider
final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  return AssessmentRepository();
});

// State for the Assessment Flow
class AssessmentState {
  final int currentQuestionIndex;
  final List<AssessmentQuestion> questions;
  final Map<String, int> answers; // Question ID -> Score
  final AssessmentResult? result;

  AssessmentState({
    this.currentQuestionIndex = 0,
    required this.questions,
    this.answers = const {},
    this.result,
  });

  AssessmentState copyWith({
    int? currentQuestionIndex,
    List<AssessmentQuestion>? questions,
    Map<String, int>? answers,
    AssessmentResult? result,
  }) {
    return AssessmentState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      result: result ?? this.result,
    );
  }

  int get totalQuestions => questions.length;
  double get progress => (currentQuestionIndex + 1) / totalQuestions;
}

class AssessmentNotifier extends StateNotifier<AssessmentState> {
  final AssessmentRepository _repository;

  AssessmentNotifier(this._repository)
    : super(AssessmentState(questions: _repository.getQuestions()));

  void answerQuestion(String questionId, int score) {
    final newAnswers = Map<String, int>.from(state.answers);
    newAnswers[questionId] = score;

    state = state.copyWith(answers: newAnswers);
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    } else {
      _calculateResult();
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  void _calculateResult() {
    int totalScore = state.answers.values.fold(0, (sum, score) => sum + score);
    final result = _repository.calculateResult(totalScore);
    state = state.copyWith(result: result);
  }

  void reset() {
    state = AssessmentState(questions: _repository.getQuestions());
  }
}

final assessmentProvider =
    StateNotifierProvider<AssessmentNotifier, AssessmentState>((ref) {
      final repository = ref.watch(assessmentRepositoryProvider);
      return AssessmentNotifier(repository);
    });
