import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/memory_service.dart';

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

              return Card(

                margin: EdgeInsets.all(10),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Image.network(
                      memory["fileURL"],
                    ),

                    Padding(

                      padding:
                      EdgeInsets.all(8),

                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          Text(
                            memory["caption"],
                            style: TextStyle(
                                fontSize: 16),
                          ),

                          Text(
                            "by ${memory["createdByName"]}",
                            style: TextStyle(
                                color: Colors.grey),
                          ),

                        ],

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