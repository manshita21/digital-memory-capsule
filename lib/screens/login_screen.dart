import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'phone_login_screen.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Digital Memory Capsule")),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                var user = await _authService.signInWithGoogle();

                if (user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Logged in as ${user.displayName}")),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                }
              },
              child: const Text("Sign in with Google"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PhoneLoginScreen(),
                  ),
                );
              },
              child: const Text("Login with Phone"),
            ),
          ],
        ),
      ),
    );
  }
}
