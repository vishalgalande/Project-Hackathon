import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../app/providers.dart';
import '../models/zone.dart';

/// Page 3: Zone Details
/// Simple, clean information page
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
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(zone.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: zoneColor.withOpacity(0.1),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: zoneColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      zone.type.toLowerCase() == 'danger'
                          ? Icons.dangerous
                          : zone.type.toLowerCase() == 'caution'
                              ? Icons.warning_amber
                              : Icons.verified_user,
                      color: zoneColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: zoneColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            zone.type.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          zone.threatLevel,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Description
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About this zone',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    zone.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Stats
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildStatItem(
                    context,
                    Icons.gavel,
                    'Crime Rate',
                    '${zone.crimeRate}%',
                    zone.crimeRate / 100,
                    zone.crimeRate > 50 ? AppColors.dangerZone : 
                        zone.crimeRate > 25 ? AppColors.cautionZone : AppColors.safeZone,
                  ),
                  const SizedBox(height: 16),
                  _buildStatItem(
                    context,
                    Icons.lightbulb_outline,
                    'Lighting Level',
                    '${zone.lightingLevel}%',
                    zone.lightingLevel / 100,
                    zone.lightingLevel < 50 ? AppColors.dangerZone : 
                        zone.lightingLevel < 75 ? AppColors.cautionZone : AppColors.safeZone,
                  ),
                  const SizedBox(height: 16),
                  _buildStatItem(
                    context,
                    Icons.report_outlined,
                    'Recent Incidents',
                    '${zone.recentIncidents}',
                    zone.recentIncidents / 10,
                    zone.recentIncidents > 5 ? AppColors.dangerZone : 
                        zone.recentIncidents > 2 ? AppColors.cautionZone : AppColors.safeZone,
                  ),
                ],
              ),
            ),
            
            // Warnings
            if (zone.warnings.isNotEmpty) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: zoneColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Safety Tips',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...zone.warnings.map((warning) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: zoneColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              warning,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
            
            // Location info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Coordinates',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${zone.centerLat.toStringAsFixed(4)}°N, ${zone.centerLng.toStringAsFixed(4)}°E',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Open in Maps'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
