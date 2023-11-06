import 'package:demux_app/app/pages/chat/cubit/chat_completion_cubit.dart';
import 'package:demux_app/app/pages/chat/cubit/chat_completion_states.dart';
import 'package:demux_app/app/pages/chat/widgets/double_input_widget.dart';
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

  final ExpandableController settingsExpandControllerV3 =
      ExpandableController();

  bool settingsExpanded = false;

  int systemPromptMaxLines = 1;
  FocusNode systemPromptFocusNode = FocusNode();
  bool loading = false;
  List<String> modelList = OPENAI_CHAT_COMPLETION_MODEL_LIST;

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

  temperatureListener() {
    chatCompletionCubit.saveTemperature(temperatureController.text);
  }

  frequencyPenaltyListener() {
    chatCompletionCubit.saveFrequencyPenalty(frequencyPenaltyController.text);
  }

  presencePenaltyListener() {
    chatCompletionCubit.savePresencePenalty(presencePenaltyController.text);
  }
  //   logitBiasListener() {
  //   chatCompletionCubit.saveLogitBias(logitBiasController.text);
  // }
  //   maxTokensListener() {
  //   chatCompletionCubit.saveMaxTokens(maxTokensController.text);
  // }

  @override
  void initState() {
    chatCompletionCubit = BlocProvider.of<ChatCompletionCubit>(context);
    updateSettingsFromState(chatCompletionCubit.state);
    systemPromptFocusNode.addListener(systemPromptListener);

    temperatureController.addListener(temperatureListener);
    frequencyPenaltyController.addListener(frequencyPenaltyListener);
    presencePenaltyController.addListener(presencePenaltyListener);
    // logitBiasController.addListener(logitBiasListener);
    // maxTokensController.addListener(maxTokensListener);

    super.initState();
  }

  @override
  void dispose() {
    systemPromptController.dispose();
    temperatureController.dispose();
    frequencyPenaltyController.dispose();
    presencePenaltyController.dispose();
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
    temperatureController.text = chatCompletionSettings.temperature.toString();

    frequencyPenaltyController.text = chatCompletionSettings.frequencyPenalty != null? chatCompletionSettings.frequencyPenalty.toString() : "";
    presencePenaltyController.text = chatCompletionSettings.presencePenalty != null? chatCompletionSettings.presencePenalty.toString() : "";

    systemPromptsAreVisible =
        chatCompletionSettings.systemPromptsAreVisible ?? true;
    sendEmptyMessage = chatCompletionSettings.sendEmptyMessage ?? false;
  }

  List<Widget> getSettingsInputWidgets() {
    return [
      DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: 'Model',
        ),
        value: selectedModel,
        onChanged: !loading
            ? (String? value) {
                setState(() {
                  selectedModel = value!;
                });
                chatCompletionCubit.saveSelectedModel(selectedModel);
              }
            : null,
        items: modelList.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
      SizedBox(
        height: 16,
      ),
      DoubleInputWidget(
        temperatureController,
        label: "Temperature",
        min: 0,
        max: 2,
        allowNull: false,
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
        decoration: InputDecoration(
          labelText: 'System prompt',
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      SizedBox(
        height: 16,
      ),
      Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10)),
          child: ExpansionTile(
            title: Text("Advanced settings"),
            shape: InputBorder.none,
            children: [
              Padding(
                  padding: EdgeInsets.all(8),
                  child: DoubleInputWidget(
                    frequencyPenaltyController,
                    label: "Frequency penalty",
                    min: -2,
                    max: 2,
                  )),
              Padding(
                  padding: EdgeInsets.all(8),
                  child: DoubleInputWidget(
                    presencePenaltyController,
                    label: "Presence penalty",
                    min: -2,
                    max: 2,
                  )),
              // Text("Logit bias"),
              // Text("Max tokens"),
              // Text("N"),
              // Text("Stop sequences"),
              // Text("Top P"),
            ],
          )),
      SizedBox(
        height: 16,
      ),
      Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10)),
        child: CheckboxListTile(
          contentPadding: EdgeInsets.all(0),
          title: Text('Show system prompts'),
          value: systemPromptsAreVisible,
          onChanged: (newValue) {
            setState(() {
              systemPromptsAreVisible = newValue!;
            });
            chatCompletionCubit.saveShowSystemPrompt(systemPromptsAreVisible);
          },
        ),
      ),
      SizedBox(
        height: 16,
      ),
      Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10)),
        child: CheckboxListTile(
          contentPadding: EdgeInsets.all(0),
          title: Text("Send empty message"),
          value: sendEmptyMessage,
          onChanged: (newValue) {
            setState(() {
              sendEmptyMessage = newValue!;
            });
            chatCompletionCubit.saveSendEmptyMessage(sendEmptyMessage);
          },
        ),
      ),
      SizedBox(
        height: 16,
      ),
      TextButton(
        style: TextButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.red),
        child: Text('Clear chat messages'),
        onPressed: () {
          chatCompletionCubit.clearChat();
        },
      ),
    ];
  }

  Widget getAPISettingsV3() {
    return Container(
      padding: EdgeInsets.all(16),
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
