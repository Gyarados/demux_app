import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:demux_app/data/api/base_api_repository.dart';
import 'package:demux_app/data/api/api_repository.dart';
import 'package:demux_app/data/api/mocked_api_repository.dart';
import 'package:demux_app/data/models/chat_completion_settings.dart';
import 'package:demux_app/data/models/message.dart';
import 'package:demux_app/data/models/openai_model.dart';
import 'package:demux_app/domain/constants.dart';
import 'package:demux_app/domain/utils/process_response.dart';
import 'package:http/http.dart' as http;

class OpenAiService {
  String? apiKey;

  ApiRepositoryBase apiService = USE_MOCK_API_SERVICE
      ? MockedApiRepository(OPENAI_API_URL)
      : ApiRepository(OPENAI_API_URL);

  OpenAiService({this.apiKey});

  List<String> getImageUrlListFromJson(Map<String, dynamic> responseJson) {
    return List<String>.from(responseJson['data'].map((item) => item['url']));
  }

  List<String> getImageResultsFromResponse(http.Response response) {
    try {
      Map<String, dynamic> responseJson = processResponse(response);
      return getImageUrlListFromJson(responseJson);
    } on ResponseException catch (e) {
      throw Exception("Request failed: ${e.responseJson['error']['message']}");
    } catch (e) {
      throw Exception("Request failed");
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
    return getImageResultsFromResponse(response);
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
    return getImageResultsFromResponse(response);
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
    return getImageResultsFromResponse(response);
  }

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

  List<String> parseModelIds(
    List<OpenAiModel> models, {
    String? pattern,
    String? antiPattern,
  }) {
    List<String> modelIds = [];

    for (var model in models) {
      String id = model.id;
      if (pattern == null && antiPattern == null) {
        modelIds.add(id);
      }
      if (pattern != null && antiPattern == null) {
        if (id.contains(pattern)) {
          modelIds.add(id);
        }
      }
      if (pattern == null && antiPattern != null) {
        if (!id.contains(antiPattern)) {
          modelIds.add(id);
        }
      }
      if (pattern != null && antiPattern != null) {
        if (id.contains(pattern) && !id.contains(antiPattern)) {
          modelIds.add(id);
        }
      }
    }

    return modelIds;
  }

  Future<List<String>> getChatModels() async {
    late http.Response response;
    try {
      response = await apiService.get(OPENAI_MODEL_ENDPOINT, getHeaders());
    } catch (e) {
      throw Exception('Server error');
    }
    Map<String, dynamic> responseJson = {};
    try {
      responseJson = processResponse(response);
    } on ResponseException catch (error, _) {
      print(error.responseJson);
      return ["API Error"];
    }

    List<dynamic> dataJson = responseJson['data'];

    List<OpenAiModel> modelList = jsonToOpenAiModelList(dataJson);

    List<String> modelIds =
        parseModelIds(modelList, pattern: "gpt", antiPattern: "instruct");
    return modelIds;
  }
}
