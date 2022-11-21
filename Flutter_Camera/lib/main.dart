import 'package:flutter/material.dart';
import 'package:flutter_camera/home.dart';
import 'package:flutter_camera/login.dart';
import 'package:flutter_camera/register.dart';
import 'pick_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
      routes: {
        "/home": (context) => new Home(),
        "/login": (context) => new Login(),
        "/register": (context) => new Register(),
      },
    );
  }
}
