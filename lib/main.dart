import 'package:finstagram/pages/home_pages.dart';
import 'package:finstagram/pages/login_page.dart';
import 'package:finstagram/pages/register_pages.dart';
import 'package:finstagram/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'services/firebase_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options for web
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCsrwYclWTIL2ivRlqbC5PucqOmVrCumdE",
          authDomain: "finstagram-2020b.firebaseapp.com",
          projectId: "finstagram-2020b",
          storageBucket: "finstagram-2020b.firebasestorage.app",
          messagingSenderId: "435187250037",
          appId: "1:435187250037:web:c4274e4d636a51b3e6d93c",
          measurementId: "G-S6500L0WFX"
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  GetIt.instance.registerSingleton<FirebaseService>(FirebaseService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finstagram',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/splash',
      debugShowCheckedModeBanner: false,
      routes: {
        '/splash': (context) => const SplashScreen(), // Assuming you have a splash page
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
