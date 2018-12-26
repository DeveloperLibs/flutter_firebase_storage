import 'package:flutter/material.dart';
import 'package:flutter_firebase_storage/home_page.dart';

void main() {
  runApp(new FirebaseStorageApp());
}

class FirebaseStorageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primaryColor: const Color(0xFF02BB9F),
        primaryColorDark: const Color(0xFF167F67),
        accentColor: const Color(0xFF167F67),
      ),
      home: new HomePage(),
    );
  }
}
