import 'dart:typed_data';

import 'package:demux_app/app/pages/chat/cubit/chat_completion_states.dart';
import 'package:demux_app/data/models/chat.dart';
import 'package:demux_app/data/models/message.dart';
import 'package:demux_app/data/utils/custom_datetime.dart';
import 'package:demux_app/domain/constants.dart';
import 'package:demux_app/domain/openai_service.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ChatCompletionCubit extends HydratedCubit<ChatCompletionState> {
  final OpenAiService openAiService;

  ChatCompletionCubit._(
    List<Chat> chats,
    Chat chat,
    this.openAiService,
  ) : super(ChatCompletionInitial(chats, chat));

  factory ChatCompletionCubit() {
    final chat = Chat.initial();
    OpenAiService openAiService = OpenAiService();
    return ChatCompletionCubit._(
      [chat],
      chat,
      openAiService,
    );
  }

  void setApiKey(String apiKey) {
    openAiService.apiKey = apiKey;
  }

  Future<List<String>> getOpenAiChatModels() async {
    return await openAiService.getChatModels();
  }

  String getSelectedModel() {
    return state.currentChat.chatCompletionSettings.model;
  }

  bool modelHasVision() {
    List<String> modelsWithVision = ["gpt-4-vision-preview"];
    return modelsWithVision
        .contains(state.currentChat.chatCompletionSettings.model);
  }

  void getChatCompletion(String userMessageContent, {Uint8List? image}) {
    Chat chat = state.currentChat;

    emit(ChatCompletionLoading(state.chats, chat));

    if (chat.messages.isEmpty &&
        chat.name == OPENAI_CHAT_COMPLETION_DEFAULT_CHAT_NAME) {
      chat.name = userMessageContent;
    }

    chat.lastUpdated = RelativeDateTime.now();

    String systemPrompt = chat.chatCompletionSettings.systemPrompt ?? "";
    if (systemPrompt.isNotEmpty) {
      Message systemMessage = Message("system", systemPrompt);
      chat.messages.add(systemMessage);
      chat.chatCompletionSettings.systemPrompt = "";
      emit(ChatCompletionSettingsChanged(state.chats, chat));
    }

    bool sendEmptyMessage =
        chat.chatCompletionSettings.sendEmptyMessage ?? true;
    if (userMessageContent.isNotEmpty || image != null || sendEmptyMessage) {
      Message userMessage = Message("user", userMessageContent);
      if (image != null){
        userMessage.image = image;
      }
      chat.messages.add(userMessage);
      emit(ChatCompletionMessagesSaved(state.chats, chat));
    }

    var streamController = openAiService.getChatResponseStream(
      chat.chatCompletionSettings,
      chat.messages,
    );

    Message assistantMessage =
        Message("assistant", "", modelUsed: chat.chatCompletionSettings.model);
    chat.messages.add(assistantMessage);

    emit(ChatCompletionReturned(
      state.chats,
      chat,
      streamController: streamController,
    ));
  }

  void saveSelectedModel(
    String selectedModel,
  ) {
    Chat chat = state.currentChat;
    chat.chatCompletionSettings.model = selectedModel;
    emit(ChatCompletionSettingsSaved(state.chats, chat));
  }

  void saveTemperature(double temperature) {
    Chat chat = state.currentChat;
    chat.chatCompletionSettings.temperature = temperature;
    emit(ChatCompletionSettingsSaved(state.chats, chat));
  }

  void saveFrequencyPenalty(
    double value,
  ) {
    Chat chat = state.currentChat;
    chat.chatCompletionSettings.frequencyPenalty = value;
    emit(ChatCompletionSettingsSaved(state.chats, chat));
  }

  void savePresencePenalty(
    double value,
  ) {
    Chat chat = state.currentChat;
    chat.chatCompletionSettings.presencePenalty = value;
    emit(ChatCompletionSettingsSaved(state.chats, chat));
  }

  void saveSystemPrompt(
    String systemPrompt,
  ) {
    Chat chat = state.currentChat;
    chat.chatCompletionSettings.systemPrompt = systemPrompt;
    emit(ChatCompletionSettingsSaved(state.chats, chat));
  }

  void saveShowSystemPrompt(
    bool systemPromptsAreVisible,
  ) {
    Chat chat = state.currentChat;
    chat.chatCompletionSettings.systemPromptsAreVisible =
        systemPromptsAreVisible;
    emit(ChatCompletionSettingsSaved(state.chats, chat));
  }

  void saveSendEmptyMessage(
    bool sendEmptyMessage,
  ) {
    Chat chat = state.currentChat;
    chat.chatCompletionSettings.sendEmptyMessage = sendEmptyMessage;
    emit(ChatCompletionSettingsSaved(state.chats, chat));
  }

  void saveCurrentMessages(
    List<Message> messages,
  ) {
    Chat chat = state.currentChat;
    chat.messages = messages;
    emit(ChatCompletionMessagesSaved(state.chats, chat));
  }

  void clearChat() {
    Chat chat = state.currentChat;
    chat.messages = [];
    emit(ChatCompletionChatSelected(state.chats, chat));
  }

  void deleteChat(Chat chatToDelete) {
    Chat currentChat = state.currentChat;

    if (chatToDelete == currentChat) {
      if (state.chats.length == 1) {
        Chat newChat = Chat.initial();
        state.chats.insert(0, newChat);
        currentChat = newChat;
        state.chats.remove(chatToDelete);
        emit(ChatCompletionChatSelected(state.chats, currentChat));
        return;
      } else {
        state.chats.remove(chatToDelete);
        currentChat = state.chats.first;
        emit(ChatCompletionChatSelected(state.chats, currentChat));
        return;
      }
    } else {
      state.chats.remove(chatToDelete);
      emit(ChatCompletionChatDeleted(state.chats, currentChat));
      return;
    }
  }

  void deleteMultipleChats(List<Chat> chatsToDelete) {
    Chat currentChat = state.currentChat;
    if (chatsToDelete.contains(currentChat)) {
      if (state.chats.length == chatsToDelete.length) {
        Chat newChat = Chat.initial();
        state.chats.insert(0, newChat);
        currentChat = newChat;
        state.chats.removeWhere((element) => chatsToDelete.contains(element));
        emit(ChatCompletionChatSelected(state.chats, currentChat));
        return;
      } else {
        state.chats.removeWhere((element) => chatsToDelete.contains(element));
        currentChat = state.chats.first;
        emit(ChatCompletionChatSelected(state.chats, currentChat));
        return;
      }
    } else {
      state.chats.removeWhere((element) => chatsToDelete.contains(element));
      emit(ChatCompletionChatDeleted(state.chats, currentChat));
      return;
    }
  }

  void selectChat(
    Chat chat,
  ) {
    emit(ChatCompletionChatSelected(state.chats, chat));
  }

  void renameChat(
    Chat chat,
    String newName,
  ) {
    chat.name = newName;
    emit(ChatCompletionChatSelected(state.chats, state.currentChat));
  }

  void createNewChat() {
    Chat newChat = Chat.initial();
    state.chats.insert(0, newChat);
    // state.chats.add(newChat);
    emit(ChatCompletionChatCreated(state.chats, state.currentChat));
  }

  @override
  ChatCompletionState fromJson(Map<String, dynamic> json) {
    List<dynamic> jsonChats = json['chats'];

    List<Chat> chats =
        jsonChats.map((chatJson) => Chat.fromJson(chatJson)).toList();

    Chat currentChat = Chat.fromJson(json['currentChat']);
    return ChatCompletionRetrievedFromMemory(chats, currentChat);
  }

  @override
  Map<String, dynamic>? toJson(ChatCompletionState state) {
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
