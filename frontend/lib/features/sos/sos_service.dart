import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class SosService {
  final String emergencyNumber = "9172504362";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Request necessary permissions
  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.phone,
    ].request();

    return statuses[Permission.sms]!.isGranted;
  }

  // Get Current Location URL (Simulated as requested)
  Future<String> getCurrentLocationUrl() async {
    // Simulating GPS fetch delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Returning the specific link requested by the user
    // Fallback because Real-Time GPS plugin is causing build failures
    return "https://maps.app.goo.gl/zvhSWKCpqFW3pbQq6";
  }

  // Send SOS via SMS
  Future<void> sendSOS(List<String> contacts) async {
    if (contacts.isEmpty) return;
    
    String locationUrl = await getCurrentLocationUrl();
    
    // Improved SOS Message (Cleaner grammar, no confusing symbols)
    String messageContent = "SOS! I need immediate help. I am using the SafeTravel app to alert you. Please check my location below:\n\nLocation: $locationUrl";
    
    // Manually construct SMS URI to avoid '+' replacement for spaces (Android specific behavior workaround)
    // We use Uri.encodeComponent for the body but ensure spaces become %20
    String encodedBody = Uri.encodeComponent(messageContent).replaceAll('+', '%20');
    
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: contacts.join(','),
      query: 'body=$encodedBody', 
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      throw 'Could not launch SMS app';
    }
  }

  // Call Emergency Number
  Future<void> callEmergency() async {
    final Uri telUri = Uri(scheme: 'tel', path: emergencyNumber);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      throw 'Could not launch dialer';
    }
  }

  // --- Trusted Contacts (Firestore) ---

  // Get stream of trusted contacts
  Stream<QuerySnapshot> getTrustedContacts() {
    final User? user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('trusted_contacts')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  // Add a trusted contact
  Future<void> addTrustedContact(String phone) async {
    final User? user = _auth.currentUser;
    if (user == null) throw 'User not logged in';

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('trusted_contacts')
        .add({
      'phoneNumber': phone,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove a trusted contact
  Future<void> removeTrustedContact(String contactId) async {
    final User? user = _auth.currentUser;
    if (user == null) throw 'User not logged in';

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('trusted_contacts')
        .doc(contactId)
        .delete();
  }
}
