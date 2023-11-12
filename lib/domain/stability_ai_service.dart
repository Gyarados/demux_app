import 'dart:async';
import 'dart:convert';

import 'package:demux_app/data/api/base_api_repository.dart';
import 'package:demux_app/data/api/api_repository.dart';
import 'package:demux_app/data/api/mocked_api_repository.dart';
import 'package:demux_app/domain/constants.dart';
import 'package:http/http.dart' as http;

class StabilityAiService {
  String? apiKey;

  ApiRepositoryBase apiService = USE_MOCK_API_SERVICE
      ? MockedApiRepository(STABILITY_AI_API_URL)
      : ApiRepository(STABILITY_AI_API_URL);

  StabilityAiService({this.apiKey});

  List<String> getImageUrlListFromResponse(http.Response response) {
    Map<String, dynamic> responseJson = jsonDecode(response.body);
    return List<String>.from(
        responseJson['artifacts'].map((item) => item['base64']));
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
      throw "Request failed: ${responseJson['message']}";
    }
  }

  String getEndpointWithEngineId(
    String engineId,
    String endpoint,
  ) {
    return endpoint.replaceAll('{engine_id}', engineId);
  }

  Map<String, String> getHeaders() {
    return {
      "Authorization": "Bearer $apiKey",
      "Content-Type": "application/json; charset=UTF-8",
    };
  }

  Future<List<String>> getGeneratedImages({
    required String engineId,
    required String prompt,
    required int quantity,
    required int height,
    required int width,
  }) async {
    Map<String, dynamic> body = {
      "text_prompts": [
        {
          "text": prompt,
          "weight": 1,
        }
      ],
      "samples": quantity,
      "height": height,
      "width": width,
    };
    late http.Response response;
    try {
      response = await apiService.post(
          getEndpointWithEngineId(
            engineId,
            STABILITY_AI_TEXT_TO_IMAGE_ENDPOINT,
          ),
          getHeaders(),
          body);
    } catch (e) {
      throw Exception('Server error');
    }
    return processResponse(response);
  }
}
