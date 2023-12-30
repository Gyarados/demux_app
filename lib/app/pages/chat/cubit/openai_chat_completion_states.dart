import 'dart:async';

import 'package:demux_app/data/models/chat.dart';

sealed class OpenAiChatCompletionState {
  final List<Chat> chats;
  final Chat currentChat;
  OpenAiChatCompletionState(
    this.chats,
    this.currentChat,
  );
}

class ChatCompletionLoading extends OpenAiChatCompletionState {
  ChatCompletionLoading(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionSettingsSaved extends OpenAiChatCompletionState {
  ChatCompletionSettingsSaved(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionSettingsChanged extends OpenAiChatCompletionState {
  ChatCompletionSettingsChanged(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionMessagesSaved extends OpenAiChatCompletionState {
  ChatCompletionMessagesSaved(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionChatSelected extends OpenAiChatCompletionState {
  ChatCompletionChatSelected(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionChatCreated extends OpenAiChatCompletionState {
  ChatCompletionChatCreated(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionChatDeleted extends OpenAiChatCompletionState {
  ChatCompletionChatDeleted(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionInitial extends OpenAiChatCompletionState {
  ChatCompletionInitial(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionRetrievedFromMemory extends OpenAiChatCompletionState {
  ChatCompletionRetrievedFromMemory(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionReturned extends OpenAiChatCompletionState {
  final StreamController? streamController;
  ChatCompletionReturned(
    super.chats,
    super.currentChat, {
    this.streamController,
  });
}
