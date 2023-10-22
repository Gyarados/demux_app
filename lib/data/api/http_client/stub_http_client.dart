import 'package:demux_app/data/api/http_client/base_http_client.dart';
import 'package:http/http.dart' as http;

class HttpClientImplementation extends BaseHttpClient {
  @override
  Future<http.StreamedResponse> send(http.Request request) {
    throw Exception("Stub implementation");
  }
}
