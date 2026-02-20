import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import 'storage_service.dart';

class MemoryService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageService _storageService=StorageService();
  Future<void> addTextMemory({
    required String capsuleId,
    required String text,
  }) async {

    User user = _auth.currentUser!;

    await _db
        .collection("capsules")
        .doc(capsuleId)
        .collection("memories")
        .add({

      "type": "text",

      "text": text,

      "fileURL": "",

      "caption": "",

      "createdBy": user.uid,

      "createdByName": user.displayName ?? user.phoneNumber ?? "User",

      "createdAt": FieldValue.serverTimestamp(),

    });

  }

  Future<void> addImageMemory({
    required String capsuleId,
    required File imageFile,
    required String caption,
  }) async {

    User user = _auth.currentUser!;

    String fileName =
    DateTime.now().millisecondsSinceEpoch.toString();

    // Upload to Firebase Storage

    String? downloadURL =
    await _storageService.uploadImage(
      file: imageFile,
      capsuleId: capsuleId,
    );

    if (downloadURL == null) {
      throw Exception("Image upload failed");
    }

    // Save in Firestore

    await _db
        .collection("capsules")
        .doc(capsuleId)
        .collection("memories")
        .add({

      "type": "image",

      "fileURL": downloadURL,

      "caption": caption,

      "text": "",

      "createdBy": user.uid,

      "createdByName":
      user.displayName ??
          user.phoneNumber ??
          "User",

      "createdAt":
      FieldValue.serverTimestamp(),

    });

  }

  Stream<QuerySnapshot> getMemoriesByType(
      String capsuleId,
      String type,
      ) {

    return _db
        .collection("capsules")
        .doc(capsuleId)
        .collection("memories")
        .where("type", isEqualTo: type)
        .orderBy("createdAt", descending: true)
        .snapshots();

  }

}