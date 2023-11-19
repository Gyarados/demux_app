import 'package:json_annotation/json_annotation.dart';

part 'openai_model.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
)
class OpenAiModel {
  String id;
  String object;
  double created;
  String ownedBy;

  OpenAiModel({
    required this.id,
    required this.object,
    required this.created,
    required this.ownedBy,
  });

  factory OpenAiModel.fromJson(Map<String, dynamic> json) =>
      _$OpenAiModelFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiModelToJson(this);
}

List<OpenAiModel> jsonToOpenAiModelList(List<dynamic> dataJson) {
  return dataJson.map((modelJson) => OpenAiModel.fromJson(modelJson)).toList();
}
