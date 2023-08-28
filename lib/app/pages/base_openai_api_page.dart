import 'package:demux_app/data/api/api_service.dart';
import 'package:demux_app/domain/constants.dart';
import 'package:demux_app/data/api/mocked_api_service.dart';
import 'package:flutter/material.dart';

abstract class OpenAIBasePage extends StatefulWidget {
  final dynamic openAI = USE_MOCK_API_SERVICE
      ? MockedApiService(OPENAI_API_URL)
      : ApiService(OPENAI_API_URL);
  final String pageName = "Abstract";
  final String pageEndpoint = "Abstract";
  final String apiReferenceURL =
      "https://platform.openai.com/docs/api-reference/";

  OpenAIBasePage({super.key});

  // @override
  // State<ImageGenerationPage> createState() => _ImageGenerationPageState();
}
