import 'dart:async';

import 'package:demux_app/data/api/base_api_repository.dart';
import 'package:demux_app/data/api/api_repository.dart';
import 'package:demux_app/data/api/mocked_api_repository.dart';
import 'package:demux_app/data/models/stability_ai_engine.dart';
import 'package:demux_app/domain/constants.dart';
import 'package:demux_app/domain/utils/process_response.dart';
import 'package:http/http.dart' as http;

class StabilityAiService {
  String? apiKey;

  ApiRepositoryBase apiService = USE_MOCK_API_SERVICE
      ? MockedApiRepository(STABILITY_AI_API_URL)
      : ApiRepository(STABILITY_AI_API_URL);

  StabilityAiService({this.apiKey});

  List<String> getImageBase64ListFromJson(Map<String, dynamic> responseJson) {
    return List<String>.from(
        responseJson['artifacts'].map((item) => item['base64']));
  }

  List<String> getImageResultsFromResponse(http.Response response){
    try {
      Map<String, dynamic> responseJson = processResponse(response);
      return getImageBase64ListFromJson(responseJson);
    } on ResponseException catch (e) {
      throw Exception("Request failed: ${e.responseJson['message']}");
    } catch (e) {
      throw Exception("Request failed");
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

  Future<List<String>> getEngines() async {
    late http.Response response;
    try {
      response = await apiService.get(STABILITY_AI_ENGINES_ENDPOINT, getHeaders());
    } catch (e) {
      throw Exception('Server error');
    }
    List<dynamic> responseJson = processResponse(response);
    List<StabilityAiEngine> engineList = jsonToStabilityAiEngineList(responseJson);
    return engineList.map((e) => e.id).toList();
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
    return getImageResultsFromResponse(response);
  }
}
