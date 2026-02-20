import 'package:flutter/material.dart';
import '../services/capsule_service.dart';

class CreateCapsuleScreen extends StatefulWidget {
  const CreateCapsuleScreen({super.key});

  @override
  State<CreateCapsuleScreen> createState() =>
      _CreateCapsuleScreenState();
}

class _CreateCapsuleScreenState
    extends State<CreateCapsuleScreen> {

  final TextEditingController titleController =
  TextEditingController();

  bool isShared = false;

  final CapsuleService capsuleService =
  CapsuleService();

  Future<void> createCapsule() async {

    if (titleController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
          Text("Please enter capsule title"),
        ),
      );

      return;

    }

    String? inviteCode =
    await capsuleService.createCapsule(

      title: titleController.text.trim(),

      isShared: isShared,

    );

    Navigator.pop(context);

    if (isShared && inviteCode != null) {

      showDialog(

        context: context,

        builder: (context) => AlertDialog(

          title: const Text("Invite Code"),

          content: SelectableText(
            inviteCode,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

        ),

      );

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Create Capsule"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(

              controller: titleController,

              decoration: const InputDecoration(
                labelText: "Capsule Title",
                border: OutlineInputBorder(),
              ),

            ),

            const SizedBox(height: 20),

            SwitchListTile(

              title:
              const Text("Shared Capsule"),

              value: isShared,

              onChanged: (value) {

                setState(() {
                  isShared = value;
                });

              },

            ),

            const SizedBox(height: 20),

            ElevatedButton(

              onPressed: createCapsule,

              child:
              const Text("Create Capsule"),

            ),

          ],

        ),

      ),

    );

  }

}