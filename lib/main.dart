import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'login_screen.dart';
import 'home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: _authService.getCurrentUser() != null
          ? HomeScreen()
          : LoginScreen(),
    );
  }
}
