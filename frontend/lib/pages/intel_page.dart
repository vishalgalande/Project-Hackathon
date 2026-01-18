import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app/theme.dart';
import '../app/providers.dart';
import '../models/zone.dart';
import '../services/zone_service.dart';

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
                                  // Dynamic score: base score minus penalty for reports
                                  () {
                                    int baseScore = zone.type == 'safe'
                                        ? 95
                                        : zone.type == 'caution'
                                            ? 60
                                            : 20;
                                    // Reduce score by 3 points per negative report
                                    int penalty =
                                        zone.negativeFeedbackCount * 3;
                                    int finalScore =
                                        (baseScore - penalty).clamp(0, 100);
                                    return '$finalScore';
                                  }(),
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

                  // Safety Tips & User Reports
                  if (zone.warnings.isNotEmpty ||
                      zone.liveWarnings.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _buildSectionTitle('Advisories'),
                    const SizedBox(height: 16),
                    // Show user-reported warnings first (live from Firebase)
                    ...zone.liveWarnings.map(
                        (w) => _buildAdvisoryItem(w, AppColors.dangerZone)),
                    // Then show static warnings
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
            Expanded(
                child: Text(
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
    final user = FirebaseAuth.instance.currentUser;

    // Check if user is logged in
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to submit reports'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReportBottomSheet(zone: zone, userId: user.uid),
    );
  }
}

/// Stateful bottom sheet for account-linked reporting
class _ReportBottomSheet extends ConsumerStatefulWidget {
  final Zone zone;
  final String userId;

  const _ReportBottomSheet({required this.zone, required this.userId});

  @override
  ConsumerState<_ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends ConsumerState<_ReportBottomSheet> {
  int _userReportCount = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _userReports = [];

  @override
  void initState() {
    super.initState();
    _loadUserReports();
  }

  Future<void> _loadUserReports() async {
    final service = ref.read(zoneServiceProvider);

    int count = 0;
    try {
      count = await service.getUserReportCountForZone(
          widget.userId, widget.zone.id);
    } catch (e) {
      debugPrint('ERROR loading report count: $e');
    }

    // Also load report history
    try {
      final reportsStream =
          service.getUserReportsForZone(widget.userId, widget.zone.id);
      reportsStream.first.then((snapshot) {
        if (mounted) {
          setState(() {
            _userReports = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                'type': data['reportType'] ?? 'unknown',
                'timestamp': data['timestamp'],
              };
            }).toList();
          });
        }
      });
    } catch (e) {
      debugPrint('ERROR loading report history: $e');
    }

    if (mounted) {
      setState(() {
        _userReportCount = count;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitReport(String reportType) async {
    final service = ref.read(zoneServiceProvider);
    final error = await service.submitUserReport(
      userId: widget.userId,
      zoneId: widget.zone.id,
      cityId: widget.zone.cityId,
      reportType: reportType,
    );

    Navigator.pop(context);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Report submitted! (${_userReportCount + 1}/3 used)'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteReport(String reportId, String reportType) async {
    final service = ref.read(zoneServiceProvider);
    try {
      await service.deleteUserReport(
          reportId, widget.zone.id, widget.zone.cityId, reportType);
      setState(() {
        _userReports.removeWhere((r) => r['id'] == reportId);
        _userReportCount = (_userReportCount - 1).clamp(0, 3);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Report deleted'), backgroundColor: Colors.blue),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error deleting: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _getReportTypeLabel(String type) {
    switch (type) {
      case 'theft':
        return 'Theft / Pickpocketing';
      case 'harassment':
        return 'Harassment';
      case 'lighting':
        return 'Poor Lighting';
      case 'suspicious':
        return 'Suspicious Activity';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canReport = _userReportCount < 3;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Report Safety Issue',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: canReport ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: canReport ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  '$_userReportCount/3 used',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        canReport ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            canReport
                ? 'Your reports help mark this zone as DANGER (>10 reports).'
                : 'You have reached the report limit for this zone.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Report Options
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (canReport) ...[
            _buildReportOption(
                'Theft / Pickpocketing', Icons.run_circle_outlined, 'theft'),
            _buildReportOption(
                'Harassment', Icons.record_voice_over_outlined, 'harassment'),
            _buildReportOption(
                'Poor Lighting', Icons.lightbulb_outline, 'lighting'),
            _buildReportOption(
                'Suspicious Activity', Icons.visibility_outlined, 'suspicious'),
          ] else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, color: Colors.grey),
                  SizedBox(width: 12),
                  Text('Report limit reached for this zone'),
                ],
              ),
            ),

          // User's Previous Reports with Delete
          if (_userReports.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Your Reports (tap to delete)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87),
            ),
            const SizedBox(height: 8),
            ..._userReports.map((report) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green.shade400, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(_getReportTypeLabel(report['type']),
                              style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 13))),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Colors.red.shade300, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () =>
                            _deleteReport(report['id'], report['type']),
                        tooltip: 'Delete report',
                      ),
                    ],
                  ),
                )),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildReportOption(String title, IconData icon, String reportType) {
    return InkWell(
      onTap: () => _submitReport(reportType),
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
