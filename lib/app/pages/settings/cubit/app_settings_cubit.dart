import 'package:demux_app/data/models/app_settings.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class AppSettingsCubit extends HydratedCubit<AppSettings> {
  AppSettingsCubit() : super(AppSettings());

  void updateDarkMode(bool isDarkMode) {
    final newState = AppSettings(
      isDarkMode: isDarkMode,
      textScaleFactor: state.textScaleFactor,
      apiKey: state.apiKey,
    );
    emit(newState);
  }

  void updateTextScaleFactor(double textScaleFactor) {
    final newState = AppSettings(
      isDarkMode: state.isDarkMode,
      textScaleFactor: textScaleFactor,
      apiKey: state.apiKey,
    );
    emit(newState);
  }

  void updateApiKey(String apiKey) {
    final newState = AppSettings(
      isDarkMode: state.isDarkMode,
      textScaleFactor: state.textScaleFactor,
      apiKey: apiKey,
    );
    emit(newState);
  }

  void resetSettings() {
    final newState = AppSettings();
    emit(newState);
  }

  String getApiKey() {
    return state.apiKey;
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
