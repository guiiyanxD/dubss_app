import 'package:flutter/material.dart';

import '../config/routes.dart';
import '../config/theme.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Esperar un mínimo de 2 segundos para mostrar el splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Verificar si el usuario está autenticado
    final authService = AuthService();
    final isAuthenticated = await authService.verificarSesion();

    if (mounted) {
      if (isAuthenticated) {
        // Usuario ya está logueado, ir al home
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        // Usuario no está logueado, ir al login
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: 32),

            // Título
            const Text(
              'DUBSS',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 8),

            // Subtítulo
            const Text(
              'Sistema de Gestión de Becas',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 48),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}