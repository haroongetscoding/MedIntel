import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MedIntelDrawer extends StatefulWidget {
  const MedIntelDrawer({Key? key}) : super(key: key);

  @override
  State<MedIntelDrawer> createState() => _MedIntelDrawerState();
}

class _MedIntelDrawerState extends State<MedIntelDrawer> {
  String _displayName = 'User';
  String _email = 'user@medintel.com';
  String _initial = 'U';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String displayName = user.displayName?.trim() ?? '';
    String email = user.email?.trim() ?? 'user@medintel.com';

    if (displayName.isEmpty) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          final firstName = data?['firstName']?.toString().trim();
          final lastName = data?['lastName']?.toString().trim();
          if (firstName != null && firstName.isNotEmpty) {
            displayName = firstName;
          } else if (lastName != null && lastName.isNotEmpty) {
            displayName = lastName;
          }
          final storedEmail = data?['email']?.toString().trim();
          if (storedEmail != null && storedEmail.isNotEmpty) {
            email = storedEmail;
          }
        }
      } catch (_) {
      }
    }

    if (displayName.isEmpty) {
      final localPart = email.split('@').first;
      displayName = localPart.isNotEmpty ? localPart : 'User';
    }

    setState(() {
      _displayName = displayName;
      _email = email;
      _initial = _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'U';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Text(
                      _initial,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _email,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Services",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _drawerTile(
              context,
              icon: Icons.task_alt_rounded,
              title: "Daily Check-in",
              route: "/checkin",
            ),
            _drawerTile(
              context,
              icon: Icons.analytics_outlined,
              title: "Symptom Checker",
              route: "/ai-chat",
            ),
            _drawerTile(
              context,
              icon: Icons.medication_outlined,
              title: "Medicine Reminders",
              route: "/medications",
            ),
            _drawerTile(
              context,
              icon: Icons.assignment_outlined,
              title: "Health Records",
              route: "/profile",
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, "/login");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    "Log Out",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _drawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, route);
          },
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2563EB), size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
