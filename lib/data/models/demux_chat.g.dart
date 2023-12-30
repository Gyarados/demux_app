// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demux_chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DemuxChat _$DemuxChatFromJson(Map<String, dynamic> json) => DemuxChat(
      messages: (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DemuxChatToJson(DemuxChat instance) => <String, dynamic>{
      'messages': instance.messages.map((e) => e.toJson()).toList(),
    };
