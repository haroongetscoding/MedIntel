import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/checkin.dart';

class CheckinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference? _checkinsRef() {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('checkins');
  }

  static String getUtc5DateKey() {
    final utcNow = DateTime.now().toUtc();
    final utc5Now = utcNow.subtract(const Duration(hours: 5));
    return '${utc5Now.year}-${utc5Now.month.toString().padLeft(2, '0')}-${utc5Now.day.toString().padLeft(2, '0')}';
  }

  static String dateKeyFor(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<Checkin?> getTodayCheckin() async {
    final ref = _checkinsRef();
    if (ref == null) return null;
    final dateKey = getUtc5DateKey();
    final snapshot = await ref.where('dateKey', isEqualTo: dateKey).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return Checkin.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<List<Checkin>> getLast7Checkins() async {
    final ref = _checkinsRef();
    if (ref == null) return [];
    final today = getUtc5DateKey();
    final snapshot = await ref.where('dateKey', isLessThanOrEqualTo: today).orderBy('dateKey', descending: true).limit(7).get();
    return snapshot.docs.map((doc) => Checkin.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Stream<List<Checkin>> getCheckinsStream() {
    try {
      final ref = _checkinsRef();
      if (ref == null) return const Stream.empty();
      return ref.orderBy('dateKey', descending: true).snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Checkin.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      });
    } catch (_) {
      return const Stream.empty();
    }
  }

  Future<void> submitCheckin({
    required int moodScore,
    required String moodLabel,
    List<String> symptoms = const [],
    String notes = '',
  }) async {
    final ref = _checkinsRef();
    if (ref == null) return;

    final dateKey = getUtc5DateKey();
    final existing = await getTodayCheckin();
    if (existing != null) return;

    final uid = _userId;
    await ref.add({
      'userId': uid,
      'dateKey': dateKey,
      'moodScore': moodScore,
      'moodLabel': moodLabel,
      'symptoms': symptoms,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
