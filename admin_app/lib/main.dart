import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:admin_app/screens/modern_admin_dashboard.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "",
        appId: "",
        messagingSenderId: "484592064169",
        projectId: "",
        storageBucket: "",
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
