import 'package:demux_app/data/api/http_client/base_http_client.dart';
import 'package:fetch_client/fetch_client.dart';
import 'package:http/http.dart' as http;

class HttpClientImplementation extends BaseHttpClient {
  @override
  Future<http.StreamedResponse> send(http.Request request) {
    var client = FetchClient(mode: RequestMode.cors, streamRequests: true);
    Future<http.StreamedResponse> streamedResponseFuture = client.send(request);
    return streamedResponseFuture;
  }
}
