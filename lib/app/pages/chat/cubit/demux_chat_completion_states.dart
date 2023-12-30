import 'dart:async';

import 'package:demux_app/data/models/demux_chat.dart';

sealed class DemuxChatCompletionState {
  final List<DemuxChat> chats;
  final DemuxChat currentChat;
  DemuxChatCompletionState(
    this.chats,
    this.currentChat,
  );
}

class ChatCompletionLoading extends DemuxChatCompletionState {
  ChatCompletionLoading(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionSettingsSaved extends DemuxChatCompletionState {
  ChatCompletionSettingsSaved(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionSettingsChanged extends DemuxChatCompletionState {
  ChatCompletionSettingsChanged(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionMessagesSaved extends DemuxChatCompletionState {
  ChatCompletionMessagesSaved(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionChatSelected extends DemuxChatCompletionState {
  ChatCompletionChatSelected(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionChatCreated extends DemuxChatCompletionState {
  ChatCompletionChatCreated(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionChatDeleted extends DemuxChatCompletionState {
  ChatCompletionChatDeleted(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionInitial extends DemuxChatCompletionState {
  ChatCompletionInitial(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionRetrievedFromMemory extends DemuxChatCompletionState {
  ChatCompletionRetrievedFromMemory(
    super.chats,
    super.currentChat,
  );
}

class ChatCompletionReturned extends DemuxChatCompletionState {
  final StreamController? streamController;
  ChatCompletionReturned(
    super.chats,
    super.currentChat, {
    this.streamController,
  });
}
