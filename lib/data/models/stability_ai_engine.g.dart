// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stability_ai_engine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StabilityAiEngine _$StabilityAiEngineFromJson(Map<String, dynamic> json) =>
    StabilityAiEngine(
      id: json['id'] as String,
      description: json['description'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$StabilityAiEngineToJson(StabilityAiEngine instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'name': instance.name,
      'type': instance.type,
    };
