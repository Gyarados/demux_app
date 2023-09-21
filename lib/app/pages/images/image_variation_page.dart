import 'dart:typed_data';

import 'package:demux_app/domain/constants.dart';
import 'package:demux_app/app/pages/base_openai_api_page.dart';
import 'package:demux_app/app/pages/images/utils/image_processing.dart';
import 'package:demux_app/app/pages/images/widgets/image_api_settings.dart';
import 'package:demux_app/app/pages/images/widgets/image_results/cubit/image_results_cubit.dart';
import 'package:demux_app/app/pages/images/widgets/image_results/image_results_widget.dart';
import 'package:demux_app/app/utils/show_snackbar.dart';
import 'package:demux_app/domain/openai_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageVariationPage extends OpenAIBasePage {
  @override
  final String pageName = "Image Variation";
  @override
  final String pageEndpoint = OPENAI_IMAGE_VARIATION_ENDPOINT;
  @override
  final String apiReferenceUrl = OPENAI_IMAGE_VARIATION_REFERENCE;

  ImageVariationPage({super.key});

  @override
  State<ImageVariationPage> createState() => _ImageVariationPageState();
}

class _ImageVariationPageState extends State<ImageVariationPage> {
  final TextEditingController imageQuantityController =
      TextEditingController(text: "1");
  List<String> imageSizeList = OPENAI_IMAGE_SIZE_LIST;
  late String selectedImageSize = imageSizeList.first;

  Uint8List? selectedImage;

  bool loadingResults = false;
  bool loadingSelectedImage = false;

  List<String> imageUrls = [];

  VariationImageResultsCubit imageResultsCubit = VariationImageResultsCubit();
  final openAiService = OpenAiService();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        getImageVariationAPISettings(
            loadingResults: loadingResults,
            loadingSelectedImage: loadingSelectedImage,
            selectedImageSize: selectedImageSize,
            sendButtonText: "Get variations!",
            sendButtonEnabled: selectedImage != null && !loadingSelectedImage,
            selectedImage: selectedImage,
            imageQuantityController: imageQuantityController,
            imageSizeOnChanged: imageSizeOnChanged,
            galleryOnPressed: galleryOnPressed,
            cameraOnPressed: cameraOnPressed,
            sendButtonOnPressed: getImageVariations,
            closeButtonOnPressed: closeButtonOnPressed),
        getImageResultsWidget(imageResultsCubit),
      ],
    );
  }

  @override
  void dispose() {
    imageQuantityController.dispose();
    super.dispose();
  }

  void closeButtonOnPressed() {
    setState(() {
      selectedImage = null;
    });
  }

  void imageSizeOnChanged(String? value) {
    setState(() {
      selectedImageSize = value!;
    });
  }

  void galleryOnPressed() {
    selectImage(ImageSource.gallery);
  }

  void cameraOnPressed() {
    selectImage(ImageSource.camera);
  }

  void selectImage(ImageSource source) async {
    setState(() {
      loadingSelectedImage = true;
    });

    try {
      XFile? imageFile = await pickImage(source);
      if (imageFile != null) {
        Uint8List pngBytes = await processImageFile(imageFile);
        setState(() {
          selectedImage = pngBytes;
        });
      }
    } catch (e) {
      showSnackbar(e.toString(), context,
          criticality: MessageCriticality.error);
    }

    setState(() {
      loadingSelectedImage = false;
    });
  }

  void getImageVariations() async {
    setState(() {
      loadingResults = true;
    });

    late int quantity;
    try {
      quantity = int.parse(imageQuantityController.text);
    } catch (e) {
      showSnackbar("Invalid quantity", context,
          criticality: MessageCriticality.warning);
      return;
    }

    try {
      imageUrls = await openAiService.getImageVariations(
        image: selectedImage!,
        quantity: quantity,
        size: selectedImageSize,
      );

      setState(() {});

      imageResultsCubit.showImageResults(imageUrls);
    } catch (e) {
      showSnackbar(e.toString(), context,
          criticality: MessageCriticality.error);
    }
    setState(() {
      loadingResults = false;
    });
  }
}
