import 'package:demux_app/app/pages/chat/cubit/chat_completion_cubit.dart';
import 'package:demux_app/app/pages/chat/widgets/chat_widget.dart';
import 'package:demux_app/app/pages/chat/widgets/settings_widget.dart';
import 'package:demux_app/domain/constants.dart';
import 'package:demux_app/app/pages/base_openai_api_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  ChatCompletionCubit chatCompletionCubit = ChatCompletionCubit();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => chatCompletionCubit,
      child: Scaffold(
        body: Column(children: [
          ChatSettingsWidget(),
          Expanded(
              child: Listener(
                onPointerDown: (_) => chatCompletionCubit.toggleSettingsExpand(false),
            child: ChatWidget(),
          )),
        ]),
      ),
    );
  }
}
