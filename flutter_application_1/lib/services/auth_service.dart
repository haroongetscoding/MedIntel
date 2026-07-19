import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String doctorEmail = 'doctor@gmail.com';

  Future<UserCredential> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final role = normalizedEmail == doctorEmail ? 'doctor' : 'patient';

    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'email': normalizedEmail,
      'password': password,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return userCredential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final credential = await _auth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
    if (!doc.exists) {
      final role = normalizedEmail == doctorEmail ? 'doctor' : 'patient';
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'firstName': normalizedEmail.split('@').first,
        'lastName': '',
        'email': normalizedEmail,
        'password': password,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else if (doc.data()?['password'] == null) {
      await doc.reference.update({'password': password});
    }

    return credential;
  }

  Future<String> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data()?['role'] as String? ?? 'patient';
    }
    return 'patient';
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  static Future<void> _seedAccount({
    required String email,
    required String password,
    required String firstName,
    required String role,
  }) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    final previousUser = auth.currentUser;

    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') {
        debugPrint('Failed to seed $email: $e');
        return;
      }
      try {
        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (_) {
        debugPrint('$email exists with different password — not touching Firebase Auth');
        return;
      }
    }

    final user = auth.currentUser;
    if (user != null) {
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'firstName': firstName,
        'lastName': '',
        'email': email.trim().toLowerCase(),
        'password': password,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (previousUser == null || previousUser.uid == user.uid) {
        await auth.signOut();
      }
      debugPrint('$role account seeded: $email');
    }
  }

  static Future<void> seedPatientAccount() =>
      _seedAccount(email: 'aamina@gmail.com', password: '1234567', firstName: 'Aamina', role: 'patient');

  static Future<void> seedDoctorAccount() =>
      _seedAccount(email: doctorEmail, password: '1234567', firstName: 'Doctor', role: 'doctor');

  Future<void> resetPassword(String email, String newPassword) async {
    final normalizedEmail = email.trim().toLowerCase();

    final user = _auth.currentUser;

    if (user != null && user.email?.toLowerCase() == normalizedEmail) {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final storedPassword = snapshot.docs.first.data()['password'] as String?;
        if (storedPassword != null) {
          final authCredential = EmailAuthProvider.credential(
            email: normalizedEmail,
            password: storedPassword,
          );
          await user.reauthenticateWithCredential(authCredential);
          await user.updatePassword(newPassword);
          await snapshot.docs.first.reference.update({'password': newPassword});
          return;
        }
      }

      throw FirebaseAuthException(
        code: 'no-stored-password',
        message: 'Unable to verify your identity. Please sign out and try again.',
      );
    }

    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: normalizedEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No account found with this email.',
      );
    }

    final userData = snapshot.docs.first.data();
    final storedPassword = userData['password'] as String?;

    if (storedPassword == null) {
      throw FirebaseAuthException(
        code: 'no-stored-password',
        message:
            'This account was created before password recovery was available. Please sign in and update your password from settings.',
      );
    }

    final credential = await _auth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: storedPassword,
    );

    await credential.user!.updatePassword(newPassword);

    await snapshot.docs.first.reference.update({'password': newPassword});

    await _auth.signOut();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
