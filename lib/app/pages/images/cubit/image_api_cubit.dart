import 'dart:typed_data';

import 'package:demux_app/app/pages/images/cubit/image_api_states.dart';
import 'package:demux_app/domain/openai_service.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ImageApiCubit extends HydratedCubit<ImageApiState> {
  final OpenAiService openAiService = OpenAiService();

  ImageApiCubit() : super(ImageApiRequested([]));

  void setApiKey(String apiKey) {
    openAiService.apiKey = apiKey;
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
    emit(ImageApiRequested(imageUrls));
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
    emit(ImageApiRequested(imageUrls));
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
    emit(ImageApiRequested(imageUrls));
  }

  @override
  ImageApiState fromJson(Map<String, dynamic> json) {
    return ImageApiRequested(json['results'] as List<String>);
  }

  @override
  Map<String, dynamic>? toJson(ImageApiState state) {
    if (state is ImageApiRequested) {
      return {'results': state.urls};
    }
    return null;
  }
}

class GenerationImageApiCubit extends ImageApiCubit {}

class VariationImageApiCubit extends ImageApiCubit {}

class EditImageApiCubit extends ImageApiCubit {}
