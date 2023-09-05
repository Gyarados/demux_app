import 'dart:async';

import 'package:demux_app/data/models/chat_completion_settings.dart';
import 'package:demux_app/data/models/message.dart';

sealed class ChatCompletionState {
  final ChatCompletionSettings chatCompletionSettings;
  final List<Message> messages;
  ChatCompletionState(
    this.chatCompletionSettings,
    this.messages,
  );
}

class ChatCompletionLoading extends ChatCompletionState {
  ChatCompletionLoading(
    super.chatCompletionSettings,
    super.messages,
  );
}

class ChatCompletionSettingsSaved extends ChatCompletionState {
  ChatCompletionSettingsSaved(
    super.chatCompletionSettings,
    super.messages,
  );
}

class ChatCompletionSettingsChanged extends ChatCompletionState {
  ChatCompletionSettingsChanged(
    super.chatCompletionSettings,
    super.messages,
  );
}

class ChatCompletionMessagesSaved extends ChatCompletionState {
  ChatCompletionMessagesSaved(
    super.chatCompletionSettings,
    super.messages,
  );
}

class ChatCompletionInitial extends ChatCompletionState {
  
  ChatCompletionInitial(
    super.chatCompletionSettings,
    super.messages,
  );
}

class ChatCompletionRetrievedFromMemory extends ChatCompletionState {
  ChatCompletionRetrievedFromMemory(
    super.chatCompletionSettings,
    super.messages,
  );
}

class ChatCompletionReturned extends ChatCompletionState {
  final StreamController? streamController;
  ChatCompletionReturned(
    super.chatCompletionSettings,
    super.messages, {
    this.streamController,
  });
}
