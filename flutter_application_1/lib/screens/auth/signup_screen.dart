import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _authService.signUp(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          email: emailController.text,
          password: passwordController.text,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Registration successfully processed!',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        switch (e.code) {
          case 'email-already-in-use':
            _showErrorSnackBar('This email is already registered. Please sign in instead.');
            break;
          case 'weak-password':
            _showErrorSnackBar('Please choose a stronger password.');
            break;
          case 'invalid-email':
            _showErrorSnackBar('Please enter a valid email address.');
            break;
          case 'network-request-failed':
            _showErrorSnackBar('Network error. Please check your connection and try again.');
            break;
          default:
            _showErrorSnackBar('Registration failed. Please try again.');
            break;
        }
      } catch (_) {
        if (!mounted) return;
        _showErrorSnackBar('An unexpected error occurred. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              Positioned(
                top: -50,
                left: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1962A1),
                  ),
                ),
              ),
              Positioned(
                top: -20,
                left: 70,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF90CAF9),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 3),
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF1962A1),
                                      width: 6,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF90CAF9),
                                      width: 6,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'MED INTEL',
                              style: TextStyle(
                                color: Color(0xFF1962A1),
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 2),
                      TextFormField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                          labelText: 'FIRST NAME',
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Enter your first name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          labelText: 'LAST NAME',
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Enter your last name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'EMAIL ID',
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Enter your email id'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'PASSWORD',
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) =>
                            (value == null || value.length < 6)
                                ? 'Password must be at least 6 characters'
                                : null,
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: handleRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1962A1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(flex: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? '),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Color(0xFF1962A1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}