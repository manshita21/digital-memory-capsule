import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class LoginScreen extends StatelessWidget {

  LoginScreen({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Digital Memory Capsule"),
      ),

      body: Center(

        child: ElevatedButton(

          onPressed: () async {

            var user =
            await _authService.signInWithGoogle();

            if (user != null) {

              ScaffoldMessenger.of(context)
                  .showSnackBar(
                SnackBar(
                  content: Text(
                      "Logged in as ${user.displayName}"),
                ),
              );

            }

          },

          child: const Text("Sign in with Google"),

        ),

      ),

    );

  }

}
