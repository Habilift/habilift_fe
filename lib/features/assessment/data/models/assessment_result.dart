enum RiskLevel { low, medium, high }

class AssessmentResult {
  final int totalScore;
  final RiskLevel riskLevel;
  final String explanation;
  final String recommendedPathway;

  AssessmentResult({
    required this.totalScore,
    required this.riskLevel,
    required this.explanation,
    required this.recommendedPathway,
  });
}
