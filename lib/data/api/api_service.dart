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

  String? dataMapper(String event) {
    event = event.substring(6);
    Map<String, dynamic> eventObj = jsonDecode(event);
    if (eventObj['choices'][0]["finish_reason"] == "stop") {
      return null;
    }
    return eventObj['choices'][0]['delta']['content'];
  }

  @override
  StreamController streamPost(
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

    final streamController = StreamController<String>();

    Future<http.StreamedResponse> streamedResponseFuture =
        _client.send(request);

    streamedResponseFuture.then((streamedResponse) {
      Stream stream = streamedResponse.stream;
      stream = stream.transform(utf8.decoder);
      stream = stream.transform(const LineSplitter());

      late StreamSubscription<dynamic> subscription;
      subscription = stream.listen((event) {
        String eventStr = event;
        if (eventStr.contains("data")) {
          String? data = dataMapper(eventStr);
          if (data != null && !streamController.isClosed) {
            try {
              streamController.add(data);
            } catch (e) {
              print(e);
            }
          } else {
            streamController.close();
          }
        }
        if (streamController.isClosed) {
          subscription.cancel();
        }
      }, onError: (error) {
        streamController.addError(error);
      }, onDone: () {
        streamController.close();
      });
    });

    return streamController;
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
