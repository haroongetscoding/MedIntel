import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medication.dart';

class MedicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference _medicationsRef() {
    final uid = _userId;
    if (uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('medications');
  }

  Stream<List<Medication>> getMedicationsStream() {
    return _medicationsRef()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Medication.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addMedication({
    required String name,
    String dosage = '',
    required String timeSlot,
    required String medTime,
    DateTime? scheduledDate,
  }) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not authenticated');

    await _medicationsRef().add({
      'userId': uid,
      'name': name,
      'dosage': dosage,
      'timeSlot': timeSlot,
      'medTime': medTime,
      'isTaken': false,
      'scheduledDate': scheduledDate,
      'createdAt': FieldValue.serverTimestamp(),
      'takenAt': null,
    });
  }

  Future<void> toggleTaken(String medicationId, bool isTaken) async {
    await _medicationsRef().doc(medicationId).update({
      'isTaken': isTaken,
      'takenAt': isTaken ? FieldValue.serverTimestamp() : null,
    });
  }

  Future<void> deleteMedication(String medicationId) async {
    await _medicationsRef().doc(medicationId).delete();
  }

  Future<void> updateMedication({
    required String medicationId,
    String? name,
    String? dosage,
    String? timeSlot,
    String? medTime,
  }) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (dosage != null) updates['dosage'] = dosage;
    if (timeSlot != null) updates['timeSlot'] = timeSlot;
    if (medTime != null) updates['medTime'] = medTime;

    if (updates.isNotEmpty) {
      await _medicationsRef().doc(medicationId).update(updates);
    }
  }
}
