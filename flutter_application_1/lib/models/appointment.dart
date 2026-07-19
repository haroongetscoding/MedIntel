class Appointment {
  final String id;
  final String doctorId;
  final String doctorEmail;
  final String doctorName;
  final String patientId;
  final String patientName;
  final String patientEmail;
  final DateTime date;
  final String timeSlot;
  String status;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorEmail,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.patientEmail,
    required this.date,
    required this.timeSlot,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorEmail': doctorEmail,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'date': date,
      'timeSlot': timeSlot,
      'status': status,
      'createdAt': DateTime.now(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map, String documentId) {
    return Appointment(
      id: documentId,
      doctorId: map['doctorId'] as String? ?? '',
      doctorEmail: map['doctorEmail'] as String? ?? '',
      doctorName: map['doctorName'] as String? ?? '',
      patientId: map['patientId'] as String? ?? '',
      patientName: map['patientName'] as String? ?? '',
      patientEmail: map['patientEmail'] as String? ?? '',
      date: (map['date'] as dynamic)?.toDate() ?? DateTime.now(),
      timeSlot: map['timeSlot'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
    );
  }
}
