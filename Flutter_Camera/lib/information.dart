// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_camera/api.dart';
import 'package:flutter_camera/dialog/dialog_loading.dart';
import 'package:flutter_camera/dialog/dialog_message.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class Information extends StatefulWidget {
  const Information({super.key});

  @override
  State<Information> createState() => _InformationState();
}

class _InformationState extends State<Information> {
  final picker = ImagePicker();
  final storage = FlutterSecureStorage();

  String result = "";
  var _image;
  String? username = "";
  @override
  void initState() {
    getName();
    super.initState();
  }

  Future<void> getName() async {
    username = await storage.read(key: "username");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('DETECTED SKIN CANCER'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Column(children: [
              SizedBox(
                height: height / 60,
              ),
              Text(
                "Welcome back $username",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: height / 60,
              ),
              ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    'LOGOUT',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )),
              SizedBox(
                height: height / 60 * 10,
                child: Text(
                  result,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan[300],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  _logout() async {
    ApiService api = new ApiService();
    LoadingDialog.showLoadingDialog(context, "Logout...");
    var response = await api.logout();
    if (response.statusCode == 204) {
      await storage.delete(key: 'token');
      LoadingDialog.hideLoadingDialog(context);
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      LoadingDialog.hideLoadingDialog(context);
      MessageDialog.showMessageDialog(
        context,
        "Error",
        "System Error. Please try again",
      );
    }
  }
}
