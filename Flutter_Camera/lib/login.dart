import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/api.dart';
import 'package:flutter_camera/dialog/dialog_loading.dart';
import 'package:flutter_camera/dialog/dialog_message.dart';
import 'package:flutter_camera/pick_image.dart';
import 'package:flutter_camera/register.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  bool showPass = false;
  final storage = new FlutterSecureStorage();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  bool usernameInvalid = false;
  bool passwordInvalid = false;

  @override
  void initState() {}

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white10,
        iconTheme: IconThemeData(
          color: Colors.blue,
        ),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(25, 25, 25, 25),
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'DETECT SKIN CANCER',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 25),
                  )),
              SizedBox(
                height: 50,
              ),
              Container(
                // ignore: prefer_const_constructors
                child: TextField(
                  // ignore: prefer_const_constructors
                  controller: usernameController,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'USERNAME',
                    errorText:
                        usernameInvalid == true ? "USERNAME is required" : null,
                    labelStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Stack(
                alignment: AlignmentDirectional.centerEnd,
                children: <Widget>[
                  Container(
                    // ignore: prefer_const_constructors
                    child: TextField(
                      controller: passwordController,
                      // ignore: prefer_const_constructors
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      obscureText: !showPass,
                      decoration: InputDecoration(
                        labelText: 'PASSWORD',
                        errorText: passwordInvalid == true
                            ? "PASSWORD is required"
                            : null,
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: toggleShowPass,
                    child: Text(showPass ? "HIDE" : "SHOW",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        )),
                  )
                ],
              ),
              SizedBox(
                height: 25,
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: checkValidateRequire,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    'SIGN IN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        text: "NEW USER? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacementNamed(
                                    context, '/register');
                              },
                            text: 'SIGN UP',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void toggleShowPass() {
    setState(() {
      showPass = !showPass;
    });
  }

  void checkValidateRequire() async {
    usernameController.text.length <= 0
        ? usernameInvalid = true
        : usernameInvalid = false;
    passwordController.text.length <= 0
        ? passwordInvalid = true
        : passwordInvalid = false;

    setState(() {});
    if (!passwordInvalid && !usernameInvalid) {
      try {
        ApiService api = new ApiService();
        LoadingDialog.showLoadingDialog(context, "Loading...");

        var response =
            await api.login(usernameController.text, passwordController.text);
        LoadingDialog.hideLoadingDialog(context);
        if (response.statusCode == 200) {
          var message = jsonDecode(response.body);
          var token = message["token"];
          var username = message["user"]["username"];
          await storage.write(key: 'token', value: token);
          await storage.write(key: 'username', value: username);
          Navigator.pushReplacementNamed(context, '/home');
        } else if (response.statusCode == 400) {
          var errorText = jsonDecode(response.body);

          String error = "";
          if (errorText.containsKey('non_field_errors')) {
            error = errorText['non_field_errors'][0];
          }
          MessageDialog.showMessageDialog(
            context,
            "Error",
            error,
          );
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
}
