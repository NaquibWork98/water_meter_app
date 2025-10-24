import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart'; 
import '../bloc/auth_state.dart';  
import 'login_page.dart';
import '../../../meter_reading/presentation/pages/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Check if user is logged in
    context.read<AuthBloc>().add(CheckAuthStatus());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (state is AuthUnauthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A3A52),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.water_drop,
                  size: 80,
                  color: Color(0xFF4A90E2),
                ),
              ),
              const SizedBox(height: 32),
              
              // App Name
              const Text(
                'Meter Reading',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Application',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 48),
              
              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}