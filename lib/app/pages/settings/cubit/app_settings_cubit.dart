import 'package:demux_app/data/models/app_settings.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class AppSettingsCubit extends HydratedCubit<AppSettings> {
  AppSettingsCubit() : super(AppSettings());

  void updateDarkMode(bool isDarkMode) {
    final newState = AppSettings(
      isDarkMode: isDarkMode,
      textScaleFactor: state.textScaleFactor,
      apiKey: state.apiKey,
      showIntroductionMessages: state.showIntroductionMessages,
    );
    emit(newState);
  }

  void updateTextScaleFactor(double textScaleFactor) {
    final newState = AppSettings(
      isDarkMode: state.isDarkMode,
      textScaleFactor: textScaleFactor,
      apiKey: state.apiKey,
      showIntroductionMessages: state.showIntroductionMessages,
    );
    emit(newState);
  }

  void updateApiKey(String apiKey) {
    final newState = AppSettings(
      isDarkMode: state.isDarkMode,
      textScaleFactor: state.textScaleFactor,
      apiKey: apiKey,
      showIntroductionMessages: state.showIntroductionMessages,
    );
    emit(newState);
  }

  void resetTextScaleFactor() {
    final newState = AppSettings(
      apiKey: state.apiKey,
      showIntroductionMessages: state.showIntroductionMessages,
    );
    emit(newState);
  }

  void resetOpenAIAPIKey() {
    final newState = AppSettings(
      textScaleFactor: state.textScaleFactor,
      showIntroductionMessages: state.showIntroductionMessages,
    );
    emit(newState);
  }

  void toggleShowIntroductionMessages(bool value) {
    final newState = AppSettings(
      apiKey: state.apiKey,
      textScaleFactor: state.textScaleFactor,
      showIntroductionMessages: value,
    );
    emit(newState);
  }

  bool showIntroductionMessages() {
    return (state.showIntroductionMessages);
  }

  String getApiKey() {
    return state.apiKey;
  }

  bool apiKeyExists() {
    return state.apiKey.isNotEmpty;
  }

  bool apiKeyIsMissing() {
    return state.apiKey.isEmpty;
  }

  double getTextScaleFactor() {
    return state.textScaleFactor;
  }

  @override
  AppSettings? fromJson(Map<String, dynamic> json) {
    return AppSettings.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(AppSettings state) {
    return state.toJson();
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print(error);
    super.onError(error, stackTrace);
  }
}
