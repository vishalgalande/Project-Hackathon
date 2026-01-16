import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        title: Text('About', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Visualization Badges (as per screenshot roughly, but showing stack categories)
            Text('Tech Stack', style: GoogleFonts.syncopate(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            
            _buildStackSection('Frontend', [
              _StackBadge('Flutter', Icons.phone_android),
              _StackBadge('Dart', Icons.code),
              _StackBadge('Riverpod', Icons.waves),
              _StackBadge('Google Fonts', Icons.font_download),
            ]),
            
            _buildStackSection('Backend & Services', [
              _StackBadge('Firebase', Icons.cloud),
              _StackBadge('Firestore', Icons.storage),
              _StackBadge('Firebase Auth', Icons.security),
              _StackBadge('Gemini AI', Icons.psychology),
            ]),
            
            _buildStackSection('Maps & Location', [
              _StackBadge('OpenStreetMap', Icons.map),
              _StackBadge('Flutter Map', Icons.place),
              _StackBadge('LatLong2', Icons.gps_fixed),
            ]),

            _buildStackSection('Visualization', [
              _StackBadge('FL Chart', Icons.bar_chart),
              _StackBadge('Animations', Icons.animation),
            ]),

            const SizedBox(height: 32),

            // About Project Card
            Text('About the Project', style: GoogleFonts.syncopate(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     'SafeZone is a comprehensive tourist safety application designed to help travelers navigate India safely. The app provides real-time safety zone information, emergency contacts, AI-powered assistance, and community-driven safety reports.',
                     style: GoogleFonts.inter(fontSize: 14, color: Colors.white70, height: 1.5),
                   ),
                   const SizedBox(height: 24),
                   _buildProjectInfoRow(Icons.calendar_month, 'Built for TechSprint - GDG 2026 Hacks'),
                   _buildProjectInfoRow(Icons.school, 'Manipal University Jaipur'),
                   _buildProjectInfoRow(Icons.date_range, 'January 2026'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // View on GitHub Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5865F2), // Blurpleish
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(FontAwesomeIcons.github),
              label: Text('View on GitHub', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              onPressed: () => launchUrl(Uri.parse('https://github.com/vishalgalande/Project-Hackathon')), // Using main repo link provided or derived
            ),

            const SizedBox(height: 48),

            // Team Members
            Text('Team Members', style: GoogleFonts.syncopate(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            
            _buildTeamMember(
              name: 'Vishal Galande',
              role: 'Leader',
              email: 'vishalgalande07@gmail.com',
              github: 'https://github.com/vishalgalande/',
              linkedin: 'https://www.linkedin.com/in/vishalgalande/',
              avatarColor: Colors.orangeAccent,
            ),
            _buildTeamMember(
              name: 'Prajnadeep Sarma',
              role: 'Member',
              email: 'prajnadeepsarma@gmail.com',
              github: 'https://github.com/SarmaHighOnCode',
              linkedin: 'https://www.linkedin.com/in/prajnadeep-sarma/',
              avatarColor: Colors.blueAccent,
            ),
            _buildTeamMember(
              name: 'Neel Patel',
              role: 'Member',
              email: 'patelramesh7311@gmail.com',
              github: 'https://github.com/patelramesh7311-code',
              linkedin: 'https://www.linkedin.com/in/neel-patel-0864773a4/',
              avatarColor: Colors.greenAccent,
            ),
            _buildTeamMember(
              name: 'Shubham Poddar',
              role: 'Member',
              email: 'shubhampoddar664@gmail.com',
              github: 'https://github.com/shubhampoddar013',
              linkedin: 'https://www.linkedin.com/in/shubhamshibupoddar/',
              avatarColor: Colors.redAccent,
            ),

            const SizedBox(height: 32),
            Center(
              child: Text('Made with ❤️ by Team Strawhats', style: GoogleFonts.spaceMono(color: Colors.white38, fontSize: 12)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStackSection(String title, List<_StackBadge> badges) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: badges.map((b) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF5865F2).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(b.icon, size: 16, color: const Color(0xFF5865F2)),
                  const SizedBox(width: 8),
                  Text(b.label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF5865F2), size: 20),
          const SizedBox(width: 12),
          Text(text, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTeamMember({
    required String name,
    required String role,
    required String email,
    required String github,
    required String linkedin,
    required Color avatarColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // White card in screenshot, but we are dark theme. Keep consistent.
        // Actually, let's make it look like the screenshot but dark.
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: avatarColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.person, color: avatarColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                    if (role == 'Leader') ...[
                      const SizedBox(width: 8),
                      Text('(Leader)', style: GoogleFonts.inter(color: Colors.orangeAccent, fontSize: 12)),
                    ],
                  ],
                ),
                Text(email, style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.github, size: 20, color: Colors.white70),
            onPressed: () => launchUrl(Uri.parse(github)),
            tooltip: 'GitHub',
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.linkedin, size: 20, color: Colors.blueAccent),
            onPressed: () => launchUrl(Uri.parse(linkedin)),
            tooltip: 'LinkedIn',
          ),
        ],
      ),
    );
  }
}

class _StackBadge {
  final String label;
  final IconData icon;
  _StackBadge(this.label, this.icon);
}
