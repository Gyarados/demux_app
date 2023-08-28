import 'dart:async';
import 'dart:convert';
import 'package:demux_app/data/api/abstract_api_service.dart';
import 'package:http/http.dart' as http;

import 'package:demux_app/domain/constants.dart';

class MockedApiService extends ApiServiceBase {
  static final _client = http.Client();

  Map<String, String> mockedImageUrls = {
    '1024x1024': 'https://i.imgur.com/0tkMZOt.png',
    '512x512': 'https://i.imgur.com/UDUgasP.png',
    '256x256': 'https://i.imgur.com/tBKMUlu_ERROR.png',
  };

  MockedApiService(super.baseUrl);

  http.Response mockImageResults(Map<String, dynamic> body) {
    int quantity = body["n"] as int;
    String size = body["size"] as String;
    List data = List.generate(quantity, (i) => {"url": mockedImageUrls[size]});
    Map<String, dynamic> mockedResponse = {"data": data};

    return http.Response(jsonEncode(mockedResponse), 200);
  }

  @override
  Future<http.Response> get(
    String endpoint,
    Map<String, String> headers,
  ) async {
    Uri endpointUri = Uri.parse(endpoint);
    Uri fullUri = baseUrl.resolveUri(endpointUri);
    http.Response response = await _client.get(
      fullUri,
      headers: <String, String>{
        'Authorization': "Bearer $OPENAI_API_KEY",
      },
    );
    return response;
  }

  @override
  Future<http.Response> post(
    String endpoint,
    Map<String, String> headers,
    Map<String, dynamic> body,
  ) async {
    http.Response response = mockImageResults(body);
    await Future.delayed(Duration(seconds: 1));
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
    request.headers.addAll({
      'Authorization': "Bearer $OPENAI_API_KEY",
      'Content-Type': 'application/json; charset=UTF-8',
    });
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
    http.Response response = mockImageResults(body);
    await Future.delayed(Duration(seconds: 1));
    return response;
  }
}
