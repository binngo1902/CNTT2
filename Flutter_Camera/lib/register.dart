import 'dart:io';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/api.dart';
import 'package:flutter_camera/dialog/dialog_loading.dart';
import 'package:flutter_camera/dialog/dialog_message.dart';
import 'package:flutter_camera/pick_image.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  bool showPass = false;
  final storage = new FlutterSecureStorage();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();

  bool usernameInvalid = false;
  bool passwordInvalid = false;
  bool EmailInvalid = false;

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Register',
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
                  controller: emailController,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'EMAIL',
                    errorText:
                        EmailInvalid == true ? "FULLNAME is required" : null,
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
                    'SIGN UP',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              GestureDetector(
                onTap: returnLogin,
                child: Text("ALREADY HAVE ACOOUNT? SIGN IN",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              SizedBox(
                height: 75,
              ),
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

  void returnLogin() {
    setState(() {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  void checkValidateRequire() async {
    usernameController.text.length <= 0
        ? usernameInvalid = true
        : usernameInvalid = false;
    passwordController.text.length <= 0
        ? passwordInvalid = true
        : passwordInvalid = false;
    emailController.text.length <= 0
        ? EmailInvalid = true
        : EmailInvalid = false;
    setState(() {});
    if (!passwordInvalid && !usernameInvalid && !EmailInvalid) {
      try {
        ApiService api = new ApiService();
        LoadingDialog.showLoadingDialog(context, "Loading...");
        var response = await api.register(emailController.text,
            usernameController.text, passwordController.text);
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
          if (errorText.containsKey('email')) {
            error = errorText['email'][0];
          } else if (errorText.containsKey('username')) {
            error = errorText['username'][0];
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
