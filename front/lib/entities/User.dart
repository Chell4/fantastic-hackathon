import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:front/main.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import '../utils/Constants.dart';

class User {
  final String? id, phone, firstName, secondName, description, lastName, picturePath;
  final bool? isAdmin, isReady;

  User(this.id, this.phone, this.firstName, this.secondName, this.lastName, this.description, this.picturePath, this.isAdmin, this.isReady);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'],
      json['phone'],
      json['first_name'],
      json['second_name'],
      json['last_name'],
      json['description'],
      json['picture_path'],
      json['is_admin'],
      json['is_ready'],
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
      return Uint8List.fromList(response.body.codeUnits);
    }
    return Uint8List(0);
  }

  Future<String> getMatches() async {
    final response = await http.get(
        Uri.parse("${BACKEND}profile/matches"),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          HttpHeaders.authorizationHeader: "Bearer ${html.window.localStorage["authToken"]}"
        }
    );

    if (response.statusCode == HttpStatus.unauthorized) {
      return "{}";
    }

    if (response.statusCode == HttpStatus.ok) {
      return response.body;
    }
    return "{}";
  }

  Future<bool> ready(bool ready) async {
    final response = await http.post(
        Uri.parse("${BACKEND}profile/ready"),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
          HttpHeaders.authorizationHeader: "Bearer ${html.window.localStorage["authToken"]}"
        },
        body: {
          "ready": ready
        }
    );

    if (response.statusCode == HttpStatus.unauthorized) {
      return false;
    }

    if (response.statusCode == HttpStatus.ok) {
      return true;
    }
    return false;
  }
}