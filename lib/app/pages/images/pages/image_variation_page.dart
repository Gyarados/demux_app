import 'dart:typed_data';

import 'package:demux_app/app/constants.dart';
import 'package:demux_app/app/pages/base_openai_api_page.dart';
import 'package:demux_app/app/pages/images/utils/image_processing.dart';
import 'package:demux_app/app/pages/images/widgets/image_api_settings.dart';
import 'package:demux_app/app/pages/images/widgets/image_results_list.dart';
import 'package:demux_app/app/pages/images/widgets/selected_image_widget.dart';
import 'package:demux_app/app/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import "package:http/http.dart" as http;

class ImageVariationPage extends OpenAIBasePage {
  @override
  final String pageName = "Image Variation";
  @override
  final String pageEndpoint = OPENAI_IMAGE_VARIATION_ENDPOINT;
  @override
  final String apiReferenceURL = OPENAI_IMAGE_VARIATION_REFERENCE;

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
          imageQuantityController: imageQuantityController,
          imageSizeOnChanged: imageSizeOnChanged,
          galleryOnPressed: galleryOnPressed,
          cameraOnPressed: cameraOnPressed,
          sendButtonOnPressed: getImageVariations,
        ),
        // if (selectedImage != null) Text("Selected image"),
        if (selectedImage != null)
          SelectedImageWidget(
            selectedImage: selectedImage!,
            loadingResults: loadingResults,
            closeButtonOnPressed: closeButtonOnPressed,
          ),
        getImageResultsWidget(context, imageUrls, loadingResults),
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

    http.MultipartFile imageFile = http.MultipartFile.fromBytes(
        "image", selectedImage!,
        filename: "image.png");

    Map<String, String> body = {
      "n": quantity.toString(),
      "size": selectedImageSize
    };

    try {
      Map<String, dynamic> response =
          await widget.openAI.filePost(widget.pageEndpoint, body, [imageFile]);
      setState(() {
        imageUrls =
            List<String>.from(response['data'].map((item) => item['url']));
      });
    } catch (e) {
      showSnackbar(e.toString(), context,
          criticality: MessageCriticality.error);
    }
    setState(() {
      loadingResults = false;
    });
  }
}
