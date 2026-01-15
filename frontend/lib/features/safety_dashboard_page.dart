import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app/theme.dart';

/// Safety Dashboard - Visual analytics for safety data
class SafetyDashboardPage extends StatelessWidget {
  const SafetyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(
          'Safety Dashboard',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.bgCard,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Safety Score
            _buildSafetyScoreCard(),
            
            const SizedBox(height: 24),
            
            // Safety Trend Chart
            _buildSectionTitle('Safety Trend (Last 7 Days)'),
            const SizedBox(height: 16),
            _buildTrendChart(),
            
            const SizedBox(height: 32),
            
            // Incident Distribution
            _buildSectionTitle('Incident Types'),
            const SizedBox(height: 16),
            _buildIncidentPieChart(),
            
            const SizedBox(height: 32),
            
            // Time-based Analysis
            _buildSectionTitle('Incidents by Time of Day'),
            const SizedBox(height: 16),
            _buildTimeBarChart(),
            
            const SizedBox(height: 32),
            
            // Safety Tips
            _buildSectionTitle('Safety Tips'),
            const SizedBox(height: 16),
            _buildSafetyTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSafetyScoreCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success.withOpacity(0.2), AppColors.primary.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 400;
          return Column(
            children: [
              Text(
                'Overall Safety Score',
                style: GoogleFonts.inter(
                  fontSize: isSmall ? 14 : 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: isSmall ? 120 : 150,
                    height: isSmall ? 120 : 150,
                    child: CircularProgressIndicator(
                      value: 0.75,
                      strokeWidth: isSmall ? 8 : 12,
                      backgroundColor: AppColors.bgCard,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.success),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '75',
                        style: GoogleFonts.inter(
                          fontSize: isSmall ? 36 : 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        'Safe',
                        style: GoogleFonts.inter(
                          fontSize: isSmall ? 14 : 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Based on recent reports and zone analysis',
                style: GoogleFonts.inter(
                  fontSize: isSmall ? 12 : 13,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTrendChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.border,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[value.toInt()],
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
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
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 10,
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3),
                FlSpot(1, 2),
                FlSpot(2, 5),
                FlSpot(3, 3),
                FlSpot(4, 4),
                FlSpot(5, 2),
                FlSpot(6, 3),
              ],
              isCurved: true,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.accent.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentPieChart() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 350;
          final content = [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: isSmall ? 160 : 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: isSmall ? 30 : 40,
                    sections: [
                      PieChartSectionData(
                          color: Colors.red,
                          value: 35,
                          title: '35%',
                          radius: isSmall ? 50 : 60),
                      PieChartSectionData(
                          color: Colors.orange,
                          value: 25,
                          title: '25%',
                          radius: isSmall ? 50 : 60),
                      PieChartSectionData(
                          color: Colors.yellow,
                          value: 20,
                          title: '20%',
                          radius: isSmall ? 50 : 60),
                      PieChartSectionData(
                          color: Colors.blue,
                          value: 20,
                          title: '20%',
                          radius: isSmall ? 50 : 60),
                    ],
                  ),
                ),
              ),
            ),
            if (!isSmall) const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem('Theft', Colors.red),
                  _buildLegendItem('Scam', Colors.orange),
                  _buildLegendItem('Harassment', Colors.yellow),
                  _buildLegendItem('Other', Colors.blue),
                ],
              ),
            ),
          ];

          return isSmall
              ? Column(children: [
                  SizedBox(height: 180, child: content[0]),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem('Theft', Colors.red),
                            _buildLegendItem('Scam', Colors.orange),
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem('Harassment', Colors.yellow),
                            _buildLegendItem('Other', Colors.blue),
                          ]),
                    ],
                  )
                ])
              : Row(children: content);
        },
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBarChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const times = ['Morning', 'Afternoon', 'Evening', 'Night'];
                  if (value.toInt() >= 0 && value.toInt() < times.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        times[value.toInt()],
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 11,
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
                reservedSize: 30,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.border,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 3, color: AppColors.success, width: 20)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5, color: AppColors.warning, width: 20)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 8, color: AppColors.danger, width: 20)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 6, color: AppColors.warning, width: 20)]),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTips() {
    final tips = [
      {'icon': Icons.groups, 'tip': 'Travel in groups, especially at night'},
      {'icon': Icons.phone, 'tip': 'Keep emergency contacts saved'},
      {'icon': Icons.location_on, 'tip': 'Share your location with trusted contacts'},
      {'icon': Icons.warning, 'tip': 'Avoid poorly lit or isolated areas'},
      {'icon': Icons.local_taxi, 'tip': 'Use registered taxis and ride-sharing services'},
    ];

    return Column(
      children: tips.map((tip) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(tip['icon'] as IconData, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  tip['tip'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
