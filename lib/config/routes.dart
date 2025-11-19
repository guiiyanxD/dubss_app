import 'package:flutter/material.dart';

import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String convocatorias = '/convocatorias';
  static const String misTramites = '/mis-tramites';
  static const String turnos = '/turnos';
  static const String perfil = '/perfil';
  static const String notificaciones = '/notificaciones';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      home: (context) => const HomeScreen(),
      // TODO: Agregar las demás pantallas cuando estén listas
      // convocatorias: (context) => const ConvocatoriasScreen(),
      // perfil: (context) => const PerfilScreen(),
      // notificaciones: (context) => const NotificacionesScreen(),
    };
  }
}