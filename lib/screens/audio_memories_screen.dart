import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

import '../services/memory_service.dart';
import '../widgets/memory_card.dart';

class AudioMemoriesScreen extends StatelessWidget {

  final String capsuleId;

  AudioMemoriesScreen({
    super.key,
    required this.capsuleId,
  });

  final MemoryService memoryService =
  MemoryService();

  final AudioPlayer player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Audio Memories"),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream:
        memoryService.getMemoriesByType(
            capsuleId, "audio"),

        builder: (context, snapshot) {

          if (!snapshot.hasData)
            return Center(
                child:
                CircularProgressIndicator());

          var memories = snapshot.data!.docs;

          if (memories.isEmpty)
            return Center(
                child:
                Text("No audio memories yet"));

          return ListView.builder(

            itemCount: memories.length,

            itemBuilder: (context, index) {

              var memory = memories[index];

              String cap = memory["caption"] ?? "";
              return MemoryCard(
                capsuleId: capsuleId,
                memory: memory,
                content: ListTile(
                  title: Text(cap.isNotEmpty ? cap : "Audio Memory"),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () async {
                      try {
                        print("Playing: ${memory["fileURL"]}");
                        await player.stop();
                        await player.setSource(UrlSource(memory["fileURL"]));
                        await player.resume();
                      } catch (e) {
                        print("Audio play error: $e");
                      }
                    },
                  ),
                ),
              );

            },

          );

        },

      ),

    );

  }

}