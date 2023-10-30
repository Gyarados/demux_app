import 'package:http/http.dart' as http;

abstract class BaseHttpClient {
  Future<http.StreamedResponse> send(http.Request request);
}
