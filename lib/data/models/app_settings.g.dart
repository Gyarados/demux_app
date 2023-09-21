// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => AppSettings(
      json['isDarkMode'] as bool,
      (json['fontSize'] as num).toDouble(),
      json['apiKey'] as String,
    );

Map<String, dynamic> _$AppSettingsToJson(AppSettings instance) =>
    <String, dynamic>{
      'isDarkMode': instance.isDarkMode,
      'fontSize': instance.fontSize,
      'apiKey': instance.apiKey,
    };
