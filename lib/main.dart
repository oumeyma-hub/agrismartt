import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrismart/config.dart';
import 'package:agrismart/firebase_options.dart';

import 'package:agrismart/providers/auth_provider.dart';
import 'package:agrismart/providers/zones_provider.dart';
import 'package:agrismart/providers/meteo_provider.dart';
import 'package:agrismart/providers/reglages_provider.dart';

import 'package:agrismart/screens/auth_gate.dart';

import 'package:agrismart/services/auth_locale_service.dart';
import 'package:agrismart/services/auth_service.dart';
import 'package:agrismart/services/firebase_auth_service.dart';

import 'package:agrismart/theme/app_theme.dart';

Future<void> main() async {
  // Initialisation de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation du stockage local
  final prefs = await SharedPreferences.getInstance();

  // Initialisation du service d'authentification
  final AuthService authService;

  if (utiliserFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    authService = FirebaseAuthService();
  } else {
    authService = AuthLocaleService();
  }

  // Initialisation des Providers
  runApp(
    MultiProvider(
      providers: [
        // Provider d'authentification
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),

        // Provider des zones agricoles
        ChangeNotifierProvider(
          create: (context) =>
              ZonesProvider(prefs, context.read<AuthProvider>()),
        ),

        // Provider des données météorologiques avec cache local
        ChangeNotifierProvider(
          create: (_) => MeteoProvider(prefs: prefs)..charger(),
        ),

        // Provider des préférences utilisateur
        ChangeNotifierProvider(create: (_) => ReglagesProvider(prefs)),
      ],
      child: const AgriSmartApp(),
    ),
  );
}

// Application principale
class AgriSmartApp extends StatelessWidget {
  const AgriSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriSmart',

      // Thème clair
      theme: AppTheme.clair(),

      // Thème sombre
      darkTheme: AppTheme.sombre(),

      // Thème choisi par l'utilisateur
      themeMode: context.watch<ReglagesProvider>().themeMode,

      // Écran de démarrage
      home: const AuthGate(),
    );
  }
}
