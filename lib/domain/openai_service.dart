import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:demux_app/data/api/base_api_repository.dart';
import 'package:demux_app/data/api/api_repository.dart';
import 'package:demux_app/data/api/mocked_api_repository.dart';
import 'package:demux_app/data/models/chat_completion_settings.dart';
import 'package:demux_app/data/models/message.dart';
import 'package:demux_app/domain/constants.dart';
import 'package:http/http.dart' as http;

class OpenAiService {
  String? apiKey;

  ApiRepositoryBase apiService = USE_MOCK_API_SERVICE
      ? MockedApiRepository(OPENAI_API_URL)
      : ApiRepository(OPENAI_API_URL);

  OpenAiService({this.apiKey});

  List<String> getImageUrlListFromResponse(http.Response response) {
    Map<String, dynamic> responseJson = jsonDecode(response.body);
    return List<String>.from(responseJson['data'].map((item) => item['url']));
  }

  bool isSuccess(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  List<String> processResponse(http.Response response) {
    if (isSuccess(response)) {
      return getImageUrlListFromResponse(response);
    } else {
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      print(responseJson);
      throw "Request failed: ${responseJson['error']['message']}";
    }
  }

  Map<String, String> getHeaders() {
    return {
      "Authorization": "Bearer $apiKey",
      "Content-Type": "application/json; charset=UTF-8",
    };
  }

  Future<List<String>> getGeneratedImages({
    required String prompt,
    required int quantity,
    required String size,
  }) async {
    Map<String, dynamic> body = {
      "prompt": prompt,
      "n": quantity,
      "size": size,
    };
    late http.Response response;
    try {
      response = await apiService.post(
          OPENAI_IMAGE_GENERATION_ENDPOINT, getHeaders(), body);
    } catch (e) {
      throw Exception('Server error');
    }
    return processResponse(response);
  }

  Future<List<String>> getImageVariations({
    required Uint8List image,
    required int quantity,
    required String size,
  }) async {
    http.MultipartFile imageFile =
        http.MultipartFile.fromBytes("image", image, filename: "image.png");

    Map<String, String> body = {
      "n": quantity.toString(),
      "size": size,
    };

    late http.Response response;
    try {
      response = await apiService.filePost(
          OPENAI_IMAGE_VARIATION_ENDPOINT, getHeaders(), body, [imageFile]);
    } catch (e) {
      throw Exception('Server error');
    }
    return processResponse(response);
  }

  Future<List<String>> getEditedImages({
    required Uint8List image,
    required Uint8List mask,
    required String prompt,
    required int quantity,
    required String size,
  }) async {
    http.MultipartFile imageFile =
        http.MultipartFile.fromBytes("image", image, filename: "image.png");

    http.MultipartFile maskFile =
        http.MultipartFile.fromBytes("mask", mask, filename: "mask.png");

    Map<String, String> body = {
      "prompt": prompt,
      "n": quantity.toString(),
      "size": size,
    };
    late http.Response response;
    try {
      response = await apiService.filePost(OPENAI_IMAGE_EDIT_ENDPOINT,
          getHeaders(), body, [imageFile, maskFile]);
    } catch (e) {
      throw Exception('Server error');
    }
    return processResponse(response);
  }

  String? dataMapper(String event) {
    event = event.substring(6);
    Map<String, dynamic> eventObj = jsonDecode(event);
    if (eventObj['choices'][0]["finish_reason"] == "stop") {
      return null;
    }
    return eventObj['choices'][0]['delta']['content'];
  }

  StreamController getChatResponseStream(
    ChatCompletionSettings chatCompletionSettings,
    List<Message> messages,
  ) {
    final body = chatCompletionSettings.getRequestJson();
    body['messages'] = messageListToJson(messages);

    Future<http.StreamedResponse> streamedResponseFuture =
        apiService.streamPost(
      OPENAI_CHAT_COMPLETION_ENDPOINT,
      getHeaders(),
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
        try {
          Map<String, dynamic> eventObj = jsonDecode(eventStr);
          if (eventObj.containsKey("error")) {
            streamController.addError(eventObj);
          }
        } catch (e) {
          // print(e);
        }

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
}
