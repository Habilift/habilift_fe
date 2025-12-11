class AssessmentQuestion {
  final String id;
  final String text;
  final List<AssessmentOption> options;

  AssessmentQuestion({
    required this.id,
    required this.text,
    required this.options,
  });
}

class AssessmentOption {
  final String id;
  final String text;
  final int score;

  AssessmentOption({required this.id, required this.text, required this.score});
}
