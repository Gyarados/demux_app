import 'package:demux_app/app/widgets/pages_drawer/cubit/pages_drawer_states.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class PagesDrawerCubit extends HydratedCubit<PageRoutes> {
  PagesDrawerCubit() : super(PageRoutes.chatCompletion);

  // List<String> pageRoutes = [

  // ];

  // ChatCompletionPage chatCompletionPage = ChatCompletionPage();
  // ImageGenerationPage imageGenerationPage = ImageGenerationPage();
  // ImageEditPage imageEditPage = ImageEditPage();
  // ImageVariationPage imageVariationPage = ImageVariationPage();
  // AppSettingsPage appSettingsPage = AppSettingsPage();

  void navigateTo(PageRoutes route) {
    emit(route);
  }

  PageRoutes getCurrentPage() {
    return state;
  }

  bool isPageFromOpenAi(PageRoutes page) {
    return openAiPages.contains(page);
  }

  @override
  PageRoutes fromJson(Map<String, dynamic> json) {
    String path = json["path"];

    switch (path) {
      case '/chat-completion':
        return PageRoutes.chatCompletion;
      case '/image-generation':
        return PageRoutes.imageGeneration;
      case '/image-variation':
        return PageRoutes.imageVariation;
      case '/image-edit':
        return PageRoutes.imageEdit;
      case '/app-settings':
        return PageRoutes.appSettings;
      default:
        return PageRoutes.chatCompletion;
    }
  }

  @override
  Map<String, dynamic>? toJson(PageRoutes state) {
    return {"path": state.path};
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print("error in drawer cubit conversion:");
    print(error);
    super.onError(error, stackTrace);
  }
}
