import 'dart:async';

import 'package:demux_app/app/pages/chat/bloc/chat_completion_states.dart';
import 'package:demux_app/data/models/message.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ChatCompletionCubit extends HydratedCubit<ChatCompletionState> {
  ChatCompletionCubit() : super(ChatCompletionReturned([]));

  void getChatCompletion(List<Message> messages, {StreamController? streamController}) {
    emit(ChatCompletionReturned(messages, streamController: streamController));
  }

  void saveMessages(List<Message> messages) {
    emit(ChatCompletionReturned(messages));
  }

  @override
  ChatCompletionState fromJson(Map<String, dynamic> json) {
    return ChatCompletionReturned(jsonToMessageList(json['messages']));
  }

  @override
  Map<String, dynamic>? toJson(ChatCompletionState state) {
    if (state is ChatCompletionReturned) {
      return {'messages': messageListToJson(state.messages)};
    }
    return null;
  }
}
