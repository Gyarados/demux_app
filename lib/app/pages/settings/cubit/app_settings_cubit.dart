
import 'package:demux_app/data/models/app_settings.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class AppSettingsCubit extends HydratedCubit<AppSettings> {
  AppSettingsCubit() : super(AppSettings(false, 16.0, '')); // initial state

  void updateDarkMode(bool isDarkMode) {
    final newState = AppSettings(isDarkMode, state.fontSize, state.apiKey);
    emit(newState);
  }

  void updateFontSize(double fontSize) {
    final newState = AppSettings(state.isDarkMode, fontSize, state.apiKey);
    emit(newState);
  }

  void updateApiKey(String apiKey) {
    final newState = AppSettings(state.isDarkMode, state.fontSize, apiKey);
    emit(newState);
  }

  String getApiKey(){
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
}