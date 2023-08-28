import 'dart:async';

import 'package:http/http.dart' as http;

abstract class ApiServiceBase {
  final Uri baseUrl;

  ApiServiceBase(String baseUrl) : baseUrl = Uri.parse(baseUrl);

  bool isSuccess(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<http.Response> get(String endpoint);
  Future<http.Response> post(String endpoint, Map<String, dynamic> body);
  StreamController streamPost(String endpoint, Map<String, dynamic> body);
  Future<http.Response> filePost(String endpoint, Map<String, String> body,
      List<http.MultipartFile> files);
}
