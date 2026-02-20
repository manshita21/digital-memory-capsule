import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';

class AuthService {
  final FirestoreService _firestoreService = FirestoreService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<User?> signInWithGoogle() async {
    // Trigger Google Sign-In
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      return null;
    }

    // Get authentication details
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase
    UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );

    User? user = userCredential.user;

    if (user != null) {
      await _firestoreService.saveUser(user);
    }

    return user;


  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  String? _verificationId;

  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String) codeSent,
    required Function(String) error,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,

      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        error(e.message ?? "Verification failed");
      },

      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;

        codeSent(verificationId);
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<User?> verifyOTP(String otp) async {
    if (_verificationId == null) {
      return null;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user != null) {
        await _firestoreService.saveUser(user);
      }

      return user;


    } catch (e) {
      print("OTP Error: $e");

      return null;
    }
  }
}
