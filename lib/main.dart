import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Memory Capsule',
      home: Scaffold(
        appBar: AppBar(title: Text('Firebase Connected')),
        body: Center(child: Text('Firebase is successfully connected')),
      ),
    );
  }
}
