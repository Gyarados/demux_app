// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openai_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAiModel _$OpenAiModelFromJson(Map<String, dynamic> json) => OpenAiModel(
      id: json['id'] as String,
      object: json['object'] as String,
      created: (json['created'] as num).toDouble(),
      ownedBy: json['owned_by'] as String,
    );

Map<String, dynamic> _$OpenAiModelToJson(OpenAiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'object': instance.object,
      'created': instance.created,
      'owned_by': instance.ownedBy,
    };
