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

  @override
  void initState() {
    appSettingsCubit = BlocProvider.of<AppSettingsCubit>(context);
    apiKeyController.text = appSettingsCubit.getApiKey();
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
              TextField(
                controller: apiKeyController,
                decoration: InputDecoration(labelText: "OpenAI API Key"),
                onChanged: (value) {
                  appSettingsCubit.updateApiKey(value);
                },
              ),
              // SizedBox(height: 16),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text("Dark Mode"),
              //     Switch(
              //       value: settings.isDarkMode,
              //       onChanged: (value) {
              //         appSettingsCubit.updateDarkMode(value);
              //       },
              //     ),
              //   ],
              // ),
              SizedBox(height: 16),
              Text("Font Size: ${settings.textScaleFactor.toStringAsFixed(2)}"),
              Slider(
                value: settings.textScaleFactor,
                min: 0.5,
                max: 3,
                onChanged: (value) {
                  appSettingsCubit.updateTextScaleFactor(value);
                },
              ),
              SizedBox(height: 16),
              Center(
                  child: TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.red),
                child: Text('Reset'),
                onPressed: () {
                  appSettingsCubit.resetSettings();
                  setState(() {
                    apiKeyController.text = appSettingsCubit.getApiKey();
                  });
                },
              )),
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
      horizontalTitleGap: 0,
      tileColor: getMessageColor(role),
      leading: Column(children: [
        Expanded(
            child: Icon(
          getMessageIcon(role),
        )),
        Expanded(
            child: Icon(
          Icons.more_horiz,
          color: Colors.black,
        ))
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
