import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final credential = await _authService.login(
          email: emailController.text,
          password: passwordController.text,
        );

        if (!mounted) return;
        final role = await _authService.getUserRole(credential.user!.uid);

        if (!mounted) return;
        if (role == 'doctor') {
          Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        switch (e.code) {
          case 'user-not-found':
            _showErrorSnackBar('No account found for this email.');
            break;
          case 'wrong-password':
            _showErrorSnackBar('Incorrect password. Please try again.');
            break;
          case 'invalid-email':
            _showErrorSnackBar('Please enter a valid email address.');
            break;
          case 'invalid-credential':
            _showErrorSnackBar('The email or password is invalid.');
            break;
          case 'network-request-failed':
            _showErrorSnackBar(
                'Network error. Please check your connection and try again.');
            break;
          default:
            _showErrorSnackBar('Login failed. Please try again.');
            break;
        }
      } catch (_) {
        if (!mounted) return;
        _showErrorSnackBar('An unexpected error occurred. Please try again.');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
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

  void handleForgotPassword() {
    Navigator.pushNamed(
      context,
      '/forgot-password',
      arguments: emailController.text.trim().contains('@')
          ? emailController.text.trim()
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            Container(
                              width: 12,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.accentLightBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'MEDINTEL',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Welcome back',
                    style:
                        theme.textTheme.headlineLarge ??
                        const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to securely access your health dashboard.',
                    style:
                        theme.textTheme.bodyLarge ??
                        const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textMedium,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(
                              Icons.mail_outline_rounded,
                              color: AppTheme.textMedium,
                              size: 20,
                            ),
                          ),
                          validator: (value) =>
                              (value == null || !value.contains('@'))
                              ? 'Please enter a valid email address'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => handleLogin(),
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(
                              Icons.lock_outlined,
                              color: AppTheme.textMedium,
                              size: 20,
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.textLight,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => obscurePassword = !obscurePassword,
                                ),
                              ),
                            ),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Password field cannot be empty'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: handleForgotPassword,
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "New to MedIntel? ",
                        style: TextStyle(
                          color: AppTheme.textMedium,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/signup'),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
