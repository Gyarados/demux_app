import 'package:demux_app/app/pages/chat/cubit/chat_completion_cubit.dart';
import 'package:demux_app/app/pages/chat/cubit/chat_completion_states.dart';
import 'package:demux_app/app/pages/chat/widgets/temperature_input_widget.dart';
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
    temperatureController.dispose();
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
    systemPromptsAreVisible =
        chatCompletionSettings.systemPromptsAreVisible ?? true;
    sendEmptyMessage = chatCompletionSettings.sendEmptyMessage ?? false;
  }

  void onTemperatureChanged(String value) {
    chatCompletionCubit.saveTemperature(temperatureController.text);
  }

  List<Widget> getSettingsInputWidgets() {
    return [
      Row(
        children: [
          Expanded(
            flex: 8,
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
          ),
          Expanded(
            flex: 3,
            child: getTemperatureInputWidget(
                temperatureController, loading, onTemperatureChanged),
          ),
        ],
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
      SizedBox(height: 16,),
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
      SizedBox(height: 16,),
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
      SizedBox(height: 16,),
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

  Widget getAPISettingsV1() {
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
        children: getSettingsInputWidgets(),
      ),
    );
  }

  Widget getAPISettingsV2() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.blueGrey[200]!)),
      child: Column(children: [
        GestureDetector(
          onTap: () {
            setState(() {
              settingsExpanded = !settingsExpanded;
            });
          },
          child: Container(
              padding: EdgeInsets.all(16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.settings),
                        Expanded(
                            child: Text(
                          selectedModel,
                          textAlign: TextAlign.center,
                        )),
                        Icon(Icons.thermostat),
                        Expanded(
                            child: Text(
                          temperatureController.text,
                          textAlign: TextAlign.center,
                        )),
                      ],
                    )),
                    Icon(settingsExpanded
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down)
                  ])),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 250),
          padding: EdgeInsets.only(left: 16, right: 16),
          height: settingsExpanded ? 200 : 0,
          child: SingleChildScrollView(
              child: Column(children: getSettingsInputWidgets())),
        ),
      ]),
    );
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
