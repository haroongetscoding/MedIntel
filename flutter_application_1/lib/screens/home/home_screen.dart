import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/drawer_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/checkin_service.dart';
import '../../models/checkin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CheckinService _checkinService = CheckinService();

  int _currentNavigationIndex = 0;
  bool _isSearching = false;
  String _searchQuery = "";
  String firstName = "User";
  bool isLoading = true;

  int _wellnessScore = 0;
  String _wellnessStatus = 'Good';
  bool _wellnessLoaded = false;
  Checkin? _todayCheckin;

  String _doctorName = 'Doctor';
  bool _doctorLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadWellnessData();
    _loadDoctorData();
  }

  Future<void> _loadWellnessData() async {
    try {
      final today = await _checkinService.getTodayCheckin();
      final recent = await _checkinService.getLast7Checkins();
      if (!mounted) return;
      setState(() => _todayCheckin = today);
      if (recent.isNotEmpty) {
        final avg = recent.fold(0, (sum, c) => sum + c.moodScore) ~/ recent.length;
        _wellnessScore = (avg * 100 / 10).round().clamp(0, 100);
        _wellnessStatus = today?.moodLabel ?? 'Fair';
      } else {
        _wellnessScore = 0;
        _wellnessStatus = 'No data';
      }
      if (!mounted) return;
      setState(() => _wellnessLoaded = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _wellnessLoaded = true);
    }
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        firstName = 'User';
        isLoading = false;
      });
      return;
    }

    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      setState(() {
        firstName = user.displayName!.trim();
        isLoading = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final storedFirstName = data?['firstName']?.toString().trim();
        final storedLastName = data?['lastName']?.toString().trim();
        final resolvedFirstName = (storedFirstName != null && storedFirstName.isNotEmpty)
            ? storedFirstName
            : ((storedLastName != null && storedLastName.isNotEmpty)
                ? storedLastName
                : 'User');

        setState(() {
          firstName = resolvedFirstName;
          isLoading = false;
        });
      } else {
        setState(() {
          firstName = 'User';
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        firstName = 'User';
        isLoading = false;
      });
    }
  }

  Future<void> _loadDoctorData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty && mounted) {
        final data = snapshot.docs.first.data();
        final fn = data['firstName']?.toString() ?? '';
        final ln = data['lastName']?.toString() ?? '';
        setState(() {
          _doctorName = '$fn $ln'.trim();
          if (_doctorName.isEmpty) _doctorName = 'Doctor';
          _doctorLoaded = true;
        });
      } else if (mounted) {
        setState(() => _doctorLoaded = true);
      }
    } catch (_) {
      if (mounted) setState(() => _doctorLoaded = true);
    }
  }

  List<String> get _searchableItems => [
        if (_doctorLoaded) 'Dr. $_doctorName',
        "Theraflu MaxGrip (Medication)",
        "Insulin Injection (Medication)",
        "M-Vit Syrup (Vitamin)",
      ].where((e) => e.isNotEmpty).toList();

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentNavigationIndex = index;
      _isSearching = (index == 3);
    });
    if (index == 1) Navigator.pushNamed(context, '/ai-chat');
    if (index == 2) Navigator.pushNamed(context, '/checkin').then((_) => _loadWellnessData());
    if (index == 4) Navigator.pushNamed(context, '/profile');
  }

  void _triggerEmergencyCall() {
    Navigator.pushNamed(context, '/emergency-call');
  }

  @override
  Widget build(BuildContext context) {
    List<String> filteredResults = _searchableItems
        .where((item) => item.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const MedIntelDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: _isSearching
            ? TextField(
                autofocus: true,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Search doctors, medication...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                ),
              )
            : const Text(
                'MedIntel',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded, color: const Color(0xFF1E293B)),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                _searchQuery = "";
                _currentNavigationIndex = _isSearching ? 3 : 0;
              });
            },
          ),
        ],
      ),
      body: _isSearching
          ? ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredResults.length,
              itemBuilder: (context, idx) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: const Icon(Icons.search_outlined, color: Color(0xFF1962A1)),
                  title: Text(filteredResults[idx]),
                  onTap: () {
                    if (filteredResults[idx].contains("Medication") || filteredResults[idx].contains("Syrup")) {
                      Navigator.pushNamed(context, '/medications');
                    } else {
                      Navigator.pushNamed(context, '/appointments');
                    }
                  },
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.18), blurRadius: 24, offset: const Offset(0, 12)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GOOD MORNING, ${firstName.toUpperCase()}',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.8), letterSpacing: 1.3),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Your care overview is ready.',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Stay calm and stay connected',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/invite-family'),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.task_alt_rounded,
                          title: 'Daily Check-in',
                          subtitle: _todayCheckin != null ? 'Done today' : 'Tap to check in',
                          color: const Color(0xFF059669),
                          onTap: () => Navigator.pushNamed(context, '/checkin').then((_) => _loadWellnessData()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.calendar_month_rounded,
                          title: 'Appointments',
                          subtitle: 'Upcoming visits',
                          color: const Color(0xFF0F766E),
                          onTap: () => Navigator.pushNamed(context, '/appointments'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.medication_rounded,
                          title: 'Medications',
                          subtitle: 'Track your routine',
                          color: const Color(0xFF1D4ED8),
                          onTap: () => Navigator.pushNamed(context, '/medications'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          icon: Icons.chat_rounded,
                          title: 'AI Chat',
                          subtitle: 'Ask anything',
                          color: const Color(0xFF7C3AED),
                          onTap: () => Navigator.pushNamed(context, '/ai-chat'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (_wellnessLoaded)
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/checkin').then((_) => _loadWellnessData()),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _todayCheckin != null ? const Color(0xFFBBF7D0) : const Color(0xFFFED7AA)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _todayCheckin != null ? Icons.check_circle : Icons.pending_actions,
                              color: _todayCheckin != null ? const Color(0xFF22C55E) : const Color(0xFFF97316),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _todayCheckin != null
                                        ? 'Feeling $_wellnessStatus'
                                        : 'Not checked in today',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _todayCheckin != null ? const Color(0xFF166534) : const Color(0xFF9A3412),
                                    ),
                                  ),
                                  if (_todayCheckin != null)
                                    Text(
                                      'Score: $_wellnessScore/100',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'WELLNESS SCORE',
                          value: _wellnessLoaded ? '$_wellnessScore/100' : '...',
                          icon: Icons.favorite_rounded,
                          startColor: const Color(0xFF4F46E5),
                          endColor: const Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'PENDING REMINDERS',
                          value: '3 TODAY',
                          icon: Icons.alarm_rounded,
                          startColor: const Color(0xFF0EA5E9),
                          endColor: const Color(0xFF38BDF8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'UPCOMING APPOINTMENT',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16, offset: const Offset(0, 8)),
                      ],
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.medication_rounded, color: Color(0xFF10B981), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _doctorLoaded ? 'Dr. $_doctorName' : 'Doctor',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'General Physician',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                          child: const Text(
                            'Schedule',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFEF4444),
                          child: Icon(Icons.gpp_maybe_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Need urgent help?',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF9A2C00)),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Call emergency services directly from here.',
                                style: TextStyle(color: Color(0xFFB45309), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _triggerEmergencyCall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    icon: const Icon(Icons.call_rounded, size: 20),
                    label: const Text(
                      'EMERGENCY CALL',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.4),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: MedIntelBottomNav(
        currentIndex: _currentNavigationIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  // Beautiful Helper Widget for Dashboard Metric Grids
  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color startColor,
    required Color endColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [startColor, endColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: startColor.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8), letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white),
          ),
        ],
      ),
    );
  }
}