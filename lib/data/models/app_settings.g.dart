// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      textScaleFactor: (json['textScaleFactor'] as num?)?.toDouble() ?? 1,
      apiKey: json['apiKey'] as String? ?? '',
    );

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'isDarkMode': instance.isDarkMode,
      'textScaleFactor': instance.textScaleFactor,
      'apiKey': instance.apiKey,
    };
