import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class CapsuleService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String generateInviteCode() {

    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    Random random = Random();

    return String.fromCharCodes(
      Iterable.generate(
        6,
            (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );

  }

  Future<String?> createCapsule({
    required String title,
    required DateTime unlockDate,
    required bool isShared,
  }) async {

    String userId = _auth.currentUser!.uid;

    String capsuleId = _db.collection("capsules").doc().id;

    String inviteCode = isShared ? generateInviteCode() : "";

    await _db.collection("capsules").doc(capsuleId).set({

      "capsuleId": capsuleId,

      "title": title,

      "createdBy": userId,

      "members": [userId],

      "inviteCode": inviteCode,

      "isShared": isShared,

      "isLocked": true,

      "unlockDate": unlockDate,

      "createdAt": FieldValue.serverTimestamp(),

    });

    return inviteCode;

  }

  Future<bool> joinCapsule(String inviteCode) async {

    try {

      String userId = _auth.currentUser!.uid;

      QuerySnapshot query = await _db
          .collection("capsules")
          .where("inviteCode", isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return false;
      }

      DocumentSnapshot capsuleDoc = query.docs.first;

      List members = capsuleDoc["members"];

      if (!members.contains(userId)) {

        await _db.collection("capsules")
            .doc(capsuleDoc.id)
            .update({

          "members": FieldValue.arrayUnion([userId])

        });

      }

      return true;

    } catch (e) {

      print("Join capsule error: $e");
      return false;

    }

  }

}