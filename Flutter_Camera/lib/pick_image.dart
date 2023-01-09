// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_camera/api.dart';
import 'package:flutter_camera/dialog/dialog_loading.dart';
import 'package:flutter_camera/dialog/dialog_message.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class PickImage extends StatefulWidget {
  const PickImage({super.key});

  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  final picker = ImagePicker();
  String result = "";
  var _image;

  _cropImage(XFile imageFile) async {
    CroppedFile? crop =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    setState(() {
      _image = XFile(crop!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.black,
        // onPressed: () async {
        //   image = await picker.pickImage(source: ImageSource.gallery);
        //   setState(() {});
        // },
        overlayOpacity: 0.5,
        children: [
          SpeedDialChild(
              child: Icon(Icons.image_search_rounded),
              label: "Gallery",
              backgroundColor: Colors.blue[300],
              onTap: () async {
                _image = await picker.pickImage(source: ImageSource.gallery);
                _cropImage(_image);
                setState(() {});
              }),
          SpeedDialChild(
              child: Icon(Icons.camera_alt_outlined),
              label: "Camera",
              backgroundColor: Colors.blue[300],
              onTap: () async {
                _image = await picker.pickImage(source: ImageSource.camera);
                _cropImage(_image);
                setState(() {});
              }),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('Detected Skin Cancer'),
      ),
      body: Center(
        child: Column(children: [
          SizedBox(
            height: height / 60,
          ),
          Text(
            "Shown Image",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: height / 60,
          ),
          Container(
            height: height / 8 * 3,
            width: width / 8 * 7,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                image: DecorationImage(
                  image: _image == null
                      ? AssetImage("assets/background.jpg")
                      : FileImage(File(_image?.path as String))
                          as ImageProvider,
                  fit: BoxFit.cover,
                )),
          ),
          SizedBox(
            height: height / 60,
          ),
          _image != null
              ? ElevatedButton(
                  onPressed: () async {
                    ApiService api = new ApiService();
                    File file = File(_image!.path);
                    LoadingDialog.showLoadingDialog(context, "Loading...");
                    var res = await api.Upload(file);
                    LoadingDialog.hideLoadingDialog(context);
                    if (res.statusCode == 200) {
                      MessageDialog.showMessageDialog(
                        context,
                        "Upload Successfully",
                        "Wait some seconds and move to Result view. You can continue choose another image to predict",
                      );
                      setState(() {
                        _image = null;
                      });
                    } else {
                      MessageDialog.showMessageDialog(
                        context,
                        "Error",
                        "System Error. Please try again",
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan[400],
                  ),
                  child: Text(
                    'Result Predict',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ))
              : SizedBox(),
        ]),
      ),
    );
  }
}
