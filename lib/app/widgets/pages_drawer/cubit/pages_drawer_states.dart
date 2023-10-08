import 'package:demux_app/domain/constants.dart';

enum PageRoutes {
  chatCompletion,
  imageGeneration,
  imageVariation,
  imageEdit,
  appSettings,
}

List<PageRoutes> openAiPages = [
  PageRoutes.chatCompletion,
  PageRoutes.imageGeneration,
  PageRoutes.imageVariation,
  PageRoutes.imageEdit,
];

extension PageRoutesExtension on PageRoutes {
  String get path {
    switch (this) {
      case PageRoutes.chatCompletion:
        return '/chat-completion';
      case PageRoutes.imageGeneration:
        return '/image-generation';
      case PageRoutes.imageVariation:
        return '/image-variation';
      case PageRoutes.imageEdit:
        return '/image-edit';
      case PageRoutes.appSettings:
        return '/app-settings';
      default:
        return '';
    }
  }

  String get pageName {
    switch (this) {
      case PageRoutes.chatCompletion:
        return 'Chat Completion';
      case PageRoutes.imageGeneration:
        return 'Image Generation';
      case PageRoutes.imageVariation:
        return 'Image Variation';
      case PageRoutes.imageEdit:
        return 'Image Edit';
      case PageRoutes.appSettings:
        return 'App Settings';
      default:
        return '';
    }
  }

  String? get pageEndpoint {
    switch (this) {
      case PageRoutes.chatCompletion:
        return OPENAI_CHAT_COMPLETION_ENDPOINT;
      case PageRoutes.imageGeneration:
        return OPENAI_IMAGE_GENERATION_ENDPOINT;
      case PageRoutes.imageVariation:
        return OPENAI_IMAGE_VARIATION_ENDPOINT;
      case PageRoutes.imageEdit:
        return OPENAI_IMAGE_EDIT_ENDPOINT;
      case PageRoutes.appSettings:
        return null;
      default:
        return null;
    }
  }

  String? get apiReferenceUrl {
    switch (this) {
      case PageRoutes.chatCompletion:
        return OPENAI_CHAT_COMPLETION_REFERENCE;
      case PageRoutes.imageGeneration:
        return OPENAI_IMAGE_GENERATION_REFERENCE;
      case PageRoutes.imageVariation:
        return OPENAI_IMAGE_VARIATION_REFERENCE;
      case PageRoutes.imageEdit:
        return OPENAI_IMAGE_EDIT_REFERENCE;
      case PageRoutes.appSettings:
        return null;
      default:
        return null;
    }
  }
}
