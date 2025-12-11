import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/models/assessment_result.dart';
import '../providers/assessment_provider.dart';
import '../widgets/risk_level_badge.dart';

class AssessmentResultScreen extends ConsumerWidget {
  const AssessmentResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assessmentProvider);
    final result = state.result;

    if (result == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textBlack),
          onPressed: () {
            ref.read(assessmentProvider.notifier).reset();
            context.go('/home'); // Go back to dashboard
          },
        ),
        title: Text(
          'Assessment Result',
          style: AppTypography.lightTextTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            RiskLevelBadge(riskLevel: result.riskLevel).animate().scale(),
            const SizedBox(height: 24),
            Text(
              'Your Mental Wellness Score',
              style: AppTypography.lightTextTheme.bodyLarge?.copyWith(
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${result.totalScore} / 20', // Assuming 5 questions * 4 max score
              style: AppTypography.lightTextTheme.displayLarge?.copyWith(
                fontSize: 48,
                color: AppColors.medicalGreen,
              ),
            ).animate().fadeIn().slideY(begin: 0.2),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        IconlyBold.infoSquare,
                        color: AppColors.medicalGreen,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Analysis',
                        style: AppTypography.lightTextTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result.explanation,
                    style: AppTypography.lightTextTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(IconlyBold.star, color: Color(0xFFFF9800)),
                      const SizedBox(width: 12),
                      Text(
                        'Recommendation',
                        style: AppTypography.lightTextTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result.recommendedPathway,
                    style: AppTypography.lightTextTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _generateAndPrintPdf(result),
                    icon: const Icon(IconlyBold.document),
                    label: const Text('Export PDF'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.medicalGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _shareResult(result),
                    icon: const Icon(IconlyBold.send, color: Colors.white),
                    label: const Text(
                      'Share',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.medicalGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndPrintPdf(AssessmentResult result) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'HabiLift Assessment Result',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Score: ${result.totalScore} / 20',
                style: pw.TextStyle(fontSize: 18),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Risk Level: ${result.riskLevel.name.toUpperCase()}',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Analysis:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(result.explanation),
              pw.SizedBox(height: 20),
              pw.Text(
                'Recommendation:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(result.recommendedPathway),
              pw.SizedBox(height: 40),
              pw.Footer(title: pw.Text('Generated by HabiLift AI')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  void _shareResult(AssessmentResult result) {
    Share.share(
      'My HabiLift Assessment Result:\n\nScore: ${result.totalScore}/20\nRisk Level: ${result.riskLevel.name.toUpperCase()}\n\nAnalysis: ${result.explanation}\n\nRecommendation: ${result.recommendedPathway}',
      subject: 'HabiLift Assessment Result',
    );
  }
}
