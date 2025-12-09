import '../models/assessment_question.dart';
import '../models/assessment_result.dart';

class AssessmentRepository {
  // Mock Questions
  List<AssessmentQuestion> getQuestions() {
    return [
      AssessmentQuestion(
        id: '1',
        text: 'How often do you feel overwhelmed by your daily tasks?',
        options: [
          AssessmentOption(id: '1a', text: 'Rarely', score: 1),
          AssessmentOption(id: '1b', text: 'Sometimes', score: 2),
          AssessmentOption(id: '1c', text: 'Often', score: 3),
          AssessmentOption(id: '1d', text: 'Always', score: 4),
        ],
      ),
      AssessmentQuestion(
        id: '2',
        text: 'How would you rate your sleep quality recently?',
        options: [
          AssessmentOption(id: '2a', text: 'Very Good', score: 1),
          AssessmentOption(id: '2b', text: 'Good', score: 2),
          AssessmentOption(id: '2c', text: 'Poor', score: 3),
          AssessmentOption(id: '2d', text: 'Very Poor', score: 4),
        ],
      ),
      AssessmentQuestion(
        id: '3',
        text: 'Do you find it difficult to concentrate on things?',
        options: [
          AssessmentOption(id: '3a', text: 'No, not at all', score: 1),
          AssessmentOption(id: '3b', text: 'Occasionally', score: 2),
          AssessmentOption(id: '3c', text: 'Frequently', score: 3),
          AssessmentOption(id: '3d', text: 'Almost always', score: 4),
        ],
      ),
      AssessmentQuestion(
        id: '4',
        text: 'Have you lost interest in activities you used to enjoy?',
        options: [
          AssessmentOption(id: '4a', text: 'No', score: 1),
          AssessmentOption(id: '4b', text: 'A little', score: 2),
          AssessmentOption(id: '4c', text: 'Yes, significantly', score: 3),
          AssessmentOption(id: '4d', text: 'Completely', score: 4),
        ],
      ),
      AssessmentQuestion(
        id: '5',
        text: 'How often do you feel anxious or on edge?',
        options: [
          AssessmentOption(id: '5a', text: 'Never', score: 1),
          AssessmentOption(id: '5b', text: 'Rarely', score: 2),
          AssessmentOption(id: '5c', text: 'Often', score: 3),
          AssessmentOption(id: '5d', text: 'Constantly', score: 4),
        ],
      ),
    ];
  }

  // Mock Logic to calculate result
  AssessmentResult calculateResult(int totalScore) {
    if (totalScore <= 8) {
      return AssessmentResult(
        totalScore: totalScore,
        riskLevel: RiskLevel.low,
        explanation:
            'Your responses suggest you are managing well. Keep up your healthy habits!',
        recommendedPathway:
            'Explore our Wellness Content for tips on maintaining balance.',
      );
    } else if (totalScore <= 14) {
      return AssessmentResult(
        totalScore: totalScore,
        riskLevel: RiskLevel.medium,
        explanation:
            'You may be experiencing some stress or mild symptoms. It might be helpful to talk to someone.',
        recommendedPathway:
            'Consider booking a session with a General Counselor.',
      );
    } else {
      return AssessmentResult(
        totalScore: totalScore,
        riskLevel: RiskLevel.high,
        explanation:
            'Your responses indicate you might be going through a difficult time. Professional support is highly recommended.',
        recommendedPathway:
            'We recommend booking an urgent consultation with a Specialist.',
      );
    }
  }
}
