import 'dart:async';

import 'package:http/http.dart' as http;

abstract class ApiServiceBase {
  final Uri baseUrl;

  ApiServiceBase(String baseUrl) : baseUrl = Uri.parse(baseUrl);

  Future<http.Response> get(
    String endpoint,
    Map<String, String> headers,
  );
  Future<http.Response> post(
    String endpoint,
    Map<String, String> headers,
    Map<String, dynamic> body,
  );
  StreamController streamPost(
    String endpoint,
    Map<String, String> headers,
    Map<String, dynamic> body,
  );
  Future<http.Response> filePost(
    String endpoint,
    Map<String, String> headers,
    Map<String, String> body,
    List<http.MultipartFile> files,
  );
}
