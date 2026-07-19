import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _appointmentsRef() =>
      _firestore.collection('appointments');

  Future<void> bookAppointment({
    required String doctorId,
    required String doctorEmail,
    required String doctorName,
    required String patientId,
    required String patientName,
    required String patientEmail,
    required DateTime date,
    required String timeSlot,
  }) async {
    await _appointmentsRef().add({
      'doctorId': doctorId,
      'doctorEmail': doctorEmail,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'date': date,
      'timeSlot': timeSlot,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Appointment>> getAppointmentsForPatient(String patientId) {
    return _appointmentsRef()
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return Appointment.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Stream<List<Appointment>> getAppointmentsForDoctor(String doctorId) {
    return _appointmentsRef()
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return Appointment.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  Future<void> confirmAppointment(String appointmentId) async {
    await _appointmentsRef().doc(appointmentId).update({'status': 'confirmed'});
  }

  Future<void> rejectAppointment(String appointmentId) async {
    await _appointmentsRef().doc(appointmentId).update({'status': 'rejected'});
  }

  Stream<QuerySnapshot> getAllPatients() {
    return _firestore.collection('users').snapshots();
  }

  Future<String?> getDoctorIdByEmail(String email) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .where('role', isEqualTo: 'doctor')
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    }
    return null;
  }
}
