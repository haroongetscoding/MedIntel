import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AuthService.seedDoctorAccount();
  await AuthService.seedPatientAccount();

  // Set system-level UI overlays to feel premium and integrated with the hardware
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Lock device orientation to portrait for a highly tailored, predictable UI experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MedIntelApp());
}

class MedIntelApp extends StatelessWidget {
  const MedIntelApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedIntel',
      debugShowCheckedModeBanner: false,

      // Using only your existing light theme setup
      theme: AppTheme.lightTheme,

      // Maintaining your existing routes
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,

      // Prevent system font scaling from affecting layout
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}