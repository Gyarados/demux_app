import 'dart:typed_data';

import 'package:demux_app/app/pages/images/cubit/image_api_states.dart';
import 'package:demux_app/domain/openai_service.dart';
import 'package:demux_app/domain/stability_ai_service.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ImageApiCubit extends HydratedCubit<ImageApiState> {
  final OpenAiService openAiService = OpenAiService();
  final StabilityAiService stabilityAiService = StabilityAiService();

  ImageApiCubit() : super(ImageApiRequested());

  void setOpenAiApiKey(String apiKey) {
    openAiService.apiKey = apiKey;
  }

  void setStabilityAiApiKey(String apiKey) {
    stabilityAiService.apiKey = apiKey;
  }

  Future<void> getGeneratedImages({
    required String prompt,
    required int quantity,
    required String size,
  }) async {
    List<String> imageUrls = await openAiService.getGeneratedImages(
      prompt: prompt,
      quantity: quantity,
      size: size,
    );
    emit(ImageApiRequested(prompt: prompt, urls: imageUrls));
  }

  Future<void> getImageEdits({
    required String prompt,
    required int quantity,
    required String size,
    required Uint8List image,
    required Uint8List mask,
  }) async {
    List<String> imageUrls = await openAiService.getEditedImages(
      prompt: prompt,
      quantity: quantity,
      size: size,
      image: image,
      mask: mask,
    );
    emit(ImageApiRequested(prompt: prompt, urls: imageUrls));
  }

  Future<void> getImageVariations({
    required int quantity,
    required String size,
    required Uint8List image,
  }) async {
    List<String> imageUrls = await openAiService.getImageVariations(
      quantity: quantity,
      size: size,
      image: image,
    );
    emit(ImageApiRequested(urls: imageUrls));
  }

  Future<List<String>> getStabilityAiEngines() async {
    return await stabilityAiService.getEngines();
  }

  // String getSelectedModel() {
  //   return state.currentChat.chatCompletionSettings.model;
  // }

  Future<void> getStabilityAiTextToImage({
    required String engineId,
    required String prompt,
    required int quantity,
    required int height,
    required int width,
  }) async {
    List<String> imageb64Strings = await stabilityAiService.getGeneratedImages(
      engineId: engineId,
      prompt: prompt,
      quantity: quantity,
      height: height,
      width: width,
    );
    emit(ImageApiRequested(prompt: prompt, b64Strings: imageb64Strings));
  }

  @override
  ImageApiState fromJson(Map<String, dynamic> json) {
    return ImageApiRequested(
      prompt: json['prompt'] as String?,
      urls: json['urls'] as List<String>?,
      b64Strings: json['b64Strings'] as List<String>?,
    );
  }

  @override
  Map<String, dynamic>? toJson(ImageApiState state) {
    if (state is ImageApiRequested) {
      return {
        'prompt': state.prompt,
        'urls': state.urls,
        'b64Strings': state.b64Strings,
      };
    }
    return null;
  }
}

class GenerationImageApiCubit extends ImageApiCubit {}

class VariationImageApiCubit extends ImageApiCubit {}

class EditImageApiCubit extends ImageApiCubit {}

class StabilityAiTextToImageApiCubit extends ImageApiCubit {}
