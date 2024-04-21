import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:front/main.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import '../utils/Constants.dart';

class User {
  final String? phone, firstName, secondName, lastName, picturePath;

  User(this.phone, this.firstName, this.secondName, this.lastName, this.picturePath);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['phone'],
      json['first_name'],
      json['second_name'],
      json['last_name'],
      json['picture_path'],
    );
  }

  static Future<bool> updateProfile() async {
    final response = await http.get(
        Uri.parse("${BACKEND}profile"),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          HttpHeaders.authorizationHeader: "Bearer ${html.window.localStorage["authToken"]}"
        }
    );

    if (response.statusCode == HttpStatus.unauthorized) {
      return false;
    }

    if (response.statusCode == HttpStatus.ok) {
      print(response.body);
      MyHomePage.instance!.currentUser = User.fromJson(jsonDecode(response.body));
      return true;
    }
    return false;
  }

  Future<Uint8List?> getMedia() async {
    final response = await http.get(
        Uri.parse("${BACKEND}media"),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          HttpHeaders.authorizationHeader: "Bearer ${html.window.localStorage["authToken"]}"
        }
    );

    if (response.statusCode == HttpStatus.unauthorized) {
      return Uint8List(0);
    }

    if (response.statusCode == HttpStatus.ok) {
      print(response.body);
      return Uint8List.fromList(response.body.codeUnits);
    }
    return Uint8List(0);
  }
}