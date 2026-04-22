import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/capsule_service.dart';
import 'login_screen.dart';
import 'capsule_detail_screen.dart';
import 'create_capsule_screen.dart';
import '../widgets/nostalgic_background.dart';
import '../widgets/glass_widgets.dart';


class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final CapsuleService _capsuleService = CapsuleService();

  final TextEditingController inviteController =
  TextEditingController();

 /* Future<void> checkAndUnlockCapsules(
      List<QueryDocumentSnapshot> capsules) async {

    for (var capsule in capsules) {

      Timestamp? unlockTimestamp =
      capsule["unlockDate"];

      bool isLocked =
          capsule["isLocked"] == true;

      if (unlockTimestamp == null || !isLocked) continue;

      DateTime unlockDate =
      unlockTimestamp.toDate();

      if (DateTime.now().isAfter(unlockDate)) {

        // Auto unlock in Firestore

        await FirebaseFirestore.instance
            .collection("capsules")
            .doc(capsule.id)
            .update({

          "isLocked": false,

        }
        );

      }

    }

  }*/

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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


    body: NostalgicBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [
           GlassContainer(
             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
             child: const Text(
               "Welcome to Digital Memory Capsule",
               style: TextStyle(
                 fontSize: 18,
                 fontWeight: FontWeight.bold,
                 color: Colors.white,
               ),
             ),
           ),
          const SizedBox(height: 20),

          // CREATE CAPSULE BUTTON

          ElevatedButton(

            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateCapsuleScreen(),
                ),
              );

            },
            child: Text("Create Capsule"),
          ),

          const SizedBox(height: 10),

          // INVITE CODE INPUT

          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: inviteController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Enter Invite Code",
                labelStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 10),

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

            child: const Text("Join Capsule"),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white54),
          const SizedBox(height: 10),
          const Text(
            "Your Capsules",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          // CAPSULE LIST

          Expanded(

            child: StreamBuilder<QuerySnapshot>(

              stream:
              _capsuleService.getUserCapsules(),

              builder: (context, snapshot) {

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {

                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {

                  return const Center(
                      child:
                      Text("No capsules yet"),);

                }

                var capsules =
                    snapshot.data!.docs;

                if (capsules.isEmpty) {

                  return const Center(
                    child:
                    Text("No capsules yet"),
                  );

                }
               // checkAndUnlockCapsules(capsules);
                return ListView.builder(

                  itemCount: capsules.length,

                  itemBuilder:
                      (context, index) {

                    var capsule =
                    capsules[index];

                    String title =
                    capsule["title"];

                    Timestamp? unlockTimestamp = capsule["unlockDate"];

                    DateTime? unlockDate = unlockTimestamp?.toDate();

                    bool isLocked = capsule["isLocked"] == true;

                    bool isSealed =
                        isLocked &&
                            unlockDate != null &&
                            DateTime.now().isBefore(unlockDate);

                    bool isUnlocked =
                        isLocked &&
                            unlockDate != null &&
                            DateTime.now().isAfter(unlockDate);

                    String inviteCode =
                    capsule["inviteCode"];

                    return GlassContainer(
                      margin: const EdgeInsets.all(8),
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CapsuleDetailScreen(capsule: capsule),
                            ),
                          );
                        },
                        leading: Icon(
                          !isLocked
                              ? Icons.lock_open
                              : isSealed
                              ? Icons.lock
                              : Icons.lock_open,
                          color:
                          !isLocked
                              ? Colors.greenAccent
                              : isSealed
                              ? Colors.orangeAccent
                              : Colors.lightBlueAccent,
                        ),
                        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          !isLocked
                              ? "Open"
                              : isSealed
                              ? "Locked"
                              : "Unlocked",
                          style: TextStyle(
                            color:
                            !isLocked
                                ? Colors.greenAccent
                                : isSealed
                                ? Colors.orangeAccent
                                : Colors.lightBlueAccent,
                          ),
                        ),
                        trailing:
                        inviteCode.isNotEmpty
                            ? Text(
                          inviteCode,
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                            : null,
                      ),
                    );

                  },

                );

              },
            ),
          ),
        ],
      ),
    ),
    ),
    ),
    );
  }
}
