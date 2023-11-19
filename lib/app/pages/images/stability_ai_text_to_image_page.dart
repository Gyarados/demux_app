import 'package:auto_route/auto_route.dart';
import 'package:demux_app/app/pages/images/cubit/image_api_cubit.dart';
import 'package:demux_app/app/pages/images/widgets/image_api_settings.dart';
import 'package:demux_app/app/pages/settings/cubit/app_settings_cubit.dart';
import 'package:demux_app/app/pages/images/widgets/image_results_widget.dart';
import 'package:demux_app/app/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class StabilityAiTextToImagePage extends StatefulWidget {
  const StabilityAiTextToImagePage({super.key});

  @override
  State<StabilityAiTextToImagePage> createState() =>
      _StabilityAiTextToImagePageState();
}

class _StabilityAiTextToImagePageState
    extends State<StabilityAiTextToImagePage> {
  final TextEditingController descriptionController = TextEditingController();

  bool loading = false;

  double quantity = 1;
  double height = 512;
  double width = 512;
  String engineId = "stable-diffusion-512-v2-1";

  StabilityAiTextToImageApiCubit imageResultsCubit =
      StabilityAiTextToImageApiCubit();
  late AppSettingsCubit appSettingsCubit;

  @override
  void initState() {
    appSettingsCubit = BlocProvider.of<AppSettingsCubit>(context);
    imageResultsCubit
        .setStabilityAiApiKey(appSettingsCubit.getStabilityAiApiKey());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        getStabilityAiTextToImageAPISettings(
            loadingResults: loading,
            sendButtonText: "Get generated images!",
            descriptionController: descriptionController,
            sendButtonOnPressed: getImageGenerations,
            onHeightChanged: onHeightChanged,
            onWidthChanged: onWidthChanged,
            onQuantityChanged: onQuantityChanged,
            getSelectedModel: getSelectedModel,
            saveSelectedModel: saveSelectedModel,
            updateModelList: updateEngineList,
            height: height,
            width: width,
            quantity: quantity),
        ImageResultsWidget(imageResultsCubit),
      ],
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<List<String>> updateEngineList() async {
    return await imageResultsCubit.getStabilityAiEngines();
  }

  void saveSelectedModel(String selectedModel) {
    setState(() {
      engineId = selectedModel;
    });
  }

  String getSelectedModel() {
    return engineId;
  }

  void onHeightChanged(double value) {
    setState(() {
      height = value;
    });
  }

  void onWidthChanged(double value) {
    setState(() {
      width = value;
    });
  }

  void onQuantityChanged(double value) {
    setState(() {
      quantity = value;
    });
  }

  void getImageGenerations() async {
    setState(() {
      loading = true;
    });

    try {
      await imageResultsCubit.getStabilityAiTextToImage(
        prompt: descriptionController.text,
        quantity: quantity.toInt(),
        height: height.toInt(),
        width: width.toInt(),
        engineId: engineId,
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
