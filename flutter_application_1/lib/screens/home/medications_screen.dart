import 'package:flutter/material.dart';
import '../../models/medication.dart';
import '../../services/medication_service.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({Key? key}) : super(key: key);

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final MedicationService _medicationService = MedicationService();

  int selectedDayIndex = 2;
  String selectedFilter = 'All';

  final TextEditingController _medInputController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  String _selectedTimeSlot = '8:00';

  final List<Map<String, String>> daysData = [
    {'month': 'JAN', 'day': '09', 'week': 'Fri'},
    {'month': 'FEB', 'day': '10', 'week': 'Sat'},
    {'month': 'MAR', 'day': '11', 'week': 'Sun'},
    {'month': 'APR', 'day': '12', 'week': 'Mon'},
    {'month': 'MAY', 'day': '13', 'week': 'Tue'},
    {'month': 'JUN', 'day': '14', 'week': 'Wed'},
  ];

  @override
  void dispose() {
    _medInputController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _addNewMedication() async {
    final String text = _medInputController.text.trim();
    if (text.isEmpty) return;

    try {
      await _medicationService.addMedication(
        name: text,
        dosage: _dosageController.text.trim(),
        timeSlot: _selectedTimeSlot,
        medTime: '$_selectedTimeSlot am',
      );
      _medInputController.clear();
      _dosageController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medication added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add medication: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleMedication(Medication med) async {
    try {
      await _medicationService.toggleTaken(med.id, !med.isTaken);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1962A1);

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
                padding: const EdgeInsets.only(
                  top: 60.0,
                  left: 24.0,
                  right: 24.0,
                  bottom: 24.0,
                ),
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
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Med Reminders',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 64,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: daysData.length,
                          itemBuilder: (context, index) {
                            bool isSelected = index == selectedDayIndex;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedDayIndex = index;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 52,
                                margin: const EdgeInsets.only(
                                  right: 8,
                                  top: 4,
                                  bottom: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryColor
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      daysData[index]['day']!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      daysData[index]['week']!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected
                                            ? Colors.white70
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Medicine Timeline',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedFilter,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: primaryColor,
                                ),
                                dropdownColor: Colors.white,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                                items: <String>['All', 'Taken', 'Pending'].map((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedFilter = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _medInputController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Add real-time med e.g. Panadol',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: primaryColor,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _dosageController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Dosage',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    color: primaryColor,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedTimeSlot,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                                items: ['8:00', '9:00', '10:00', '11:00'].map((
                                  String val,
                                ) {
                                  return DropdownMenuItem(
                                    value: val,
                                    child: Text(val),
                                  );
                                }).toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedTimeSlot = v!),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: _addNewMedication,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: StreamBuilder<List<Medication>>(
                          stream: _medicationService.getMedicationsStream(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error loading medications: ${snapshot.error}',
                                  style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            }

                            final medications = snapshot.data ?? [];

                            final filteredMeds = medications.where((med) {
                              if (selectedFilter == 'Taken') {
                                return med.isTaken;
                              }
                              if (selectedFilter == 'Pending') {
                                return !med.isTaken;
                              }
                              return true;
                            }).toList();

                            if (filteredMeds.isEmpty) {
                              return Center(
                                child: Text(
                                  medications.isEmpty
                                      ? 'No medications added yet.\nAdd one above!'
                                      : 'No medicines match your filter.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: filteredMeds.length,
                              itemBuilder: (context, index) {
                                final med = filteredMeds[index];
                                return _buildMedicineTimelineCard(
                                  med.timeSlot,
                                  med.dosage.isEmpty
                                      ? med.name
                                      : '${med.name}\n${med.dosage}',
                                  med.medTime,
                                  med.isTaken,
                                  primaryColor,
                                  onToggleTaken: () => _toggleMedication(med),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineTimelineCard(
    String timeSlot,
    String medTitle,
    String medTime,
    bool isTaken,
    Color primaryColor, {
    required VoidCallback onToggleTaken,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Text(
                timeSlot,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(width: 1.5, height: 12, color: Colors.grey.shade200),
              Icon(
                isTaken ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 13,
                color: isTaken ? primaryColor : Colors.grey.shade300,
              ),
              Expanded(
                child: Container(width: 1.5, color: Colors.grey.shade200),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isTaken
                    ? const Color(0xFFE0F2FE).withOpacity(0.5)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isTaken
                      ? const Color(0xFFBAE6FD)
                      : Colors.grey.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          medTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            height: 1.3,
                            color: isTaken ? Colors.black54 : Colors.black87,
                            decoration: isTaken
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medTime,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: onToggleTaken,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isTaken
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_off_rounded,
                            color: primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isTaken ? 'Taken' : 'Take it',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
