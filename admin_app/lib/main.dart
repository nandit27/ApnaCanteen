import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:admin_app/screens/modern_admin_dashboard.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCT1FajldYpzqHckaqPgbSz7YgvKfgHlgU",
        appId: "1:484592064169:web:7dec39216e48f753f9fbb8",
        messagingSenderId: "484592064169",
        projectId: "webapp-ccea9",
        storageBucket: "webapp-ccea9.firebasestorage.app",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: const Color(0xFFFF6B6B),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFFFF6B6B),
        secondary: const Color(0xFFFF9F9F),
      ),
      fontFamily: 'Inter',
    ),
    home: ModernAdminDashboard(),
  ));
}
