import 'package:auto_route/auto_route.dart';
import 'package:demux_app/app/pages/images/cubit/image_api_cubit.dart';
import 'package:demux_app/domain/constants.dart';
import 'package:demux_app/app/pages/images/widgets/image_api_settings.dart';
import 'package:demux_app/app/pages/settings/cubit/app_settings_cubit.dart';
import 'package:demux_app/app/pages/images/widgets/image_results_widget.dart';
import 'package:demux_app/app/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ImageGenerationPage extends StatefulWidget {
  ImageGenerationPage();

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

  GenerationImageApiCubit imageResultsCubit = GenerationImageApiCubit();
  late AppSettingsCubit appSettingsCubit;

  @override
  void initState() {
    appSettingsCubit = BlocProvider.of<AppSettingsCubit>(context);
    imageResultsCubit.setApiKey(appSettingsCubit.getApiKey());
    super.initState();
  }

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

      setState(() {
        loading = false;
      });
      return;
    }

    try {
      await imageResultsCubit.getGeneratedImages(
        prompt: description,
        quantity: quantity,
        size: selectedImageSize,
      );

      setState(() {});
    } catch (e) {
      showSnackbar(e.toString(), context,
          criticality: MessageCriticality.error);
    }
    setState(() {
      loading = false;
    });
  }
}
