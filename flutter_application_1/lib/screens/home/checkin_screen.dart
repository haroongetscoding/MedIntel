import 'package:flutter/material.dart';
import '../../services/checkin_service.dart';
import '../../models/checkin.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({Key? key}) : super(key: key);

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final CheckinService _checkinService = CheckinService();
  final TextEditingController _notesController = TextEditingController();

  Checkin? _todayCheckin;
  List<Checkin> _recentCheckins = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  int _selectedMoodScore = 5;
  String _selectedMoodLabel = 'Good';
  List<String> _selectedSymptoms = [];

  final List<String> _symptomOptions = [
    'Headache', 'Fever', 'Cough', 'Fatigue', 'Nausea',
    'Body ache', 'Sore throat', 'Dizziness', 'Chest pain', 'None',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final today = await _checkinService.getTodayCheckin();
    final recent = await _checkinService.getLast7Checkins();
    if (!mounted) return;
    setState(() {
      _todayCheckin = today;
      _recentCheckins = recent;
      _isLoading = false;
    });
  }

  Future<void> _submitCheckin() async {
    setState(() => _isSubmitting = true);
    try {
      await _checkinService.submitCheckin(
        moodScore: _selectedMoodScore,
        moodLabel: _selectedMoodLabel,
        symptoms: _selectedSymptoms.contains('None') ? [] : _selectedSymptoms,
        notes: _notesController.text.trim(),
      );
      await _loadData();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _isSubmitting = false);
  }

  List<Map<String, dynamic>> _buildWeekDays() {
    final today = DateTime.now().toUtc().subtract(const Duration(hours: 5));
    List<Map<String, dynamic>> days = [];
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final dateKey = CheckinService.dateKeyFor(day);
      final checkin = _recentCheckins.where((c) => c.dateKey == dateKey).firstOrNull;
      final isToday = i == 0;
      days.add({
        'dateKey': dateKey,
        'dayName': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1],
        'dayNum': day.day,
        'isToday': isToday,
        'checkedIn': checkin != null,
        'checkin': checkin,
      });
    }
    return days;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1962A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: const Text(
          'Daily Check-in',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWeekGrid(primaryColor),
                  const SizedBox(height: 24),
                  if (_todayCheckin == null) _buildCheckinForm(primaryColor),
                ],
              ),
            ),
    );
  }

  Widget _buildWeekGrid(Color primaryColor) {
    final days = _buildWeekDays();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THIS WEEK',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1.0),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isCheckedIn = day['checkedIn'] as bool;
              final isToday = day['isToday'] as bool;
              return Column(
                children: [
                  Text(
                    day['dayName'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isToday ? primaryColor : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCheckedIn
                          ? const Color(0xFF22C55E)
                          : (isToday ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9)),
                      border: isToday && !isCheckedIn
                          ? Border.all(color: const Color(0xFFEF4444), width: 2)
                          : null,
                    ),
                    child: Center(
                      child: isCheckedIn
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : Text(
                              '${day['dayNum']}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isToday ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isCheckedIn)
                    Text(
                      day['checkin']?.moodLabel ?? '',
                      style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                ],
              );
            }).toList(),
          ),
          if (_todayCheckin != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Checked in today — feeling $_selectedMoodLabel',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF166534), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckinForm(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "HOW ARE YOU FEELING?",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1.0),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _moodOption('Awful', 2, '☹', const Color(0xFFFEE2E2), const Color(0xFFEF4444)),
              _moodOption('Tired', 4, '😴', const Color(0xFFFEF3C7), const Color(0xFFF59E0B)),
              _moodOption('Good', 7, '☺', const Color(0xFFE0F2FE), const Color(0xFF0284C7)),
              _moodOption('Great', 9, '✌︎', const Color(0xFFDCFCE7), const Color(0xFF22C55E)),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "ANY SYMPTOMS?",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1.0),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _symptomOptions.map((symptom) {
              final selected = _selectedSymptoms.contains(symptom);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (symptom == 'None') {
                      _selectedSymptoms = ['None'];
                    } else {
                      _selectedSymptoms.remove('None');
                      if (selected) {
                        _selectedSymptoms.remove(symptom);
                      } else {
                        _selectedSymptoms.add(symptom);
                      }
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? primaryColor : const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    symptom,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            "NOTES (OPTIONAL)",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1.0),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'How was your day? Any concerns?',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitCheckin,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('SUBMIT CHECK-IN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _moodOption(String label, int score, String emoji, Color bg, Color activeColor) {
    final selected = _selectedMoodLabel == label;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedMoodLabel = label;
        _selectedMoodScore = score;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? bg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? activeColor.withOpacity(0.5) : const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: selected
              ? [BoxShadow(color: activeColor.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                color: selected ? activeColor : const Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
