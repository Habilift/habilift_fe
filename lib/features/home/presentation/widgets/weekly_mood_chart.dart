import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../app/theme/app_colors.dart';

class WeeklyMoodChart extends StatelessWidget {
  final List<double> moodScores;
  final List<String> days;

  const WeeklyMoodChart({
    super.key,
    required this.moodScores,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Mood Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              // Calculate mood growth
              Builder(
                builder: (context) {
                  // Calculate average for current week (last 7 days)
                  final currentWeekScores = moodScores.where((score) => score > 0).toList();
                  if (currentWeekScores.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  final currentAvg = currentWeekScores.reduce((a, b) => a + b) / currentWeekScores.length;
                  
                  // Calculate growth percentage (comparing to baseline of 5.0)
                  // Or compare first half vs second half of week
                  final firstHalf = moodScores.take(3).where((s) => s > 0).toList();
                  final secondHalf = moodScores.skip(4).where((s) => s > 0).toList();
                  
                  double growthPercent = 0.0;
                  bool isPositive = true;
                  
                  if (firstHalf.isNotEmpty && secondHalf.isNotEmpty) {
                    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
                    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
                    growthPercent = ((secondAvg - firstAvg) / firstAvg * 100);
                    isPositive = growthPercent >= 0;
                  } else if (currentAvg > 0) {
                    // Compare to baseline of 5.0 (middle of scale)
                    growthPercent = ((currentAvg - 5.0) / 5.0 * 100);
                    isPositive = growthPercent >= 0;
                  }
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (isPositive ? AppColors.medicalGreen : AppColors.errorRed).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          size: 16,
                          color: isPositive ? AppColors.medicalGreen : AppColors.errorRed,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isPositive ? '+' : ''}${growthPercent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isPositive ? AppColors.medicalGreen : AppColors.errorRed,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.divider.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[value.toInt()],
                              style: TextStyle(
                                color: AppColors.textGray,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      reservedSize: 35,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (days.length - 1).toDouble(),
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      moodScores.length,
                      (index) => FlSpot(index.toDouble(), moodScores[index]),
                    ),
                    isCurved: true,
                    color: AppColors.medicalGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: AppColors.medicalGreen,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.medicalGreen.withValues(alpha: 0.3),
                          AppColors.medicalGreen.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
