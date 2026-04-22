import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/memory_service.dart';
import '../widgets/memory_card.dart';

class ImageMemoriesScreen extends StatelessWidget {

  final String capsuleId;

  ImageMemoriesScreen({
    super.key,
    required this.capsuleId,
  });

  final MemoryService memoryService =
  MemoryService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Image Memories"),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream:
        memoryService.getMemoriesByType(
            capsuleId, "image"),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData)
            return Center(
                child:
                Text("No Image Memories Yet"));

          var memories = snapshot.data!.docs;

          if (memories.isEmpty)
            return Center(
                child:
                Text("No image memories yet"));

          return ListView.builder(

            itemCount: memories.length,

            itemBuilder: (context, index) {

              var memory = memories[index];

              return MemoryCard(
                capsuleId: capsuleId,
                memory: memory,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.network(memory["fileURL"], fit: BoxFit.cover),
                    if (memory["caption"].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          memory["caption"],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                  ],
                ),
              );

            },

          );

        },

      ),

    );

  }

}