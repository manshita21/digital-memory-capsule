import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/memory_service.dart';

class TextMemoriesScreen extends StatelessWidget {

  final String capsuleId;

  TextMemoriesScreen({
    super.key,
    required this.capsuleId,
  });

  final MemoryService memoryService = MemoryService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Text Memories"),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream:
        memoryService.getMemoriesByType(
            capsuleId, "text"),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {

            return Center(
                child:
                Text("No Text Memories Yet!")
            );

          }

          var memories = snapshot.data!.docs;

          if (memories.isEmpty) {

            return Center(
              child: Text("No Mext Memories Yet"),
            );

          }

          return ListView.builder(

            itemCount: memories.length,

            itemBuilder: (context, index) {

              var memory = memories[index];

              return Card(

                margin: EdgeInsets.all(10),

                child: ListTile(

                  title: Text(memory["text"]),

                  subtitle: Text(
                    "by ${memory["createdByName"]}",
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