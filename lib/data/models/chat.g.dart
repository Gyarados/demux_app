// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat(
      messages: (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      chatCompletionSettings: ChatCompletionSettings.fromJson(
          json['chat_completion_settings'] as Map<String, dynamic>),
      uuid: json['uuid'] as String?,
      name: json['name'] as String? ?? "New chat",
    );

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
      'messages': instance.messages.map((e) => e.toJson()).toList(),
      'chat_completion_settings': instance.chatCompletionSettings.toJson(),
      'uuid': instance.uuid,
      'name': instance.name,
    };
