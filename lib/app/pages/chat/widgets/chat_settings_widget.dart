import 'package:demux_app/app/pages/chat/cubit/chat_completion_cubit.dart';
import 'package:demux_app/app/pages/chat/cubit/chat_completion_states.dart';
import 'package:demux_app/app/pages/chat/widgets/double_slider_widget.dart';
import 'package:demux_app/app/widgets/model_dropdown.dart';
import 'package:demux_app/data/models/chat.dart';
import 'package:demux_app/data/models/chat_completion_settings.dart';
import 'package:demux_app/domain/constants.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatSettingsWidget extends StatefulWidget {
  const ChatSettingsWidget({super.key});

  @override
  State<ChatSettingsWidget> createState() => _ChatSettingsWidgetState();
}

class _ChatSettingsWidgetState extends State<ChatSettingsWidget> {
  final systemPromptController = TextEditingController();
  final topPController = TextEditingController();
  final quantityController = TextEditingController();
  final stopController = TextEditingController();
  final maxTokensController = TextEditingController();
  final logitBiasController = TextEditingController();
  final ExpansionTileController settingsExpandController =
      ExpansionTileController();

  final ExpandableController settingsExpandControllerV3 =
      ExpandableController();

  bool settingsExpanded = false;

  int systemPromptMaxLines = 1;
  FocusNode systemPromptFocusNode = FocusNode();
  bool loading = false;

  String selectedModel = OPENAI_CHAT_COMPLETION_DEFAULT_MODEL;
  bool systemPromptsAreVisible = true;
  bool sendEmptyMessage = false;
  late ChatCompletionCubit chatCompletionCubit;

  Chat currentChat = Chat.initial();
  late ChatCompletionSettings chatCompletionSettings =
      currentChat.chatCompletionSettings;

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
    chatCompletionCubit = BlocProvider.of<ChatCompletionCubit>(context);
    updateSettingsFromState(chatCompletionCubit.state);
    systemPromptFocusNode.addListener(systemPromptListener);
    super.initState();
  }

  @override
  void dispose() {
    systemPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCompletionCubit, ChatCompletionState>(
      builder: (context, state) {
        if (state is ChatCompletionRetrievedFromMemory ||
            state is ChatCompletionChatSelected) {
          updateSettingsFromState(state);
        }
        return getAPISettingsV3();
      },
    );
  }

  void updateSettingsFromState(ChatCompletionState state) {
    currentChat = state.currentChat;
    chatCompletionSettings = currentChat.chatCompletionSettings;
    selectedModel = chatCompletionSettings.model;
    systemPromptController.text = chatCompletionSettings.systemPrompt ?? "";
    systemPromptsAreVisible =
        chatCompletionSettings.systemPromptsAreVisible ?? true;
    sendEmptyMessage = chatCompletionSettings.sendEmptyMessage ?? false;
  }

  Future<List<String>> updateModelList() async {
    return await chatCompletionCubit.getOpenAiChatModels();
  }

  void saveSelectedModel(String selectedModel) {
    chatCompletionCubit.saveSelectedModel(selectedModel);
  }

  String getSelectedModel() {
    return chatCompletionCubit.getSelectedModel();
  }

  List<Widget> getSettingsInputWidgets() {
    return [
      ModelDropDownWidget(
        label: 'Model',
        updateModelList: updateModelList,
        saveSelectedModel: saveSelectedModel,
        getSelectedModel: getSelectedModel,
      ),
      TextField(
        focusNode: systemPromptFocusNode,
        enabled: !loading,
        onChanged: (value) {
          chatCompletionCubit.saveSystemPrompt(systemPromptController.text);
        },
        controller: systemPromptController,
        maxLines: systemPromptMaxLines,
        minLines: 1,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(
          labelText: 'System prompt',
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      const SizedBox(
        height: 16,
      ),
      DoubleSliderWidget(
        label: "Temperature",
        min: OPENAI_CHAT_COMPLETION_MIN_TEMPERATURE,
        max: OPENAI_CHAT_COMPLETION_MAX_TEMPERATURE,
        divisions: 20,
        defaultValue: OPENAI_CHAT_COMPLETION_DEFAULT_TEMPERATURE,
        currentValue: chatCompletionSettings.temperature ??
            OPENAI_CHAT_COMPLETION_DEFAULT_TEMPERATURE,
        onChanged: (value) => chatCompletionCubit.saveTemperature(value),
      ),
      const SizedBox(
        height: 16,
      ),
      Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10)),
          child: ExpansionTile(
            title: const Text("Advanced settings"),
            shape: InputBorder.none,
            children: [
              DoubleSliderWidget(
                label: "Frequency penalty",
                min: -2,
                max: 2,
                divisions: 40,
                defaultValue: 0,
                currentValue: chatCompletionSettings.frequencyPenalty ?? 0,
                onChanged: (value) =>
                    chatCompletionCubit.saveFrequencyPenalty(value),
              ),
              DoubleSliderWidget(
                label: "Presence penalty",
                min: -2,
                max: 2,
                divisions: 40,
                defaultValue: 0,
                currentValue: chatCompletionSettings.presencePenalty ?? 0,
                onChanged: (value) =>
                    chatCompletionCubit.savePresencePenalty(value),
              ),
              // Text("Logit bias"),
              // Text("Max tokens"),
              // Text("N"),
              // Text("Stop sequences"),
              // Text("Top P"),
            ],
          )),
      const SizedBox(
        height: 16,
      ),
      Container(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10)),
        child: CheckboxListTile(
          contentPadding: const EdgeInsets.all(0),
          title: const Text('Show system prompts'),
          value: systemPromptsAreVisible,
          onChanged: (newValue) {
            setState(() {
              systemPromptsAreVisible = newValue!;
            });
            chatCompletionCubit.saveShowSystemPrompt(systemPromptsAreVisible);
          },
        ),
      ),
      const SizedBox(
        height: 16,
      ),
      Container(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10)),
        child: CheckboxListTile(
          contentPadding: const EdgeInsets.all(0),
          title: const Text("Send empty message"),
          value: sendEmptyMessage,
          onChanged: (newValue) {
            setState(() {
              sendEmptyMessage = newValue!;
            });
            chatCompletionCubit.saveSendEmptyMessage(sendEmptyMessage);
          },
        ),
      ),
      const SizedBox(
        height: 16,
      ),
      TextButton(
        style: TextButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.red),
        child: const Text('Clear chat messages'),
        onPressed: () {
          chatCompletionCubit.clearChat();
        },
      ),
    ];
  }

  Widget getAPISettingsV3() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.blueGrey[200]!)),
      child: SingleChildScrollView(
          child: Column(
        children: getSettingsInputWidgets(),
      )),
    );
  }
}
