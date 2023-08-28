import 'dart:convert';
import 'dart:typed_data';

import 'package:demux_app/data/api/abstract_api_service.dart';
import 'package:demux_app/data/api/api_service.dart';
import 'package:demux_app/data/api/mocked_api_service.dart';
import 'package:demux_app/domain/constants.dart';
import 'package:http/http.dart' as http;

class OpenAiRepository {
  ApiServiceBase apiService = USE_MOCK_API_SERVICE
      ? MockedApiService(OPENAI_API_URL)
      : ApiService(OPENAI_API_URL);

  OpenAiRepository();

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
      "Authorization": "Bearer $OPENAI_API_KEY",
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
}
