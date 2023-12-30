import 'dart:async';
import 'dart:convert';

import 'package:demux_app/data/api/base_api_repository.dart';
import 'package:demux_app/data/api/api_repository.dart';
import 'package:demux_app/data/api/mocked_api_repository.dart';
import 'package:demux_app/data/models/message.dart';
import 'package:demux_app/domain/constants.dart';
import 'package:demux_app/domain/utils/get_headers.dart';
import 'package:http/http.dart' as http;

class DemuxService {
  String? apiKey;

  ApiRepositoryBase apiService = USE_MOCK_API_SERVICE
      ? MockedApiRepository(DEMUX_API_URL)
      : ApiRepository(DEMUX_API_URL);

  DemuxService({this.apiKey});

  String? dataMapper(String event) {
    event = event.substring(6);
    Map<String, dynamic> eventObj = jsonDecode(event);
    var finishReason = eventObj['choices'][0]["finish_reason"];
    var finishDetails = eventObj['choices'][0]["finish_details"];
    if (finishReason != null || finishDetails != null) {
      return null;
    }
    var deltaContent = eventObj['choices'][0]['delta']['content'] ?? "";
    return deltaContent;
  }

  StreamController getChatResponseStream(
    List<Message> messages,
  ) {
    final body = <String, dynamic>{};
    body['model'] = 'deepseek-coder';
    body['messages'] = messageListToJson(messages);

    Future<http.StreamedResponse> streamedResponseFuture =
        apiService.streamPost(
      DEMUX_CHAT_COMPLETION_ENDPOINT,
      getHeaders(apiKey),
      body,
    );
    final streamController = StreamController<String>();

    streamedResponseFuture.then((streamedResponse) {
      Stream stream = streamedResponse.stream;
      stream = stream.transform(utf8.decoder);
      stream = stream.transform(const LineSplitter());

      late StreamSubscription<dynamic> subscription;
      subscription = stream.listen((event) {
        String eventStr = event;
        // try {
        //   Map<String, dynamic> eventObj = jsonDecode(eventStr);
        //   if (eventObj.containsKey("error")) {
        //     streamController.addError(eventObj);
        //   }
        // } catch (e) {
        //   // print(e);
        // }
        Map<String, dynamic> eventObj = jsonDecode(eventStr);

        Map<String, dynamic>? message = eventObj["message"];
        String? content = message?["content"];
        if (content != null && !streamController.isClosed) {
          try {
            streamController.add(content);
          } catch (e) {
            print(e);
          }
        } else {
          streamController.close();
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
}
