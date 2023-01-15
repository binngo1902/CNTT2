import 'package:flutter/material.dart';
import 'package:flutter_camera/result.dart';
import 'package:flutter_camera/pick_image.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  List tabs = [
    PickImage(),
    Information(),
  ];
  final storage = FlutterSecureStorage();
  var token;
  int currentIndex = 0;
  void initState() {
    checkToken();
  }

  Future<void> checkToken() async {
    token = await storage.read(key: "token");
    print(token);
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey[400],
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.photo_size_select_actual_rounded),
              label: "Main"),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined), label: "Result"),
        ],
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
