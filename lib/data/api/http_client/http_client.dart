import 'package:demux_app/data/api/http_client/stub_http_client.dart'
    if (dart.library.io) 'package:demux_app/data/api/http_client/mobile_http_client.dart'
    if (dart.library.html) 'package:demux_app/data/api/http_client/web_http_client.dart';
import 'package:http/http.dart' as http;

class HttpClient {
  final HttpClientImplementation _client;

  HttpClient() : _client = HttpClientImplementation();

  Future<http.StreamedResponse> send(http.Request request) {
    return _client.send(request);
  }
}
