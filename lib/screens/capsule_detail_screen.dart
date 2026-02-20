import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';


import '../services/memory_service.dart';
import 'text_memories_screen.dart';
import 'image_memories_screen.dart';
import 'audio_memories_screen.dart';
import 'video_memories_screen.dart';

class CapsuleDetailScreen extends StatelessWidget {

  final DocumentSnapshot capsule;

   CapsuleDetailScreen({
    super.key,
    required this.capsule,
  });

  final MemoryService _memoryService = MemoryService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  // ADD TEXT DIALOG

  void openAddTextDialog(BuildContext context) {

    TextEditingController controller =
    TextEditingController();

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text("Add Text Memory"),

          content: TextField(

            controller: controller,

            maxLines: 5,

            decoration: const InputDecoration(
              hintText: "Write your memory...",
              border: OutlineInputBorder(),
            ),

          ),

          actions: [

            TextButton(

              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("Cancel"),

            ),

            ElevatedButton(

              onPressed: () async {

                if (controller.text.isNotEmpty) {

                  await _memoryService.addTextMemory(
                    capsuleId: capsule.id,
                    text: controller.text.trim(),
                  );

                }

                Navigator.pop(context);

              },

              child: const Text("Save"),

            )

          ],

        );

      },

    );

  }

  //ADD  IMAGE PICKER
  Future<void> pickImage(BuildContext context) async {

    final ImagePicker picker = ImagePicker();

    final XFile? picked =
    await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) return;

    File imageFile = File(picked.path);

    TextEditingController captionController =
    TextEditingController();

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: Text("Add Caption"),

          content: TextField(
            controller: captionController,
            decoration: InputDecoration(
              hintText: "Enter caption...",
            ),
          ),

          actions: [

            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: Text("Cancel"),
            ),

            ElevatedButton(

              onPressed: () async {

                await _memoryService.addImageMemory(
                  capsuleId: capsule.id,
                  imageFile: imageFile,
                  caption:
                  captionController.text.trim(),
                );

                Navigator.pop(context);

              },

              child: Text("Upload"),

            )

          ],

        );

      },

    );

  }

  //ADD AUDIO RECORDING
  Future<void> recordAudio(BuildContext context) async {

    if (await _audioRecorder.hasPermission()) {

      Directory dir =
      await getTemporaryDirectory();

      String path =
          "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a";

      await _audioRecorder.start(
        const RecordConfig(),
        path: path,
      );

      showDialog(

        context: context,

        builder: (context) {

          return AlertDialog(

            title: Text("Recording..."),

            actions: [

              ElevatedButton(

                onPressed: () async {

                  String? filePath =
                  await _audioRecorder.stop();

                  if (filePath == null) return;

                  File audioFile =
                  File(filePath);

                  TextEditingController captionController =
                  TextEditingController();

                  Navigator.pop(context);

                  showDialog(

                    context: context,

                    builder: (context) {

                      return AlertDialog(

                        title: Text("Add Caption"),

                        content: TextField(
                          controller: captionController,
                        ),

                        actions: [

                          ElevatedButton(

                            onPressed: () async {

                              await _memoryService.addAudioMemory(
                                capsuleId: capsule.id,
                                audioFile: audioFile,
                                caption: captionController.text,
                              );

                              Navigator.pop(context);

                            },

                            child: Text("Upload"),

                          )

                        ],

                      );

                    },

                  );

                },

                child: Text("Stop & Save"),

              )

            ],

          );

        },

      );

    }

  }

  //ADD VIDEO PICKER
  Future<void> pickVideo(BuildContext context) async {

    final ImagePicker picker = ImagePicker();

    final XFile? picked =
    await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (picked == null) return;

    File videoFile = File(picked.path);

    TextEditingController captionController =
    TextEditingController();

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: Text("Add Caption"),

          content: TextField(
            controller: captionController,
            decoration:
            InputDecoration(
              hintText: "Enter caption...",
            ),
          ),

          actions: [

            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: Text("Cancel"),
            ),

            ElevatedButton(

              onPressed: () async {

                await _memoryService.addVideoMemory(
                  capsuleId: capsule.id,
                  videoFile: videoFile,
                  caption:
                  captionController.text.trim(),
                );

                Navigator.pop(context);

              },

              child: Text("Upload"),

            )

          ],

        );

      },

    );

  }

  //LOCK CAPSULE
  Future<void> lockCapsule(BuildContext context) async {

    DateTime? pickedDate =
    await showDatePicker(

      context: context,

      initialDate:
      DateTime.now().add(
          const Duration(days: 1)),

      firstDate:
      DateTime.now(),

      lastDate:
      DateTime(2100),

    );

    if (pickedDate == null) return;

    await FirebaseFirestore.instance
        .collection("capsules")
        .doc(capsule.id)
        .update({

      "isLocked": true,

      "unlockDate":
      Timestamp.fromDate(pickedDate),

    });

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content:
        Text("Capsule locked successfully"),
      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    Timestamp? unlockTimestamp= capsule["unlockDate"];
    DateTime? unlockDate = unlockTimestamp?.toDate();

    String title = capsule["title"];
    String inviteCode = capsule["inviteCode"];

    bool isLocked = capsule["isLocked"] == true;

    bool isSealed= isLocked && unlockDate!=null && DateTime.now().isBefore(unlockDate);

    bool isUnlocked =
        isLocked &&
            unlockDate != null &&
            DateTime.now().isAfter(unlockDate);

    return Scaffold(

      appBar: AppBar(
        title: Text(title),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              "Capsule Title: $title",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            if (inviteCode.isNotEmpty)
              Text("Invite Code: $inviteCode",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),),

            const SizedBox(height: 8),

            Text(
              !isLocked
                  ? "The future is waiting… add memories your future self will cherish 💭"
                  : isSealed
                  ? "A message from your past awaits… unlocking on ${unlockDate!.day}/${unlockDate.month}/${unlockDate.year}✨"
                  : "The capsule has opened… relive your memories 🌟",

              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: !isLocked
                    ? Colors.green
                    : isSealed
                    ? Colors.red
                    : Colors.blue,
              ),
            ),


            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 10),

            // ADD BUTTONS ROW 1

            Row(

              mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,

              children: [

                ElevatedButton.icon(

                  onPressed: (!isLocked || isUnlocked)
                        ? () => openAddTextDialog(context)
                        : null,
                  icon: const Icon(Icons.text_snippet),

                  label: const Text("Add Text"),

                ),

                ElevatedButton.icon(

                  onPressed:(!isLocked || isUnlocked)
                        ?() => pickImage(context): null,

                  icon: const Icon(Icons.image),

                  label: const Text("Add Image"),

                ),

              ],

            ),

            const SizedBox(height: 10),

            // ADD BUTTONS ROW 2

            Row(

              mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,

              children: [

                ElevatedButton.icon(

                  onPressed: (!isLocked || isUnlocked)
                      ? () => recordAudio(context)
                      : null  ,

                  icon: const Icon(Icons.mic),

                  label: const Text("Add Audio"),

                ),

                ElevatedButton.icon(

                  onPressed: (!isLocked || isUnlocked)
                      ? () => pickVideo(context)
                      : null ,

                  icon: const Icon(Icons.video_library),

                  label: const Text("Add Video"),

                ),

              ],

            ),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 10),

            const Text(
              "Memories We Made ❤️",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // MEMORY CATEGORY TILES

            ListTile(

              leading: const Icon(Icons.text_snippet),

              title: const Text("Text Memories"),

              trailing: const Icon(Icons.arrow_forward),

              onTap:(!isLocked || isUnlocked)
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TextMemoriesScreen(
                          capsuleId: capsule.id,
                        ),
                  ),
                );
              }
                  : () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      "Capsule is sealed",
                    ),
                  ),
                );
              },
            ),

            ListTile(

              leading: const Icon(Icons.image),

              title: const Text("Image Memories"),

              trailing: const Icon(Icons.arrow_forward),

              onTap: (!isLocked || isUnlocked)
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ImageMemoriesScreen(
                          capsuleId: capsule.id,
                        ),
                  ),
                );
              }
                  : () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      "Capsule is sealed",
                    ),
                  ),
                );
              },
            ),

            ListTile(

              leading: const Icon(Icons.mic),

              title: const Text("Audio Memories"),

              trailing: const Icon(Icons.arrow_forward),

              onTap: (!isLocked || isUnlocked)
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AudioMemoriesScreen(
                          capsuleId: capsule.id,
                        ),
                  ),
                );
              }
                  : () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      "Capsule is sealed",
                    ),
                  ),
                );
              },
            ),

            ListTile(

              leading: const Icon(Icons.video_library),

              title: const Text("Video Memories"),

              trailing: const Icon(Icons.arrow_forward),

              onTap: (!isLocked || isUnlocked)
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        VideoMemoriesScreen(
                          capsuleId: capsule.id,
                        ),
                  ),
                );
              }
                  : () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      "Capsule is sealed",
                    ),
                  ),
                );
              },
            ),

            if (!isLocked)

              ElevatedButton.icon(

                onPressed:
                    () => lockCapsule(context),

                icon:
                const Icon(Icons.lock),

                label:
                const Text("Lock Capsule"),

                style:
                ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),

              ),
          ],

        ),

      ),


    );

  }

}