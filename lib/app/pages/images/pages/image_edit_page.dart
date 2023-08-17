import 'dart:typed_data';

import 'package:demux_app/app/constants.dart';
import 'package:demux_app/app/pages/base_openai_api_page.dart';
import 'package:demux_app/app/pages/images/utils/image_processing.dart';
import 'package:demux_app/app/pages/images/widgets/edit_area_painter.dart';
import 'package:demux_app/app/pages/images/widgets/image_api_settings.dart';
import 'package:demux_app/app/pages/images/widgets/image_results_list.dart';
import 'package:demux_app/app/pages/images/widgets/selectable_area_image_widget.dart';
import 'package:demux_app/app/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import "package:http/http.dart" as http;

class ImageEditPage extends OpenAIBasePage {
  @override
  final String pageName = "Image Edit";
  @override
  final String pageEndpoint = OPENAI_IMAGE_EDIT_ENDPOINT;
  @override
  final String apiReferenceURL = OPENAI_IMAGE_EDIT_REFERENCE;

  ImageEditPage({super.key});

  @override
  State<ImageEditPage> createState() => _ImageEditPageState();
}

class _ImageEditPageState extends State<ImageEditPage> {
  final TextEditingController imageQuantityController =
      TextEditingController(text: "1");
  final TextEditingController descriptionController = TextEditingController();
  late String selectedImageSize = OPENAI_IMAGE_SIZE_LIST.first;

  Uint8List? selectedImage;
  Uint8List? mask;
  EditAreaPainter editAreaPainter = EditAreaPainter();

  bool loadingResults = false;
  bool loadingSelectedImage = false;

  List<String> imageUrls = [];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        getImageEditAPISettings(
          loadingResults: loadingResults,
          loadingSelectedImage: loadingSelectedImage,
          selectedImageSize: selectedImageSize,
          sendButtonText: "Get edits!",
          sendButtonEnabled: selectedImage != null && !loadingSelectedImage,
          imageQuantityController: imageQuantityController,
          descriptionController: descriptionController,
          imageSizeOnChanged: imageSizeOnChanged,
          galleryOnPressed: galleryOnPressed,
          cameraOnPressed: cameraOnPressed,
          sendButtonOnPressed: getImageEdits,
        ),
        if (selectedImage != null)
          SelectableAreaImage(editAreaPainter, removeSelectedImage),
        getImageResultsWidget(context, imageUrls, loadingResults),
      ],
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    imageQuantityController.dispose();
    super.dispose();
  }

  void removeSelectedImage() {
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
        await editAreaPainter.updateImage(pngBytes);

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

  void getImageEdits() async {
    setState(() {
      loadingResults = true;
    });

    String description = descriptionController.text;

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

    mask = await editAreaPainter.exportMask();

    setState(() {});

    http.MultipartFile maskFile =
        http.MultipartFile.fromBytes("mask", mask!, filename: "mask.png");

    Map<String, String> body = {
      "prompt": description,
      "n": quantity.toString(),
      "size": selectedImageSize
    };

    try {
      Map<String, dynamic> response = await widget.openAI
          .filePost(widget.pageEndpoint, body, [imageFile, maskFile]);
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
