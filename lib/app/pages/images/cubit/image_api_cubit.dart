import 'dart:typed_data';

import 'package:demux_app/app/pages/images/cubit/image_api_states.dart';
import 'package:demux_app/domain/openai_service.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ImageApiCubit extends HydratedCubit<ImageApiState> {
  final OpenAiService openAiService = OpenAiService();

  ImageApiCubit() : super(ImageApiRequested());

  void setApiKey(String apiKey) {
    openAiService.apiKey = apiKey;
  }

  void generateImage(
    String prompt,
    int quantity,
    String size,
  ) async {
    List<String> imageUrls = await openAiService.getGeneratedImages(
      prompt: prompt,
      quantity: quantity,
      size: size,
    );
    emit(ImageApiRequested());
  }

  void editImage(String prompt, int quantity, String size, Uint8List image,
      Uint8List mask) async {
    List<String> imageUrls = await openAiService.getEditedImages(
      prompt: prompt,
      quantity: quantity,
      size: size,
      image: image,
      mask: mask,
    );
    emit(ImageApiRequested());
  }

  void getImageVariations(
    int quantity,
    String size,
    Uint8List image,
  ) async {
    List<String> imageUrls = await openAiService.getImageVariations(
      quantity: quantity,
      size: size,
      image: image,
    );
    emit(ImageApiRequested());
  }

  @override
  ImageApiState fromJson(Map<String, dynamic> json) {
    return ImageApiRequested();
  }

  @override
  Map<String, dynamic>? toJson(ImageApiState state) {
    return null;
  }
}

class GenerationImageApiCubit extends ImageApiCubit {}

class VariationImageApiCubit extends ImageApiCubit {}

class EditImageApiCubit extends ImageApiCubit {}
