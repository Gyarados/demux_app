import 'dart:async';

import 'package:demux_app/data/models/chat.dart';

sealed class ChatCompletionState {
  final List<Chat> chats;
  final int currentChatIndex;
  ChatCompletionState(
    this.chats,
    this.currentChatIndex,
  );
}

class ChatCompletionLoading extends ChatCompletionState {
  ChatCompletionLoading(
    super.chats,
    super.currentChatIndex,
  );
}

class ChatCompletionSettingsSaved extends ChatCompletionState {
  ChatCompletionSettingsSaved(
    super.chats,
    super.currentChatIndex,
  );
}

class ChatCompletionSettingsChanged extends ChatCompletionState {
  ChatCompletionSettingsChanged(
    super.chats,
    super.currentChatIndex,
  );
}

class ChatCompletionMessagesSaved extends ChatCompletionState {
  ChatCompletionMessagesSaved(
    super.chats,
    super.currentChatIndex,
  );
}

class ChatCompletionChatSelected extends ChatCompletionState {
  ChatCompletionChatSelected(
    super.chats,
    super.currentChatIndex,
  );
}

class ChatCompletionInitial extends ChatCompletionState {
  ChatCompletionInitial(
    super.chats,
    super.currentChatIndex,
  );
}

class ChatCompletionRetrievedFromMemory extends ChatCompletionState {
  ChatCompletionRetrievedFromMemory(
    super.chats,
    super.currentChatIndex,
  );
}

class ChatCompletionReturned extends ChatCompletionState {
  final StreamController? streamController;
  ChatCompletionReturned(
    super.chats,
    super.currentChatIndex, {
    this.streamController,
  });
}
