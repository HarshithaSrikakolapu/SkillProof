import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/auth/presentation/auth_provider.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/auth/presentation/screens/signup_screen.dart';
import 'package:frontend/features/skills/presentation/screens/skills_list_screen.dart';
import 'package:frontend/features/credentials/presentation/screens/credential_list_screen.dart';
import 'package:frontend/features/certificates/presentation/screens/user_certificates_screen.dart';
import 'package:frontend/features/employer/presentation/screens/employer_dashboard_screen.dart';
import 'package:frontend/features/analytics/presentation/screens/analytics_screen.dart';

import 'package:frontend/core/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillProof',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const SignupScreen(),
        '/home': (context) => const SkillsListScreen(),
        '/user_certificates': (context) => const CertificateListScreen(),
        '/credentials': (context) => const CredentialListScreen(),
        '/employer_dashboard': (context) => const EmployerDashboardScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
      },
    );
  }
}
