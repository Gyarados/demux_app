import 'package:json_annotation/json_annotation.dart';

part 'app_settings.g.dart';

@JsonSerializable()
class AppSettings {
  bool isDarkMode;
  double textScaleFactor;
  String apiKey;

  AppSettings({this.isDarkMode = false, this.textScaleFactor = 1, this.apiKey = ''});

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);
}

List<Map<String, dynamic>> appSettingsListToJson(List<AppSettings> settings) {
  return settings.map((setting) => setting.toJson()).toList();
}

List<AppSettings> jsonToAppSettingsList(List<dynamic> settingsJson) {
  return settingsJson
      .map((settingJson) => AppSettings.fromJson(settingJson))
      .toList();
}
