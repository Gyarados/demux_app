import 'package:demux_app/domain/constants.dart';
import 'package:demux_app/app/pages/base_openai_api_page.dart';
import 'package:demux_app/app/pages/images/widgets/image_api_settings.dart';
import 'package:demux_app/app/pages/images/widgets/image_results/cubit/image_results_cubit.dart';
import 'package:demux_app/app/pages/images/widgets/image_results/image_results_widget.dart';
import 'package:demux_app/app/utils/show_snackbar.dart';
import 'package:flutter/material.dart';

class ImageGenerationPage extends OpenAIBasePage {
  @override
  final String pageName = "Image Generation";
  @override
  final String pageEndpoint = OPENAI_IMAGE_GENERATION_ENDPOINT;
  @override
  final String apiReferenceUrl = OPENAI_IMAGE_GENERATION_REFERENCE;

  ImageGenerationPage({super.key});

  @override
  State<ImageGenerationPage> createState() => _ImageGenerationPageState();
}

class _ImageGenerationPageState extends State<ImageGenerationPage> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageQuantityController =
      TextEditingController(text: "1");
  List<String> imageSizeList = OPENAI_IMAGE_SIZE_LIST;
  late String selectedImageSize = imageSizeList.first;

  bool loading = false;

  List<String> imageUrls = [];

  GenerationImageResultsCubit imageResultsCubit = GenerationImageResultsCubit();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        getImageGenerationAPISettings(
          loadingResults: loading,
          selectedImageSize: selectedImageSize,
          sendButtonText: "Get generations!",
          imageQuantityController: imageQuantityController,
          descriptionController: descriptionController,
          imageSizeOnChanged: imageSizeOnChanged,
          sendButtonOnPressed: getImageGenerations,
        ),
        getImageResultsWidget(imageResultsCubit),
      ],
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    imageQuantityController.dispose();
    super.dispose();
  }

  void imageSizeOnChanged(String? value) {
    setState(() {
      selectedImageSize = value!;
    });
  }

  void getImageGenerations() async {
    setState(() {
      loading = true;
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

    Map<String, dynamic> body = {
      "prompt": description,
      "n": quantity,
      "size": selectedImageSize
    };

    try {
      Map<String, dynamic> response =
          await widget.openAI.post(widget.pageEndpoint, body);
      setState(() {
        imageUrls =
            List<String>.from(response['data'].map((item) => item['url']));
      });

      imageResultsCubit.showImageResults(imageUrls);

    } catch (e) {
      showSnackbar(e.toString(), context,
          criticality: MessageCriticality.error);
    }
    setState(() {
      loading = false;
    });
  }
}
