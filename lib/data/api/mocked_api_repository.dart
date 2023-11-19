import 'dart:async';
import 'dart:convert';
import 'package:demux_app/data/api/base_api_repository.dart';
import 'package:http/http.dart' as http;

class MockedApiRepository extends ApiRepositoryBase {
  Map<String, String> mockedImageUrls = {
    '1024x1024': 'https://i.imgur.com/0tkMZOt.png',
    '512x512': 'https://i.imgur.com/UDUgasP.png',
    '256x256': 'https://i.imgur.com/tBKMUlu_ERROR.png',
  };

  MockedApiRepository(super.baseUrl);

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
    Map<String, dynamic> mockedResponse = {"data": "OK"};
    return http.Response(jsonEncode(mockedResponse), 200);
  }

  @override
  Future<http.Response> post(
    String endpoint,
    Map<String, String> headers,
    Map<String, dynamic> body,
  ) async {
    http.Response response = mockImageResults(body);
    await Future.delayed(const Duration(seconds: 1));
    return response;
  }

  @override
  Future<http.StreamedResponse> streamPost(
    String endpoint,
    Map<String, String> headers,
    Map<String, dynamic> body,
  ) async {
    final StreamController<List<int>> streamController = StreamController();

    const mockText =
        """Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
        Vivamus lacinia odio vitae vestibulum. Donec in efficitur leo. Integer nec felis purus. 
        Nullam sodales et eros nec facilisis. Nullam non dolor quis tellus dapibus tincidunt. 
        Mauris commodo, risus sit amet facilisis facilisis, turpis erat porta neque, 
        at ullamcorper arcu elit a eros. Vivamus eu vestibulum purus, sit amet dictum sapien. 
        Pellentesque orci ex, fringilla id ante sit amet, rutrum elementum nisl. 
        Etiam lacinia, nulla a vestibulum pharetra, justo nulla luctus urna, 
        vitae tempor dui est eget arcu.""";

    // Schedule the streaming of "Lorem Ipsum" text
    Future.microtask(() async {
      const chunkSize = 30; // Length of each chunk
      for (int i = 0; i < mockText.length; i += chunkSize) {
        final end =
            (i + chunkSize < mockText.length) ? i + chunkSize : mockText.length;
        final data = utf8.encode(mockText.substring(i, end));
        streamController.add(data);
        await Future.delayed(const Duration(milliseconds: 500));
      }

      streamController.close();
    });

    http.StreamedResponse streamedResponseFuture = http.StreamedResponse(
      streamController.stream,
      200,
      contentLength: null,
    );
    return streamedResponseFuture;
  }

  @override
  Future<http.Response> filePost(
    String endpoint,
    Map<String, String> headers,
    Map<String, String> body,
    List<http.MultipartFile> files,
  ) async {
    http.Response response = mockImageResults(body);
    await Future.delayed(const Duration(seconds: 1));
    return response;
  }
}
