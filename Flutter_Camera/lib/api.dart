import 'dart:io';
import 'dart:math';
import 'package:flutter_camera/dialog/dialog_loading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:http/http.dart" as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class ApiService {
  final storage = FlutterSecureStorage();
  String path = "";
  var registerUri;
  var logoutUri;
  var loginUri;
  var uploadUri;

  ApiService() {
    if (Platform.isAndroid) {
      path = "http://10.0.2.2:8000";
    } else {
      path = "http://127.0.0.1:8000";
    }
    registerUri = Uri.parse('$path/api/register/');
    logoutUri = Uri.parse("$path/api/logout/");
    loginUri = Uri.parse("$path/api/login/");
    uploadUri = Uri.parse("$path/api/uploadimage/");
  }

  Future<dynamic> register(
      String email, String username, String password) async {
    var response = await http.post(registerUri,
        body: {"email": email, "username": username, "password": password});
    return response;
  }

  Future<dynamic> logout() async {
    var token = await storage.read(key: 'token');
    var response = await http.post(logoutUri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Token $token',
    });

    return response;
  }

  Future<dynamic> login(String username, String password) async {
    var response = await http
        .post(loginUri, body: {"username": username, "password": password});
    return response;
  }

  Upload(File img) async {
    var token = await storage.read(key: 'token');
    var username = await storage.read(key: 'username');
    var request = new http.MultipartRequest("POST", uploadUri);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Token $token',
    };
    request.headers.addAll(headers);
    request.fields['username'] = username ?? "";

    request.files.add(await http.MultipartFile.fromBytes(
      "image",
      img.readAsBytesSync(),
      filename: (DateTime.now().millisecondsSinceEpoch.toString()) +
          Random().nextInt(10000).toString() +
          ".jpg",
    ));
    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    return response;
  }
}
