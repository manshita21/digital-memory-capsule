import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  Future<String?> uploadImage({
    required File file,
    required String capsuleId,
  }) async {

    try {

      String fileName =
      DateTime.now()
          .millisecondsSinceEpoch
          .toString();

      Reference ref = _storage
          .ref()
          .child("capsules")
          .child(capsuleId)
          .child("images")
          .child("$fileName.jpg");

      UploadTask uploadTask =
      ref.putFile(file);

      TaskSnapshot snapshot =
      await uploadTask;

      String downloadUrl =
      await snapshot.ref.getDownloadURL();

      return downloadUrl;

    } catch (e) {

      print("Upload error: $e");
      return null;

    }

  }

}