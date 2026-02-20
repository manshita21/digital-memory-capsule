import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MemoryService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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