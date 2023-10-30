import 'package:auto_route/auto_route.dart';
import 'package:demux_app/app/pages/chat/widgets/chat_widget.dart';
import 'package:demux_app/app/pages/settings/cubit/app_settings_cubit.dart';
import 'package:demux_app/data/models/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';

@RoutePage()
class AppSettingsPage extends StatefulWidget {
  AppSettingsPage();

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  late AppSettingsCubit appSettingsCubit;
  final TextEditingController apiKeyController = TextEditingController();
  bool showIntroMessages = true;

  @override
  void initState() {
    appSettingsCubit = BlocProvider.of<AppSettingsCubit>(context);
    apiKeyController.text = appSettingsCubit.getApiKey();
    showIntroMessages = appSettingsCubit.showIntroductionMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettings>(
      builder: (context, settings) {
        return Container(
          color: Colors.grey.shade200,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        obscureText: true,
                        controller: apiKeyController,
                        decoration:
                            InputDecoration(labelText: "OpenAI API Key"),
                        onChanged: (value) {
                          appSettingsCubit.updateApiKey(value);
                        },
                      ),
                    ),
                    if (apiKeyController.text.isNotEmpty)
                      IconButton(
                          onPressed: () {
                            apiKeyController.clear();
                            appSettingsCubit.resetOpenAIAPIKey();
                          },
                          icon: Icon(Icons.close))
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.all(0),
                  title: Text("Show introduction messages"),
                  value: showIntroMessages,
                  onChanged: (newValue) {
                    setState(() {
                      showIntroMessages = newValue!;
                      appSettingsCubit.toggleShowIntroductionMessages(newValue);
                    });
                  },
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Text Scale Factor: ${settings.textScaleFactor.toStringAsFixed(2)}"),
                    Row(
                      children: [
                        Expanded(
                            child: Slider(
                          activeColor: Colors.blueGrey,
                          value: settings.textScaleFactor,
                          min: 0.5,
                          max: 3,
                          onChanged: (value) {
                            appSettingsCubit.updateTextScaleFactor(value);
                          },
                        )),
                        TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red),
                          child: Text('Reset'),
                          onPressed: () {
                            appSettingsCubit.resetTextScaleFactor();
                            setState(() {
                              apiKeyController.text =
                                  appSettingsCubit.getApiKey();
                            });
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
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
      contentPadding: EdgeInsets.only(left: 8, top: 0, bottom: 8, right: 8),
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
