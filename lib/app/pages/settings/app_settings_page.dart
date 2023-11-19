import 'package:auto_route/auto_route.dart';
import 'package:demux_app/app/pages/chat/widgets/chat_widget.dart';
import 'package:demux_app/app/pages/chat/widgets/double_slider_widget.dart';
import 'package:demux_app/app/pages/settings/cubit/app_settings_cubit.dart';
import 'package:demux_app/data/models/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';

@RoutePage()
class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  late AppSettingsCubit appSettingsCubit;
  final TextEditingController openAiApiKeyController = TextEditingController();
  final TextEditingController stabilityAiApiKeyController =
      TextEditingController();
  bool showIntroMessages = true;

  @override
  void initState() {
    appSettingsCubit = BlocProvider.of<AppSettingsCubit>(context);
    openAiApiKeyController.text = appSettingsCubit.getOpenAiApiKey();
    stabilityAiApiKeyController.text = appSettingsCubit.getStabilityAiApiKey();
    showIntroMessages = appSettingsCubit.showIntroductionMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettings>(
      builder: (context, settings) {
        print("Settings from BlocBuilder: ${settings.toJson()}");
        return Container(
          color: Colors.grey.shade200,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        obscureText: true,
                        controller: openAiApiKeyController,
                        decoration:
                            const InputDecoration(labelText: "OpenAI API Key"),
                        onChanged: (value) {
                          print("onChanged OpenAI API Key: $value");
                          appSettingsCubit.updateOpenAiApiKey(value);
                        },
                      ),
                    ),
                    if (openAiApiKeyController.text.isNotEmpty)
                      IconButton(
                          onPressed: () {
                            openAiApiKeyController.clear();
                            appSettingsCubit.resetOpenAiApiKey();
                          },
                          icon: const Icon(Icons.close))
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        obscureText: true,
                        controller: stabilityAiApiKeyController,
                        decoration:
                            const InputDecoration(labelText: "Stability AI API Key"),
                        onChanged: (value) {
                          print("onChanged Stability API Key: $value");
                          appSettingsCubit.updateStabilityAiApiKey(value);
                        },
                      ),
                    ),
                    if (stabilityAiApiKeyController.text.isNotEmpty)
                      IconButton(
                          onPressed: () {
                            stabilityAiApiKeyController.clear();
                            appSettingsCubit.resetStabilityAiApiKey();
                          },
                          icon: const Icon(Icons.close))
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: CheckboxListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: const Text("Show introduction messages"),
                  value: showIntroMessages,
                  onChanged: (newValue) {
                    setState(() {
                      showIntroMessages = newValue!;
                      appSettingsCubit.toggleShowIntroductionMessages(newValue);
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              DoubleSliderWidget(
                  label: "Text Scale Factor",
                  min: 0.5,
                  max: 3,
                  divisions: 25,
                  defaultValue: 1,
                  currentValue: settings.textScaleFactor,
                  onChanged: (value) =>
                      appSettingsCubit.updateTextScaleFactor(value),),
              const SizedBox(height: 16),
              Expanded(
                  child: ListView(
                children: [
                  chatExampleMessageWidget("user", settings.textScaleFactor),
                  chatExampleMessageWidget(
                      "assistant", settings.textScaleFactor),
                ],
              )),
            ],
          ),
        );
      },
    );
  }

  String getExampleUserMessage() {
    return "How does photosynthesis work?";
  }

  String getExampleAssistantMessage() {
    return """Photosynthesis is a process used by plants, algae, and some bacteria to convert light energy into chemical energy stored in glucose. In simple terms, they take in carbon dioxide from the air and water from the soil, and using light energy from the sun, they create glucose and release oxygen as a byproduct.

The process mainly consists of two stages: the light-dependent reactions and the Calvin cycle. The light-dependent reactions happen in the thylakoid membranes and convert light energy into ATP and NADPH. The Calvin cycle, which takes place in the stroma of the chloroplast, uses the ATP and NADPH to convert CO2 into glucose.

This is a simplified explanation, but it covers the basic idea. Would you like to know more about either stage?""";
  }

  Widget chatExampleMessageWidget(String role, double textScaleFactor) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 8, top: 0, bottom: 8, right: 8),
      // horizontalTitleGap: 0,
      tileColor: getMessageColor(role),
      leading: Column(children: [
        Expanded(
            child: Icon(
          getMessageIcon(role),
          color: Colors.blueGrey,
        )),
        // Expanded(
        //     child: Icon(
        //   Icons.more_horiz,
        //   color: Colors.black,
        // ))
      ]),
      titleAlignment: ListTileTitleAlignment.top,
      title: SelectionArea(
          child: MarkdownBody(
        data: role == "user"
            ? getExampleUserMessage()
            : getExampleAssistantMessage(),
        styleSheet: MarkdownStyleSheet(
            textScaleFactor: textScaleFactor,
            code: TextStyle(
              color: Colors.blueGrey.shade100,
              backgroundColor: Colors.grey.shade800,
            ),
            codeblockDecoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(5))),
      )),
    );
  }
}
