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

  //ADD IMAGE MEMORY

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

 //ADD AUDIO MEMORY

  Future<void> addAudioMemory({
    required String capsuleId,
    required File audioFile,
    required String caption,
  }) async {

    User user = _auth.currentUser!;

    String? downloadURL =
    await _storageService.uploadAudio(
      file: audioFile,
      capsuleId: capsuleId,
    );

    if (downloadURL == null) {
      throw Exception("Audio upload failed");
    }

    await _db
        .collection("capsules")
        .doc(capsuleId)
        .collection("memories")
        .add({

      "type": "audio",

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

  //ADD VIDEO MEMORY

  Future<void> addVideoMemory({
    required String capsuleId,
    required File videoFile,
    required String caption,
  }) async {

    User user = _auth.currentUser!;

    String? downloadURL =
    await _storageService.uploadVideo(
      file: videoFile,
      capsuleId: capsuleId,
    );

    if (downloadURL == null) {
      throw Exception("Video upload failed");
    }

    await _db
        .collection("capsules")
        .doc(capsuleId)
        .collection("memories")
        .add({

      "type": "video",

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

  Future<void> toggleReaction({
    required String capsuleId,
    required String memoryId,
    required String emoji,
  }) async {
    User user = _auth.currentUser!;
    DocumentReference memRef = _db.collection("capsules").doc(capsuleId).collection("memories").doc(memoryId);

    DocumentSnapshot doc = await memRef.get();
    if (!doc.exists) return;

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> reactions = {};
    if (data.containsKey('reactions')) {
      reactions = Map<String, dynamic>.from(data['reactions']);
    }

    if (reactions.containsKey(user.uid) && reactions[user.uid]['emoji'] == emoji) {
      reactions.remove(user.uid);
    } else {
      reactions[user.uid] = {
        'emoji': emoji,
        'name': user.displayName ?? user.phoneNumber ?? "User",
      };
    }

    await memRef.update({'reactions': reactions});
  }

  Future<void> deleteMemory({
    required String capsuleId,
    required String memoryId,
    required String fileUrl,
  }) async {
    if (fileUrl.isNotEmpty) {
      await _storageService.deleteFile(fileUrl);
    }

    await _db
        .collection("capsules")
        .doc(capsuleId)
        .collection("memories")
        .doc(memoryId)
        .delete();
  }

}