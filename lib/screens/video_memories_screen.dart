import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

import '../services/memory_service.dart';
import '../widgets/memory_card.dart';

class VideoMemoriesScreen extends StatelessWidget {

  final String capsuleId;

  VideoMemoriesScreen({
    super.key,
    required this.capsuleId,
  });

  final MemoryService memoryService =
  MemoryService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Video Memories"),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream:
        memoryService.getMemoriesByType(
            capsuleId, "video"),

        builder: (context, snapshot) {

          if (!snapshot.hasData)
            return Center(
                child:
                CircularProgressIndicator());

          var memories = snapshot.data!.docs;

          if (memories.isEmpty)
            return Center(
                child:
                Text("No video memories yet"));

          return ListView.builder(

            itemCount: memories.length,

            itemBuilder: (context, index) {

              var memory = memories[index];

              return VideoTile(
                memory: memory,
                capsuleId: capsuleId,
              );

            },

          );

        },

      ),

    );

  }

}

class VideoTile extends StatefulWidget {

  final DocumentSnapshot memory;
  final String capsuleId;

  const VideoTile({
    super.key,
    required this.memory,
    required this.capsuleId,
  });

  @override
  State<VideoTile> createState() =>
      _VideoTileState();

}

class _VideoTileState extends State<VideoTile> {

  late VideoPlayerController controller;

  @override
  void initState() {

    super.initState();

    controller =
    VideoPlayerController.network(
        widget.memory["fileURL"])
      ..initialize().then((_) {
        setState(() {});
      });

  }

  @override
  Widget build(BuildContext context) {

    return MemoryCard(
      capsuleId: widget.capsuleId,
      memory: widget.memory,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controller.value.isInitialized)
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          IconButton(
            icon: Icon(
              controller.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
            onPressed: () {
              setState(() {
                controller.value.isPlaying
                    ? controller.pause()
                    : controller.play();
              });
            },
          ),
          if (widget.memory["caption"].toString().isNotEmpty)
             Padding(
               padding: const EdgeInsets.all(12),
               child: Text(widget.memory["caption"]),
             ),
        ],
      ),
    );

  }

}