// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_camera/api.dart';
import 'package:flutter_camera/dialog/dialog_loading.dart';
import 'package:flutter_camera/dialog/dialog_message.dart';
import 'package:flutter_camera/fullScreenImage.dart';
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
        body: Center(
          child: ListView(children: <Widget>[
            _comboNameLogout(width, height),
            _listView(width, height),
          ]),
        ));
  }

  Widget _comboNameLogout(width, height) {
    return Column(children: [
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
    ]);
  }

  Future<dynamic> _loadData() async {
    var response;
    var data;
    ApiService api = new ApiService();
    response = await api.getResult();
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
    }
    return data['data'];
  }

  Widget _listView(width, height) {
    return FutureBuilder(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(20),
                child: Card(
                  elevation: 20,
                  color: Colors.cyan[50],
                  shape: Border.all(width: 2, color: Colors.cyan),
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                          child: Image.network(
                            "http://192.168.100.8:8000/media/" +
                                snapshot.data[index]['image'],
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                            height: height / 3,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FullScreenImageViewer(
                                        "http://192.168.100.8:8000/media/" +
                                            snapshot.data[index]['image'],
                                      )),
                            );
                          }),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        snapshot.data[index]['predictions'],
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.black87,
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Container(
            child: Center(
              child: Text(
                "NOT FOUND DATA",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.red,
                ),
              ),
            ),
          );
        } else {
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  _logout() async {
    try {
      ApiService api = new ApiService();
      LoadingDialog.showLoadingDialog(context, "Logout...");
      var response = await api.logout();
      LoadingDialog.hideLoadingDialog(context);

      if (response.statusCode == 204) {
        await storage.delete(key: 'token');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        MessageDialog.showMessageDialog(
          context,
          "Error",
          "System Error. Please try again",
        );
      }
    } catch (e) {
      MessageDialog.showMessageDialog(
        context,
        "Error",
        "System Error. Please try again",
      );
    }
  }
}
