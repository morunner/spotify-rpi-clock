import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:supabase_flutter/supabase_flutter.dart';

class ApiCaller {
  ApiCaller();

  Future<String> getFromUrl(String uri) async {
    String access_token =
        Supabase.instance.client.auth.currentSession!.providerToken.toString();

    final response = await http.get(Uri.parse(uri), headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $access_token'
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['images'][0]['url'].toString();
    } else {
      String errorResponseMessage =
          jsonDecode(response.body)['error']['message'].toString();
      throw Exception(
          "Failed to get: $response.statusCode : $errorResponseMessage");
    }
  }
}
