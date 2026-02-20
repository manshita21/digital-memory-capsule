import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(User user) async {

    try {

      final userRef = _db.collection("users").doc(user.uid);

      final doc = await userRef.get();

      if (!doc.exists) {

        await userRef.set({

          "uid": user.uid,
          "name": user.displayName ?? "",
          "email": user.email ?? "",
          "phone": user.phoneNumber ?? "",
          "photoURL": user.photoURL ?? "",

          "createdAt": FieldValue.serverTimestamp(),

        });

        print("User saved in Firestore");

      } else {

        print("User already exists");

      }

    } catch (e) {

      print("Error saving user: $e");

    }

  }

}