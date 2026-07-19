import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';
import '../../theme/app_theme.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime focusedMonth = DateTime.now();
  int? selectedDay = DateTime.now().day;
  String? selectedTimeSlot;
  bool _isBooking = false;
  bool _isLoadingDoctor = true;

  String _patientId = '';
  String _patientName = '';
  String _patientEmail = '';

  String? _doctorId;
  String _doctorName = 'Loading...';
  String _doctorEmail = '';

  final List<String> weekdays = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];
  final List<String> monthsList = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
    'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
  ];
  final List<String> timeSlots = [
    '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserAndDoctor();
  }

  Future<void> _loadUserAndDoctor() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _patientId = user.uid;
      _patientEmail = user.email ?? '';
    });

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (userDoc.exists) {
      final data = userDoc.data()!;
      final firstName = data['firstName']?.toString() ?? '';
      final lastName = data['lastName']?.toString() ?? '';
      setState(() {
        _patientName = '$firstName $lastName'.trim();
        if (_patientName.isEmpty) _patientName = _patientEmail.split('@').first;
      });
    }

    final doctorSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .limit(1)
        .get();

    if (doctorSnapshot.docs.isNotEmpty && mounted) {
      final docData = doctorSnapshot.docs.first.data();
      _doctorId = doctorSnapshot.docs.first.id;
      _doctorEmail = docData['email']?.toString() ?? 'doctor@gmail.com';
      final docFirstName = docData['firstName']?.toString() ?? '';
      final docLastName = docData['lastName']?.toString() ?? '';
      _doctorName = '$docFirstName $docLastName'.trim();
      if (_doctorName.isEmpty) _doctorName = 'Doctor';
      setState(() => _isLoadingDoctor = false);
    } else if (mounted) {
      setState(() => _isLoadingDoctor = false);
    }
  }

  List<int?> _generateMonthlyDaysGrid(DateTime date) {
    int firstDayOffset = DateTime(date.year, date.month, 1).weekday % 7;
    int totalDays = DateUtils.getDaysInMonth(date.year, date.month);
    List<int?> grid = List.filled(firstDayOffset, null, growable: true);
    for (int day = 1; day <= totalDays; day++) {
      grid.add(day);
    }
    return grid;
  }

  Future<void> _bookAppointment() async {
    if (selectedDay == null || selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time slot.')),
      );
      return;
    }

    if (_doctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No doctor available in the system.')),
      );
      return;
    }

    final isSunday =
        DateTime(focusedMonth.year, focusedMonth.month, selectedDay!).weekday ==
        DateTime.sunday;

    if (isSunday) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Doctor Unavailable'),
          content: const Text(
            'Clinics are closed on Sundays. Please select a weekday.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      final bookingDate = DateTime(
        focusedMonth.year,
        focusedMonth.month,
        selectedDay!,
      );

      await _appointmentService.bookAppointment(
        doctorId: _doctorId!,
        doctorEmail: _doctorEmail,
        doctorName: _doctorName,
        patientId: _patientId,
        patientName: _patientName,
        patientEmail: _patientEmail,
        date: bookingDate,
        timeSlot: selectedTimeSlot!,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Appointment Booked!'),
          content: Text(
            'Your appointment with $_doctorName on $selectedDay ${monthsList[focusedMonth.month - 1]} ${focusedMonth.year} at $selectedTimeSlot has been submitted.\n\nThe doctor will confirm your appointment.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1962A1);
    final calculatedGrid = _generateMonthlyDaysGrid(focusedMonth);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Book Appointment',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Schedule a visit with your doctor.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_hospital_rounded,
                                size: 16,
                                color: AppTheme.primaryBlue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _isLoadingDoctor
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _doctorId == null
                                            ? 'No doctor available'
                                            : 'Doctor: $_doctorName',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Text(
                                      '${monthsList[focusedMonth.month - 1]} ${focusedMonth.year}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_back_ios,
                                          size: 14,
                                          color: primaryColor,
                                        ),
                                        onPressed: () => setState(
                                          () => focusedMonth = DateTime(
                                            focusedMonth.year,
                                            focusedMonth.month - 1,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: primaryColor,
                                        ),
                                        onPressed: () => setState(
                                          () => focusedMonth = DateTime(
                                            focusedMonth.year,
                                            focusedMonth.month + 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: weekdays
                                    .map(
                                      (day) => Expanded(
                                        child: Text(
                                          day,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 8),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: calculatedGrid.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 7,
                                      mainAxisSpacing: 6,
                                      crossAxisSpacing: 6,
                                    ),
                                itemBuilder: (context, index) {
                                  final currentDay = calculatedGrid[index];
                                  if (currentDay == null)
                                    return const SizedBox.shrink();

                                  final isSelected = currentDay == selectedDay;
                                  final isPast = DateTime(
                                        focusedMonth.year,
                                        focusedMonth.month,
                                        currentDay,
                                      ).isBefore(
                                        DateTime.now().subtract(
                                          const Duration(days: 1),
                                        ),
                                      );

                                  return Center(
                                    child: GestureDetector(
                                      onTap: isPast
                                          ? null
                                          : () => setState(
                                              () => selectedDay = currentDay,
                                            ),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? primaryColor
                                              : Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.transparent
                                                : Colors.grey.shade200,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          currentDay.toString(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Colors.white
                                                : (isPast
                                                    ? Colors.grey.shade300
                                                    : Colors.black87),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: const Text(
                                'Select Time Slot',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value: selectedTimeSlot,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: primaryColor,
                              ),
                              dropdownColor: Colors.white,
                              items: timeSlots
                                  .map(
                                    (slot) => DropdownMenuItem(
                                      value: slot,
                                      child: Text(
                                        slot,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => selectedTimeSlot = val),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: (_isBooking || _doctorId == null)
                                ? null
                                : _bookAppointment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isBooking
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Book Appointment',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<List<Appointment>>(
                          stream: _appointmentService
                              .getAppointmentsForPatient(_patientId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox.shrink();
                            }
                            final appointments = snapshot.data ?? [];
                            if (appointments.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                const SizedBox(height: 8),
                                const Text(
                                  'YOUR APPOINTMENTS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.grey,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...appointments.map(
                                  (a) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: a.status == 'confirmed'
                                            ? Colors.green.shade200
                                            : a.status == 'rejected'
                                                ? Colors.red.shade200
                                                : Colors.orange.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${a.date.month}/${a.date.day}/${a.date.year}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                a.timeSlot,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: a.status == 'confirmed'
                                                ? Colors.green.shade50
                                                : a.status == 'rejected'
                                                    ? Colors.red.shade50
                                                    : Colors.orange.shade50,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            a.status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: a.status == 'confirmed'
                                                  ? Colors.green
                                                  : a.status == 'rejected'
                                                      ? Colors.red
                                                      : Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
