// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      json['role'] as String,
      json['content'] as String,
      image: imageFromJson(json['image'] as Map<String, dynamic>?),
      modelUsed: json['model_used'] as String?,
    );

Map<String, dynamic> _$MessageToJson(Message instance) {
  final val = <String, dynamic>{
    'role': instance.role,
    'content': instance.content,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('model_used', instance.modelUsed);
  writeNotNull('image', imageToJson(instance.image));
  return val;
}
