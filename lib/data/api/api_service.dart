import 'dart:async';
import 'dart:convert';
import 'package:demux_app/data/api/abstract_api_service.dart';
import 'package:http/http.dart' as http;

class ApiService extends ApiServiceBase {
  static final _client = http.Client();

  ApiService(super.baseUrl);

  @override
  Future<http.Response> get(
      String endpoint, Map<String, String> headers) async {
    Uri endpointUri = Uri.parse(endpoint);
    Uri fullUri = baseUrl.resolveUri(endpointUri);
    http.Response response = await _client.get(
      fullUri,
      headers: headers,
    );
    return response;
  }

  @override
  Future<http.Response> post(
    String endpoint,
    Map<String, String> headers,
    Map<String, dynamic> body,
  ) async {
    Uri endpointUri = Uri.parse(endpoint);
    Uri fullUri = baseUrl.resolveUri(endpointUri);

    http.Response response = await _client.post(
      fullUri,
      headers: headers,
      body: jsonEncode(body),
    );

    return response;
  }

  @override
  Future<http.StreamedResponse> streamPost(
    String endpoint,
    Map<String, String> headers,
    Map<String, dynamic> body,
  ) {
    Uri endpointUri = Uri.parse(endpoint);
    Uri fullUri = baseUrl.resolveUri(endpointUri);
    final request = http.Request(
      "POST",
      fullUri,
    );
    request.headers.addAll(headers);
    request.body = jsonEncode(body);
    Future<http.StreamedResponse> streamedResponseFuture =
        _client.send(request);
    return streamedResponseFuture;
  }

  @override
  Future<http.Response> filePost(
    String endpoint,
    Map<String, String> headers,
    Map<String, String> body,
    List<http.MultipartFile> files,
  ) async {
    Uri endpointUri = Uri.parse(endpoint);
    Uri fullUri = baseUrl.resolveUri(endpointUri);
    var request = http.MultipartRequest("POST", fullUri);
    request.headers.addAll(headers);
    request.fields.addAll(body);
    request.files.addAll(files);
    final responseStream = await request.send();
    final response = await http.Response.fromStream(responseStream);
    return response;
  }
}
