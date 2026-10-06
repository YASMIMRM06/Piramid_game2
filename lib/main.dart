import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'core/di/dependency_injection.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase precisa ser inicializado ANTES da injeção de dependências,
  // pois FirebaseAuth/FirebaseFirestore são registrados no injector.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  setupInjection();

  // Carrega tema salvo (SharedPreferences)
  try {
    final themeController = injector.get<ThemeController>();
    await themeController.loadTheme();
  } catch (e) {
    debugPrint('[main] Erro ao carregar tema: $e');
  }

  runApp(const PiramidGameApp());
}

class PiramidGameApp extends StatelessWidget {
  const PiramidGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = injector.get<ThemeController>();

    return Watch(
      (_) => MaterialApp.router(
        title: 'PiramidGame IFPR-Pgua',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeController.themeMode.value,
        routerConfig: appRouter,
      ),
    );
  }
}
