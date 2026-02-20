import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../services/capsule_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final CapsuleService _capsuleService = CapsuleService();

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

      body: Center(
       child:Column(
         children: [
            Text("Welcome to Digital Memory Capsule"),
           ElevatedButton(
             onPressed: () async {

               await _capsuleService.createCapsule(
                 title: "My First Capsule",
                 unlockDate: DateTime.now().add(Duration(days: 30)),
                 isShared: false,
               );

               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text("Capsule Created")),
               );

             },
             child: Text("Create Capsule"),
           ),
         ],
       )
      )
    );
  }
}
