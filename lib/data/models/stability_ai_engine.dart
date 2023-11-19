import 'package:json_annotation/json_annotation.dart';

part 'stability_ai_engine.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
)
class StabilityAiEngine {
  String id;
  String description;
  String name;
  String type;

  StabilityAiEngine({
    required this.id,
    required this.description,
    required this.name,
    required this.type,
  });

  factory StabilityAiEngine.fromJson(Map<String, dynamic> json) =>
      _$StabilityAiEngineFromJson(json);

  Map<String, dynamic> toJson() => _$StabilityAiEngineToJson(this);
}

List<StabilityAiEngine> jsonToStabilityAiEngineList(List<dynamic> dataJson) {
  return dataJson.map((modelJson) => StabilityAiEngine.fromJson(modelJson)).toList();
}
