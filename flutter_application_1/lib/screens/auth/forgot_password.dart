// *ForgotPass*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();

  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && args.trim().isNotEmpty) {
        emailController.text = args.trim();
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
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

  Future<void> handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final newPassword = newPasswordController.text;

    try {
      await _authService.resetPassword(email, newPassword);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Password changed successfully.',
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
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.message ?? 'Unable to reset password. Please try again.');
    } catch (_) {
      if (!mounted) return;
      _showErrorSnackBar('An unexpected error occurred. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Premium, low-profile navigation back arrow
            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textDark,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  shape: const CircleBorder(),
                ),
              ),
            ),

            Center(
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
                      // --- PREMIUM INTEGRATED LOGO BRANDING ---
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

                      // --- EDITORIAL HEADERS ---
                      Text(
                        'Reset Password',
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
                        'Please choose a strong, secure password to protect your health records.',
                        style:
                            theme.textTheme.bodyLarge ??
                            const TextStyle(
                              fontSize: 15,
                              color: AppTheme.textMedium,
                            ),
                      ),
                      const SizedBox(height: 32),

                      // --- CORE FORM FIELDS ---
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Field
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
                                  Icons.email_outlined,
                                  color: AppTheme.textMedium,
                                  size: 20,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email address';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // New Password Field
                            TextFormField(
                              controller: newPasswordController,
                              obscureText: obscureNewPassword,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                labelText: 'New Password',
                                prefixIcon: const Icon(
                                  Icons.lock_outlined,
                                  color: AppTheme.textMedium,
                                  size: 20,
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: IconButton(
                                    icon: Icon(
                                      obscureNewPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppTheme.textLight,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                      () => obscureNewPassword =
                                          !obscureNewPassword,
                                    ),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a new password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Confirm Password Field
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: obscureConfirmPassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => handlePasswordReset(),
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: const Icon(
                                  Icons.lock_reset_rounded,
                                  color: AppTheme.textMedium,
                                  size: 20,
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: IconButton(
                                    icon: Icon(
                                      obscureConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppTheme.textLight,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                      () => obscureConfirmPassword =
                                          !obscureConfirmPassword,
                                    ),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your new password';
                                }
                                if (value != newPasswordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- SUBMIT ACTION BUTTON ---
                      ElevatedButton(
                        onPressed: handlePasswordReset,
                        style: theme.elevatedButtonTheme.style,
                        child: const Text('Update Password'),
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
}