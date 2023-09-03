import 'package:flutter/material.dart';

abstract class OpenAIBasePage extends StatefulWidget {
  final String pageName = "Abstract";
  final String pageEndpoint = "Abstract";
  final String apiReferenceUrl =
      "https://platform.openai.com/docs/api-reference/";

  OpenAIBasePage({super.key});

  // @override
  // State<ImageGenerationPage> createState() => _ImageGenerationPageState();
}
