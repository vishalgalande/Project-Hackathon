import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/providers.dart';

/// Admin page for database seeding and management
/// Navigate to /admin to access this page
class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  bool _isSeeding = false;
  String _status = 'Ready to seed database';

  Future<void> _seedDatabase() async {
    setState(() {
      _isSeeding = true;
      _status = 'Seeding database...';
    });

    try {
      final service = ref.read(zoneServiceProvider);
      await service.seedDatabase();
      setState(() {
        _status =
            '✅ Database seeded successfully!\nZones and cities have been uploaded to Firestore.';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error seeding database:\n$e';
      });
    } finally {
      setState(() {
        _isSeeding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Database Seeding'),
        backgroundColor: Colors.blueGrey[900],
      ),
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload,
                size: 80,
                color: Colors.blue[400],
              ),
              const SizedBox(height: 24),
              const Text(
                'Seed Firestore Database',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This will upload all mock zones and cities to your Firebase Firestore database.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _status.contains('✅')
                        ? Colors.green
                        : _status.contains('❌')
                            ? Colors.red
                            : Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isSeeding ? null : _seedDatabase,
                icon: _isSeeding
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload),
                label: Text(_isSeeding ? 'Seeding...' : 'Seed Database'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                '⚠️ Only run this once!\nRunning multiple times will overwrite existing data.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orange[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
