import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:http/http.dart" as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  final storage = FlutterSecureStorage();
  final registerUri = Uri.parse("http://127.0.0.1:8000/api/register/");
  final logoutUri = Uri.parse("http://127.0.0.1:8000/api/logout/");
  final loginUri = Uri.parse("http://127.0.0.1:8000/api/login/");
  final uploadUri = Uri.parse("http://127.0.0.1:8000/api/uploadimage/");

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
    var request = new http.MultipartRequest("POST", uploadUri);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Token $token',
    };
    print(img);
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromBytes(
      "image",
      img.readAsBytesSync(),
      filename: img.path.split("/").last,
    ));
    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    print(respStr);
  }
}
