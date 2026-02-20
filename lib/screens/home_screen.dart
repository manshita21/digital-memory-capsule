import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../services/capsule_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final CapsuleService _capsuleService = CapsuleService();

  final TextEditingController inviteController =
  TextEditingController();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),


    body: Padding(
      padding: const EdgeInsets.all(20),

      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Text("Welcome to Digital Memory Capsule"),
          ElevatedButton(

            onPressed: () async {

              String? inviteCode = await _capsuleService.createCapsule(
                title: "My Shared Capsule",
                unlockDate: DateTime.now().add(Duration(days: 30)),
                isShared: true,
              );

              if (inviteCode != null && inviteCode.isNotEmpty) {

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(

                    title: Text("Invite Code"),

                    content: SelectableText(
                      inviteCode,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("OK"),
                      )
                    ],

                  ),
                );

              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Shared Capsule Created")),
              );

            },

            child: Text("Create Shared Capsule"),

          ),

          SizedBox(height: 20),

          TextField(
            controller: inviteController,
            decoration: InputDecoration(
              labelText: "Enter Invite Code",
              border: OutlineInputBorder(),
            ),
          ),

          SizedBox(height: 10),

          ElevatedButton(

            onPressed: () async {

              bool success =
              await _capsuleService.joinCapsule(
                  inviteController.text.trim());

              ScaffoldMessenger.of(context).showSnackBar(

                SnackBar(
                  content: Text(
                    success
                        ? "Joined capsule successfully"
                        : "Invalid invite code",
                  ),
                ),

              );

            },

            child: Text("Join Capsule"),

          ),

        ],

      ),

    ),

    );
  }
}
