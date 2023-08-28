// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_completion_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatCompletionRequestBody _$ChatCompletionRequestBodyFromJson(
        Map<String, dynamic> json) =>
    ChatCompletionRequestBody(
      model: json['model'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      temperature: (json['temperature'] as num?)?.toDouble() ?? 1,
      topP: (json['top_p'] as num?)?.toDouble(),
    )
      ..n = json['n'] as int?
      ..stream = json['stream'] as bool
      ..stop = json['stop'] as List<dynamic>?
      ..maxTokens = json['max_tokens'] as int?
      ..presencePenalty = (json['presence_penalty'] as num?)?.toDouble()
      ..frequencyPenalty = (json['frequency_penalty'] as num?)?.toDouble()
      ..logitBias = json['logit_bias'] as Map<String, dynamic>?;

Map<String, dynamic> _$ChatCompletionRequestBodyToJson(
    ChatCompletionRequestBody instance) {
  final val = <String, dynamic>{
    'model': instance.model,
    'messages': instance.messages.map((e) => e.toJson()).toList(),
    'temperature': instance.temperature,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('top_p', instance.topP);
  writeNotNull('n', instance.n);
  val['stream'] = instance.stream;
  writeNotNull('stop', instance.stop);
  writeNotNull('max_tokens', instance.maxTokens);
  writeNotNull('presence_penalty', instance.presencePenalty);
  writeNotNull('frequency_penalty', instance.frequencyPenalty);
  writeNotNull('logit_bias', instance.logitBias);
  return val;
}
