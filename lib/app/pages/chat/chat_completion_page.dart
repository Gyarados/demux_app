import 'package:demux_app/app/pages/chat/cubit/chat_completion_cubit.dart';
import 'package:demux_app/app/pages/chat/cubit/chat_completion_states.dart';
import 'package:demux_app/app/pages/chat/widgets/chat_widget.dart';
import 'package:demux_app/domain/constants.dart';
import 'package:demux_app/app/pages/base_openai_api_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/temperature_input_widget.dart';

class ChatCompletionPage extends OpenAIBasePage {
  @override
  final String pageName = "Chat Completion";
  @override
  final String pageEndpoint = OPENAI_CHAT_COMPLETION_ENDPOINT;
  @override
  final String apiReferenceUrl = OPENAI_CHAT_COMPLETION_REFERENCE;

  ChatCompletionPage({super.key});

  @override
  State<ChatCompletionPage> createState() => _ChatCompletionPageState();
}

class _ChatCompletionPageState extends State<ChatCompletionPage> {
  final systemPromptController = TextEditingController();
  final temperatureController = TextEditingController();
  final topPController = TextEditingController();
  final quantityController = TextEditingController();
  final stopController = TextEditingController();
  final maxTokensController = TextEditingController();
  final presencePenaltyController = TextEditingController();
  final frequencyPenaltyController = TextEditingController();
  final logitBiasController = TextEditingController();
  final ExpansionTileController settingsExpandController =
      ExpansionTileController();
  int systemPromptMaxLines = 1;
  FocusNode systemPromptFocusNode = FocusNode();
  bool loading = false;
  List<String> modelList = OPENAI_CHAT_COMPLETION_MODEL_LIST;

  ChatCompletionCubit chatCompletionCubit = ChatCompletionCubit();
  String selectedModel = OPENAI_CHAT_COMPLETION_DEFAULT_MODEL;
  bool systemPromptsAreVisible = true;
  bool sendEmptyMessage = false;

  systemPromptListener() {
    if (systemPromptFocusNode.hasFocus) {
      setState(() {
        systemPromptMaxLines = 5;
      });
    } else {
      setState(() {
        systemPromptMaxLines = 1;
      });
    }
  }

  @override
  void initState() {
    systemPromptFocusNode.addListener(systemPromptListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => chatCompletionCubit,
      child: Scaffold(
        body: BlocBuilder<ChatCompletionCubit, ChatCompletionState>(
          builder: (context, state) {
            if (state is ChatCompletionRetrievedFromMemory) {
              selectedModel = state.chatCompletionSettings.model;
              systemPromptController.text =
                  state.chatCompletionSettings.systemPrompt ?? "";
              temperatureController.text =
                  state.chatCompletionSettings.temperature.toString();
              systemPromptsAreVisible =
                  state.chatCompletionSettings.systemPromptsAreVisible ?? true;
              sendEmptyMessage =
                  state.chatCompletionSettings.sendEmptyMessage ?? false;
            }
            return Column(children: [
              getAPISettings(),
              Expanded(
                child: Listener(
                  onPointerDown: (_) => settingsExpandController.collapse(),
                  child: ChatWidget(),
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    systemPromptController.dispose();
    temperatureController.dispose();
    super.dispose();
  }

  void onTemperatureChanged(String value) {
    chatCompletionCubit.saveTemperature(temperatureController.text);
  }

  Widget getAPISettings() {
    return Container(
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.blueGrey[200]!)),
        child: ExpansionTile(
          controller: settingsExpandController,
          maintainState: true,
          tilePadding: EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.settings),
              Text(selectedModel),
              Icon(Icons.thermostat),
              Text(temperatureController.text),
            ],
          ),
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: 'Model',
                      contentPadding: EdgeInsets.all(0.0),
                    ),
                    value: selectedModel,
                    onChanged: !loading
                        ? (String? value) {
                            setState(() {
                              selectedModel = value!;
                            });
                            chatCompletionCubit
                                .saveSelectedModel(selectedModel);
                          }
                        : null,
                    items:
                        modelList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: getTemperatureInputWidget(
                      temperatureController, loading, onTemperatureChanged),
                ),
              ],
            ),
            TextField(
              focusNode: systemPromptFocusNode,
              enabled: !loading,
              onChanged: (value) {
                chatCompletionCubit
                    .saveSystemPrompt(systemPromptController.text);
              },
              controller: systemPromptController,
              maxLines: systemPromptMaxLines,
              minLines: 1,
              decoration: InputDecoration(
                labelText: 'System prompt',
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Show system prompts'),
                Checkbox(
                  value: systemPromptsAreVisible,
                  onChanged: (newValue) {
                    setState(() {
                      systemPromptsAreVisible = newValue!;
                    });
                    chatCompletionCubit
                        .saveShowSystemPrompt(systemPromptsAreVisible);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Send empty message'),
                Checkbox(
                  value: sendEmptyMessage,
                  onChanged: (newValue) {
                    setState(() {
                      sendEmptyMessage = newValue!;
                    });
                    chatCompletionCubit.saveSendEmptyMessage(sendEmptyMessage);
                  },
                ),
              ],
            ),
          ],
        ));
  }
}
