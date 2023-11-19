import 'package:demux_app/app/pages/chat/cubit/chat_completion_cubit.dart';
import 'package:demux_app/app/pages/chat/cubit/chat_completion_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ModelDropDownWidget extends StatefulWidget {
  const ModelDropDownWidget({super.key});

  @override
  State<ModelDropDownWidget> createState() => _ModelDropDownWidgetState();
}

class _ModelDropDownWidgetState extends State<ModelDropDownWidget> {
  List<String> modelList = [];

  bool loading = true;

  late String selectedModel;
  bool selectedModelNotAvailable = false;

  late ChatCompletionCubit chatCompletionCubit;

  @override
  void initState() {
    chatCompletionCubit = BlocProvider.of<ChatCompletionCubit>(context);
    selectedModel = chatCompletionCubit.getSelectedModel();
    updateModelList();
    super.initState();
  }

  Future<void> updateModelList() async {
    setState(() {
      loading = true;
      modelList.clear();
    });

    modelList = await chatCompletionCubit.getOpenAiChatModels();
    setState(() {
      modelList = modelList;

      if (!modelList.contains(selectedModel)) {
        selectedModelNotAvailable = true;
        modelList.insert(0, selectedModel);
      } else {
        selectedModelNotAvailable = false;
      }
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCompletionCubit, ChatCompletionState>(
      listener: (context, state) async {
        if (selectedModel != state.currentChat.chatCompletionSettings.model) {
          selectedModel = state.currentChat.chatCompletionSettings.model;
          await updateModelList();
        }
      },
      builder: (context, state) {
        return Row(children: [
          Expanded(
              child: DropdownButtonFormField(
            decoration: const InputDecoration(
              labelText: 'Model',
            ),
            value: selectedModel,
            onChanged: (String? value) {
              setState(() {
                selectedModel = value!;
              });
              chatCompletionCubit.saveSelectedModel(selectedModel);
            },
            items: loading
                ? null
                : modelList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child:
                          (selectedModelNotAvailable && value == selectedModel)
                              ? Text(
                                  "$value (Unavailable)",
                                  style: TextStyle(color: Colors.red),
                                )
                              : Text(
                                  value,
                                ),
                    );
                  }).toList(),
          )),
          if (loading)
            SpinKitRing(
              color: Colors.blueGrey,
              size: 32,
              lineWidth: 4,
            )
        ]);
      },
    );
  }
}
