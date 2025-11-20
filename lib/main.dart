import 'package:dubss_android_app/provider/auth_provider.dart';
import 'package:dubss_android_app/provider/convocatoria_provider.dart';
import 'package:dubss_android_app/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
//import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';

class DubssApp extends StatelessWidget {
  const DubssApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        // Aquí puedes agregar más providers en el futuro
        // ChangeNotifierProvider(create: (_) => TramiteProvider()),
        ChangeNotifierProvider(create: (_) => ConvocatoriaProvider()),
      ],
      child: MaterialApp(
        title: 'DUBSS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}

// ============================================
// MAIN FUNCTION
// ============================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar StorageService
  await StorageService().init();

  runApp(const DubssApp());
}