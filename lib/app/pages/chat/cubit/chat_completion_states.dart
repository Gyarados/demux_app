import 'dart:async';

import 'package:demux_app/data/models/chat.dart';

sealed class ChatCompletionState {
  final List<Chat> chats;
  final Chat currentChat;
  ChatCompletionState(
    this.chats,
    this.currentChat,
  );
}

class ChatCompletionLoading extends ChatCompletionState {
  ChatCompletionLoading(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionSettingsSaved extends ChatCompletionState {
  ChatCompletionSettingsSaved(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionSettingsChanged extends ChatCompletionState {
  ChatCompletionSettingsChanged(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionMessagesSaved extends ChatCompletionState {
  ChatCompletionMessagesSaved(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionChatSelected extends ChatCompletionState {
  ChatCompletionChatSelected(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionChatCreated extends ChatCompletionState {
  ChatCompletionChatCreated(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionChatDeleted extends ChatCompletionState {
  ChatCompletionChatDeleted(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionInitial extends ChatCompletionState {
  ChatCompletionInitial(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionRetrievedFromMemory extends ChatCompletionState {
  ChatCompletionRetrievedFromMemory(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionReturned extends ChatCompletionState {
  final StreamController? streamController;
  ChatCompletionReturned(
    super.chats,
    super.currentChat, {
    this.streamController,
  });
}
