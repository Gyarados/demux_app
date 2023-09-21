import 'package:demux_app/app/pages/base_openai_api_page.dart';
import 'package:demux_app/app/pages/settings/cubit/app_settings_cubit.dart';
import 'package:demux_app/data/models/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppSettingsPage extends OpenAIBasePage {
  @override
  final String pageName = "App Settings";
  @override
  final String? pageEndpoint = null;
  @override
  final String? apiReferenceUrl = null;

  AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  late AppSettingsCubit appSettingsCubit;

  @override
  void initState() {
    appSettingsCubit = BlocProvider.of<AppSettingsCubit>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettings>(
      builder: (context, settings) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Dark Mode"),
                  Switch(
                    value: settings.isDarkMode,
                    onChanged: (value) {
                      appSettingsCubit.updateDarkMode(value);
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text("Font Size: ${settings.fontSize.toStringAsFixed(1)}"),
              Slider(
                value: settings.fontSize,
                min: 10,
                max: 30,
                onChanged: (value) {
                  appSettingsCubit.updateFontSize(value);
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: "OpenAI API Key"),
                onChanged: (value) {
                  appSettingsCubit.updateApiKey(value);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
