import 'dart:convert';
import 'package:http/http.dart' as http;

class ResponseException implements Exception {
  Map<String, dynamic> responseJson;
  ResponseException(this.responseJson);
}

bool isSuccess(http.Response response) {
  return response.statusCode >= 200 && response.statusCode < 300;
}

dynamic processResponse(
  http.Response response,
) {
  dynamic  responseJson = jsonDecode(response.body);
  if (isSuccess(response)) {
    return responseJson;
  } else {
    // throw "Request failed: ${responseJson['error']['message']}";
    throw ResponseException(responseJson);
  }
}
