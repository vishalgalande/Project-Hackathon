import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app/theme.dart';
import '../app/providers.dart';
import '../models/zone.dart';

/// Page 3: Zone Details with Feedback Reporting
class IntelPage extends ConsumerWidget {
  final String zoneId;

  const IntelPage({super.key, required this.zoneId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zone = ref.watch(selectedZoneProvider(zoneId));

    if (zone == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Zone Details')),
        body: const Center(child: Text('Zone not found')),
      );
    }

    final zoneColor = zone.type.zoneColor;
    final isUserReportedDanger = zone.negativeFeedbackCount > 10;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Hero Header with Safety Score
          SliverAppBar(
            expandedHeight: 260.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                zone.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          zoneColor.withOpacity(0.15),
                          Colors.white,
                        ],
                      ),
                    ),
                  ),

                  // Radial Safety Score
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: zoneColor.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  zone.type == 'safe'
                                      ? '95'
                                      : zone.type == 'caution'
                                          ? '60'
                                          : '20',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: zoneColor,
                                  ),
                                ),
                                Text(
                                  'SCORE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .scale(duration: 600.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: zoneColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            zone.threatLevel.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Reported Alert (Dynamic)
                  if (isUserReportedDanger)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.report_gmailerrorred_rounded,
                              color: Colors.red),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Community Alert',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                Text(
                                  'Flagged as DANGER by ${zone.negativeFeedbackCount} users recently.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.02, 1.02),
                        duration: 600.ms),

                  // Report Button (Primary Action)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showReportDialog(context, ref, zone),
                      icon: const Icon(Icons.add_alert_rounded),
                      label: const Text('REPORT SAFETY ISSUE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      '${zone.negativeFeedbackCount} active reports in last 24h',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Info Cards
                  _buildSectionTitle('Zone Analysis'),
                  const SizedBox(height: 16),

                  // Bento Grid
                  Row(
                    children: [
                      Expanded(
                        child: _ModernStatCard(
                          title: 'Crime Index',
                          value: '${zone.crimeRate}',
                          subtitle: 'Lower is better',
                          icon: Icons.shield_outlined,
                          color: zone.crimeRate < 30
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ModernStatCard(
                          title: 'Visibility',
                          value: '${zone.lightingLevel}%',
                          subtitle: 'Street light coverage',
                          icon: Icons.lightbulb_outline,
                          color: zone.lightingLevel > 80
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Description'),
                  const SizedBox(height: 12),
                  Text(
                    zone.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  // Safety Tips
                  if (zone.warnings.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _buildSectionTitle('Advisories'),
                    const SizedBox(height: 16),
                    ...zone.warnings
                        .map((w) => _buildAdvisoryItem(w, zoneColor)),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87, // Force Black
      ),
    );
  }

  Widget _buildAdvisoryItem(String warning, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(
              warning,
              style: const TextStyle(
                color: Colors.black87, // Force Black
                fontWeight: FontWeight.w500,
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context, WidgetRef ref, Zone zone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Safety Issue',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your reports help mark this zone as DANGER (>10 reports).',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            _buildReportOption(context, ref, zone, 'Theft / Pickpocketing',
                Icons.run_circle_outlined),
            _buildReportOption(context, ref, zone, 'Harassment',
                Icons.record_voice_over_outlined),
            _buildReportOption(
                context, ref, zone, 'Poor Lighting', Icons.lightbulb_outline),
            _buildReportOption(context, ref, zone, 'Suspicious Activity',
                Icons.visibility_outlined),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOption(BuildContext context, WidgetRef ref, Zone zone,
      String title, IconData icon) {
    return InkWell(
      onTap: () {
        // Increment feedback (In a real app, this would be an API call)
        final newCount = zone.negativeFeedbackCount + 1;

        // Simulating the update by locally modifying the mock list via provider
        // (Just showing success message for this demo)

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Report submitted! Total reports: $newCount',
              style: const TextStyle(color: Colors.white), // Force white text
            ),
            backgroundColor:
                newCount > 10 ? AppColors.dangerZone : Colors.grey.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.black87, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}


class _ModernStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
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
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87, // Force Black
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87, // Force Black
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600, // Dark grey
            ),
          ),
        ],
      ),
    );
  }
}
