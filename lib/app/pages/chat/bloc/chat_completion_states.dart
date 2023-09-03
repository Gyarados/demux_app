import 'dart:async';

import 'package:demux_app/data/models/message.dart';

sealed class ChatCompletionState {
  final List<Message> messages;
  ChatCompletionState(this.messages);
}

class ChatCompletionReturned extends ChatCompletionState {
  final StreamController? streamController;
  ChatCompletionReturned(super.messages, {this.streamController});
}
