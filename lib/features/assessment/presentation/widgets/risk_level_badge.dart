import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/models/assessment_result.dart';

class RiskLevelBadge extends StatelessWidget {
  final RiskLevel riskLevel;

  const RiskLevelBadge({super.key, required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (riskLevel) {
      case RiskLevel.low:
        color = const Color(0xFF4CAF50); // Green
        text = 'Low Risk';
        break;
      case RiskLevel.medium:
        color = const Color(0xFFFF9800); // Orange
        text = 'Medium Risk';
        break;
      case RiskLevel.high:
        color = const Color(0xFFF44336); // Red
        text = 'High Risk';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: AppTypography.lightTextTheme.titleLarge?.copyWith(
          color: color,
          fontSize: 14,
        ),
      ),
    );
  }
}
