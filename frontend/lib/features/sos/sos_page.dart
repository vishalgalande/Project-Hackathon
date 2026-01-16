import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'sos_service.dart';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> with SingleTickerProviderStateMixin {
  final SosService _sosService = SosService();
  late AnimationController _controller;
  List<DocumentSnapshot> _trustedContacts = []; 
  StreamSubscription? _contactsSubscription;
  final TextEditingController _contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _checkPermissions();
    _subscribeToContacts();
  }

  void _subscribeToContacts() {
    _contactsSubscription = _sosService.getTrustedContacts().listen((snapshot) {
      if (mounted) {
        setState(() {
          _trustedContacts = snapshot.docs;
        });
      }
    }, onError: (error) {
       print("Error loading contacts: $error");
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error loading contacts. Please log in.')),
         );
       }
    });
  }

  Future<void> _checkPermissions() async {
    await _sosService.requestPermissions();
  }

  @override
  void dispose() {
    _controller.dispose();
    _contactController.dispose();
    _contactsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _addContact(String number) async {
    if (number.isNotEmpty) {
      try {
        await _sosService.addTrustedContact(number);
        if (mounted) {
          _contactController.clear();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
           Navigator.pop(context);
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Failed to add contact: $e')),
           );
        }
      }
    }
  }

  Future<void> _removeContact(String docId) async {
    try {
      await _sosService.removeTrustedContact(docId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact removed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove contact: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text('Emergency SOS', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SOS Button Section
              Center(
                child: GestureDetector(
                  onTap: () async {
                    if (_trustedContacts.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please add at least one trusted contact first!')),
                      );
                      return;
                    }
                    List<String> numbers = _trustedContacts
                        .map((doc) => doc['phoneNumber'] as String)
                        .toList();
                    await _sosService.sendSOS(numbers);
                  },
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.6),
                              blurRadius: 20 + (_controller.value * 20),
                              spreadRadius: 10 + (_controller.value * 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'SOS',
                            style: GoogleFonts.inter(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap to send location & alert to contacts',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              
              const SizedBox(height: 48),

              // National Emergency Numbers
              Text('National Emergency Numbers', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              _buildEmergencyCard(
                'Police', 
                'For immediate police assistance', 
                '100', 
                Colors.blue, 
                Icons.local_police
              ),
              _buildEmergencyCard(
                'Ambulance', 
                'Medical emergency services', 
                '102', 
                Colors.red, 
                Icons.medical_services
              ),
              _buildEmergencyCard(
                'Fire Department', 
                'Fire emergency services', 
                '101', 
                Colors.orange, 
                Icons.fire_truck
              ),
              _buildEmergencyCard(
                'Women Helpline', 
                '24x7 women safety helpline', 
                '1091', 
                Colors.purple, 
                Icons.woman
              ),

              const SizedBox(height: 32),
              
              // Tourist Services
              Text('Tourist Services', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              _buildEmergencyCard(
                'Tourist Helpline', 
                'Ministry of Tourism helpline', 
                '1363', 
                Colors.indigo, 
                Icons.travel_explore
              ),
              _buildEmergencyCard(
                'National Emergency', 
                'Single emergency number for all services', 
                '112', 
                Colors.green, 
                Icons.shield
              ),

              const SizedBox(height: 32),

              // Trusted Contacts Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trusted Contacts',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    onPressed: () => _showAddContactDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_trustedContacts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'No contacts added. Add family or friends to notify them in emergencies.',
                    style: TextStyle(color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ..._trustedContacts.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final phone = data['phoneNumber'] as String? ?? 'Unknown';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      tileColor: Colors.white.withOpacity(0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      leading: const Icon(Icons.person, color: Colors.white70),
                      title: Text(phone, style: const TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _removeContact(doc.id),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Add Trusted Contact', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _contactController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter phone number',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _addContact(_contactController.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(String title, String subtitle, String number, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(number, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => launchUrl(Uri.parse('tel:$number')),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.call, size: 12, color: color),
                        const SizedBox(width: 4),
                        Text('Call', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
