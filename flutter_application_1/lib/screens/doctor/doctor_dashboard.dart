import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../theme/app_theme.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({Key? key}) : super(key: key);

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final AppointmentService _appointmentService = AppointmentService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _doctorName = 'Doctor';
  String _doctorId = '';
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadDoctor();
  }

  Future<void> _loadDoctor() async {
    final user = _auth.currentUser;
    if (user == null) return;
    setState(() => _doctorId = user.uid);
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      final data = doc.data();
      final firstName = data?['firstName']?.toString() ?? '';
      final lastName = data?['lastName']?.toString() ?? '';
      setState(() {
        _doctorName = '$firstName $lastName'.trim();
        if (_doctorName.isEmpty) _doctorName = 'Doctor';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Dr. $_doctorName',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            onPressed: () async {
              await _auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _selectedTab == 0
                ? _buildAppointmentsTab()
                : _buildPatientsTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTab(0, 'Appointments', Icons.calendar_month_rounded),
          _buildTab(1, 'Patients', Icons.people_rounded),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    if (_doctorId.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<Appointment>>(
      stream: _appointmentService.getAppointmentsForDoctor(_doctorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final appointments = snapshot.data ?? [];

        final pending = appointments.where((a) => a.status == 'pending').toList();
        final confirmed = appointments.where((a) => a.status == 'confirmed').toList();
        final rejected = appointments.where((a) => a.status == 'rejected').toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatCard('Pending', pending.length.toString(), Colors.orange),
                  const SizedBox(width: 10),
                  _buildStatCard('Confirmed', confirmed.length.toString(), Colors.green),
                  const SizedBox(width: 10),
                  _buildStatCard('Rejected', rejected.length.toString(), Colors.red),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'APPOINTMENT REQUESTS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: appointments.isEmpty
                    ? Center(
                        child: Text(
                          'No appointments yet',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          return _buildAppointmentCard(appointments[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final isPending = appointment.status == 'pending';
    final isConfirmed = appointment.status == 'confirmed';
    final dateStr =
        '${appointment.date.month}/${appointment.date.day}/${appointment.date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPending
              ? Colors.orange.shade100
              : isConfirmed
                  ? Colors.green.shade100
                  : Colors.red.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                child: Text(
                  appointment.patientName.isNotEmpty
                      ? appointment.patientName[0].toUpperCase()
                      : 'P',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      appointment.patientEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending
                      ? Colors.orange.shade50
                      : isConfirmed
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  appointment.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isPending
                        ? Colors.orange
                        : isConfirmed
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                appointment.timeSlot,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _appointmentService.confirmAppointment(appointment.id),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Confirm', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _appointmentService.rejectAppointment(appointment.id),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatientsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _appointmentService.getAllPatients(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allUsers = snapshot.data?.docs ?? [];

        final patients = allUsers.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final role = data['role']?.toString();
          final uid = doc.id;
          return uid != _doctorId && role != 'doctor';
        }).toList();

        if (patients.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'No registered patients yet',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'REGISTERED PATIENTS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final data = patients[index].data() as Map<String, dynamic>;
                    return _buildPatientCard(data);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> data) {
    final firstName = data['firstName']?.toString() ?? '';
    final lastName = data['lastName']?.toString() ?? '';
    final email = data['email']?.toString() ?? '';
    final name = '$firstName $lastName'.trim();
    final displayName = name.isNotEmpty ? name : email.split('@').first;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
            child: Text(
              displayName[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'PATIENT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
