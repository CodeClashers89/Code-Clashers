import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/citizen_home.dart';
import 'screens/doctor_dashboard.dart';
import 'screens/city_staff_dashboard.dart';
import 'screens/agri_officer_dashboard.dart';
import 'services/auth_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const DPIApp(),
    ),
  );
}

class DPIApp extends StatelessWidget {
  const DPIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DPI Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2563EB),
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/citizen': (context) => const CitizenHome(),
        '/doctor': (context) => const DoctorDashboard(),
        '/city-staff': (context) => const CityStaffDashboard(),
        '/agri-officer': (context) => const AgriOfficerDashboard(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.isAuthenticated) {
          // Route based on user role
          switch (authService.userRole) {
            case 'citizen':
              return const CitizenHome();
            case 'doctor':
              return const DoctorDashboard();
            case 'city_staff':
              return const CityStaffDashboard();
            case 'agri_officer':
              return const AgriOfficerDashboard();
            default:
              return const LoginScreen();
          }
        }
        return const LoginScreen();
      },
    );
  }
}
