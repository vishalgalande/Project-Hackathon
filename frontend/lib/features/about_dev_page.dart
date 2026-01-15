import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/theme.dart';

/// About Dev Page - Team Strawhats information for GDC 2026 Hacks
class AboutDevPage extends StatelessWidget {
  const AboutDevPage({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.bgCard,
            foregroundColor: AppColors.textPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'About',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      AppColors.accent.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.shield_outlined,
                    size: 80,
                    color: AppColors.textPrimary.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hackathon Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '🏆 GDC 2026 Hacks',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Project Title
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'SafeZone',
                          style: GoogleFonts.inter(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Smart Tourist Safety System',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Team Section
                  _buildSectionTitle('Team Strawhats'),
                  const SizedBox(height: 16),
                  
                  // Team Leader
                  _buildTeamMemberCard(
                    name: 'Vishal Galande',
                    role: 'Team Leader',
                    email: 'vishalgalande07@gmail.com',
                    isLeader: true,
                  ),
                  
                  // Team Members
                  _buildTeamMemberCard(
                    name: 'Shubham Poddar',
                    role: 'Developer',
                    email: 'shubhampoddar864@gmail.com',
                  ),
                  
                  _buildTeamMemberCard(
                    name: 'Prajnadeep Sarma',
                    role: 'Developer',
                    email: 'prajnadeepsarma@gmail.com',
                  ),
                  
                  _buildTeamMemberCard(
                    name: 'Neel Patel',
                    role: 'Developer',
                    email: 'patelramesh7311@gmail.com',
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Tech Stack
                  _buildSectionTitle('Tech Stack'),
                  const SizedBox(height: 16),
                  
                  _buildTechCategory(
                    'Frontend',
                    [
                      {'name': 'Flutter', 'icon': Icons.phone_android},
                      {'name': 'Dart', 'icon': Icons.code},
                      {'name': 'Riverpod', 'icon': Icons.settings_input_component},
                      {'name': 'Google Fonts', 'icon': Icons.font_download},
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildTechCategory(
                    'Backend & Services',
                    [
                      {'name': 'Firebase', 'icon': Icons.cloud},
                      {'name': 'Firestore', 'icon': Icons.storage},
                      {'name': 'Firebase Auth', 'icon': Icons.security},
                      {'name': 'Gemini AI', 'icon': Icons.psychology},
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildTechCategory(
                    'Maps & Location',
                    [
                      {'name': 'OpenStreetMap', 'icon': Icons.map},
                      {'name': 'Flutter Map', 'icon': Icons.location_on},
                      {'name': 'LatLong2', 'icon': Icons.gps_fixed},
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildTechCategory(
                    'Visualization',
                    [
                      {'name': 'FL Chart', 'icon': Icons.bar_chart},
                      {'name': 'Animations', 'icon': Icons.animation},
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Project Info
                  _buildSectionTitle('About the Project'),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SafeZone is a comprehensive tourist safety application designed to help travelers navigate India safely. The app provides real-time safety zone information, emergency contacts, AI-powered assistance, and community-driven safety reports.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.event, 'Built for GDC 2026 Hacks'),
                        _buildInfoRow(Icons.school, 'Manipal University Jaipur'),
                        _buildInfoRow(Icons.calendar_today, 'January 2026'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // GitHub Link
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl('https://github.com/vishalgalande/Project-Hackathon'),
                      icon: const Icon(Icons.code),
                      label: Text(
                        'View on GitHub',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Footer
                  Center(
                    child: Text(
                      'Made with ❤️ by Team Strawhats',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
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
      style: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTeamMemberCard({
    required String name,
    required String role,
    required String email,
    bool isLeader = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(
          color: isLeader ? AppColors.primary : AppColors.border,
          width: isLeader ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isLeader
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 400;
          return Row(
            children: [
              Container(
                width: isSmall ? 50 : 60,
                height: isSmall ? 50 : 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLeader
                        ? [AppColors.primary, AppColors.accent]
                        : [
                            AppColors.textSecondary.withOpacity(0.3),
                            AppColors.textSecondary.withOpacity(0.1)
                          ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLeader ? Icons.star : Icons.person,
                  color: Colors.white,
                  size: isSmall ? 24 : 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: isSmall ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (isLeader)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.accent],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'LEADER',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: GoogleFonts.inter(
                        fontSize: isSmall ? 12 : 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            email,
                            style: GoogleFonts.inter(
                              fontSize: isSmall ? 11 : 12,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTechCategory(String category, List<Map<String, dynamic>> technologies) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: technologies.map((tech) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tech['icon'] as IconData, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      tech['name'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
