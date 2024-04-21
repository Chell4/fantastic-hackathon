import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:front/main.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import '../utils/Constants.dart';

Future<bool> addAdmin(String id) async {
  final response = await http.post(
      Uri.parse("${BACKEND}admin/add"),
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        HttpHeaders.authorizationHeader: "Bearer ${html.window.localStorage["authToken"]}",
      },
      body: jsonEncode({
        "id": id,
      })
  );

  if (response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.created) {
    return true;
  }

  return false;
}

Future<bool> answerRequest(String id, bool accept) async {
  final response = await http.put(
      Uri.parse("${BACKEND}admin/requests"),
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        HttpHeaders.authorizationHeader: "Bearer ${html.window.localStorage["authToken"]}",
      },
      body: jsonEncode({
        "id": id,
        "accept": accept
      })
  );

  if (response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.created) {
    return true;
  }

  return false;
}

Future<String> listUsers() async {
  final response = await http.post(
      Uri.parse("${BACKEND}admin/userlist"),
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        HttpHeaders.authorizationHeader: "Bearer ${html.window.localStorage["authToken"]}",
      },
      body: jsonEncode({
        "size": 1000,
        "offset": 0,
      })
  );

  print(response.body);

  if (response.statusCode == HttpStatus.unauthorized) {
    return "{}";
  }

  if (response.statusCode == HttpStatus.ok) {
    return response.body;
  }
  return "{}";
}

Future<String> listRequests() async {
  final response = await http.post(
      Uri.parse("${BACKEND}admin/requests"),
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        HttpHeaders.authorizationHeader: "Bearer ${html.window.localStorage["authToken"]}",
      },
      body: jsonEncode({
        "size": 1000,
        "offset": 0,
      })
  );

  print(response.body);

  if (response.statusCode == HttpStatus.unauthorized) {
    return "{}";
  }

  if (response.statusCode == HttpStatus.ok) {
    return response.body;
  }
  return "{}";
}