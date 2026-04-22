import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/home_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController otpController = TextEditingController();

  bool otpSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Login")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number (+91...)",
              ),
            ),

            if (otpSent)
              TextField(
                controller: otpController,
                decoration: const InputDecoration(labelText: "Enter OTP"),
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (!otpSent) {
                  await _authService.sendOTP(
                    phoneNumber: phoneController.text,
                    codeSent: (id) {
                      setState(() {
                        otpSent = true;
                      });
                    },
                    error: (msg) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(msg)));
                    },
                  );
                } else {
                  var user = await _authService.verifyOTP(otpController.text);

                  if (user != null) {
                    if (user.displayName == null || user.displayName!.isEmpty) {
                      final nameController = TextEditingController();
                      await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) {
                            return AlertDialog(
                              title: const Text("What's your name?"),
                              content: TextField(
                                controller: nameController,
                                decoration: const InputDecoration(hintText: "Enter your name"),
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () async {
                                    if (nameController.text.trim().isNotEmpty) {
                                      await user.updateDisplayName(nameController.text.trim());
                                      await user.reload();
                                    }
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text("Save"),
                                )
                              ],
                            );
                          }
                      );
                    }

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  }
                }
              },

              child: Text(otpSent ? "Verify OTP" : "Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
