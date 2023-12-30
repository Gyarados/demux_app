import 'dart:typed_data';

import 'package:demux_app/app/pages/chat/cubit/demux_chat_completion_states.dart';
import 'package:demux_app/data/models/demux_chat.dart';
import 'package:demux_app/data/models/message.dart';
import 'package:demux_app/domain/demux_service.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class DemuxChatCompletionCubit extends HydratedCubit<DemuxChatCompletionState> {
  final DemuxService demuxService;

  DemuxChatCompletionCubit._(
    List<DemuxChat> chats,
    DemuxChat chat,
    this.demuxService,
  ) : super(ChatCompletionInitial(chats, chat));

  factory DemuxChatCompletionCubit() {
    final chat = DemuxChat(messages: []);
    DemuxService demuxService = DemuxService();
    return DemuxChatCompletionCubit._(
      [chat],
      chat,
      demuxService,
    );
  }

  bool modelHasVision() {
    return false;
  }

  void getChatCompletion(String userMessageContent, {Uint8List? image}) {
    DemuxChat chat = state.currentChat;

    emit(ChatCompletionLoading(state.chats, chat));

    if (userMessageContent.isNotEmpty) {
      Message userMessage = Message("user", userMessageContent);
      chat.messages.add(userMessage);
      emit(ChatCompletionMessagesSaved(state.chats, chat));
    }

    var streamController = demuxService.getChatResponseStream(
      chat.messages,
    );

    Message assistantMessage =
        Message("assistant", "",);
    chat.messages.add(assistantMessage);

    emit(ChatCompletionReturned(
      state.chats,
      chat,
      streamController: streamController,
    ));
  }

  void saveCurrentMessages(
    List<Message> messages,
  ) {
    DemuxChat chat = state.currentChat;
    chat.messages = messages;
    emit(ChatCompletionMessagesSaved(state.chats, chat));
  }

  @override
  DemuxChatCompletionState fromJson(Map<String, dynamic> json) {
    List<dynamic> jsonChats = json['chats'];

    List<DemuxChat> chats =
        jsonChats.map((chatJson) => DemuxChat.fromJson(chatJson)).toList();

    DemuxChat currentChat = DemuxChat.fromJson(json['currentChat']);
    return ChatCompletionRetrievedFromMemory(chats, currentChat);
  }

  @override
  Map<String, dynamic>? toJson(DemuxChatCompletionState state) {
    return {
      'chats': state.chats.map((chat) => chat.toJson()).toList(),
      'currentChat': state.currentChat.toJson()
    };
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print("error in chat_completion_cubit conversion:");
    print(error);
    super.onError(error, stackTrace);
  }
}
