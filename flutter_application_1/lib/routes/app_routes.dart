import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/ai_chat_screen.dart';
import '../screens/home/medications_screen.dart';
import '../screens/home/appointment_screen.dart';
import '../screens/home/profile_screen.dart';
import '../screens/home/invite_family_screen.dart';
import '../screens/home/emergency_call_screen.dart';
import '../screens/home/checkin_screen.dart';
import '../screens/doctor/doctor_dashboard.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String aiChat = '/ai-chat';
  static const String medications = '/medications';
  static const String appointments = '/appointments';
  static const String profile = '/profile';
  static const String inviteFamily = '/invite-family';
  static const String emergencyCall = '/emergency-call';
  static const String checkin = '/checkin';
  static const String doctorDashboard = '/doctor-dashboard';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      home: (context) => const HomeScreen(),
      aiChat: (context) => const AiChatScreen(),
      medications: (context) => const MedicationsScreen(),
      appointments: (context) => const AppointmentScreen(),
      profile: (context) => const ProfileScreen(),
      inviteFamily: (context) => const InviteFamilyScreen(),
      emergencyCall: (context) => const EmergencyCallScreen(),
      checkin: (context) => const CheckinScreen(),
      doctorDashboard: (context) => const DoctorDashboard(),
    };
  }
}
