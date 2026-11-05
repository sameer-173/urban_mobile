import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/auth/auth_service.dart';
import 'modules/auth/views/login_screen.dart';
import 'modules/dashboard/views/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  final loggedIn = await authService.isLoggedIn();

  runApp(UrbanMobileApp(isLoggedIn: loggedIn));
}

class UrbanMobileApp extends StatelessWidget {
  final bool isLoggedIn;
  const UrbanMobileApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PUROJAS Urban ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
