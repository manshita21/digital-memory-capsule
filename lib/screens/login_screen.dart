import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'phone_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                    const Color(0xFFB993D6),
                    const Color(0xFF8CA6DB),
                    _controller.value,
                  )!,
                  Color.lerp(
                    const Color(0xFFE0C3FC),
                    const Color(0xFF8EC5FC),
                    _controller.value,
                  )!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          );
        },

        // 👇 UI CONTENT
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // 🎬 LOTTIE ANIMATION
                Lottie.asset(
                  'assets/animations/memory.json',
                  height: 200,
                ),

                const SizedBox(height: 20),

                // 🧠 HEADING
                const Text(
                  "Digital Memory Capsule",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                const Text(
                  "Preserve your memories forever",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFF5F7FF),
                  ),
                ),

                const SizedBox(height: 40),

                // ✨ GOOGLE BUTTON
                _buildButton(
                  text: "Sign in with Google",
                  onPressed: () async {
                    var user = await _authService.signInWithGoogle();

                    if (user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomeScreen()),
                      );
                    }
                  },
                ),

                const SizedBox(height: 20),

                // ✨ PHONE BUTTON
                _buildButton(
                  text: "Login with Phone",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const PhoneLoginScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🧊 MODERN BUTTON WIDGET
  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(0.55),
        border: Border.all(color: Colors.white30),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}