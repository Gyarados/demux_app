import 'package:demux_app/app/pages/chat/cubit/chat_completion_states.dart';
import 'package:demux_app/data/models/chat.dart';
import 'package:demux_app/data/models/message.dart';
import 'package:demux_app/domain/openai_repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ChatCompletionCubit extends HydratedCubit<ChatCompletionState> {
  final repository = OpenAiRepository();

  ChatCompletionCubit() : super(ChatCompletionInitial([Chat.initial()], 0));

  Chat getCurrentChat(int index) {
    return state.chats[index];
  }

  void getChatCompletion(String userMessageContent) {
    int chatIndex = state.currentChatIndex;
    emit(ChatCompletionLoading(state.chats, chatIndex));
    Chat chat = getCurrentChat(chatIndex);
    String systemPrompt = chat.chatCompletionSettings.systemPrompt ?? "";
    if (systemPrompt.isNotEmpty) {
      Message systemMessage = Message("system", systemPrompt);
      chat.messages.add(systemMessage);
      chat.chatCompletionSettings.systemPrompt = "";
      emit(ChatCompletionSettingsChanged(state.chats, chatIndex));
    }

    bool sendEmptyMessage =
        chat.chatCompletionSettings.sendEmptyMessage ?? true;
    if (userMessageContent.isNotEmpty || sendEmptyMessage) {
      Message userMessage = Message("user", userMessageContent);
      chat.messages.add(userMessage);
      emit(ChatCompletionMessagesSaved(state.chats, chatIndex));
    }

    var streamController = repository.getChatResponseStream(
      chat.chatCompletionSettings,
      chat.messages,
    );

    Message assistantMessage = Message("assistant", "");
    chat.messages.add(assistantMessage);

    emit(ChatCompletionReturned(
      state.chats,
      chatIndex,
      streamController: streamController,
    ));
  }

  void saveSelectedModel(
    String selectedModel,
  ) {
    Chat chat = getCurrentChat(state.currentChatIndex);
    chat.chatCompletionSettings.model = selectedModel;
    emit(ChatCompletionSettingsSaved(state.chats, state.currentChatIndex));
  }

  void saveTemperature(
    String temperatureString,
  ) {
    double temperature = double.parse(temperatureString);
    Chat chat = getCurrentChat(state.currentChatIndex);
    chat.chatCompletionSettings.temperature = temperature;
    emit(ChatCompletionSettingsSaved(state.chats, state.currentChatIndex));
  }

  void saveSystemPrompt(
    String systemPrompt,
  ) {
    Chat chat = getCurrentChat(state.currentChatIndex);
    chat.chatCompletionSettings.systemPrompt = systemPrompt;
    emit(ChatCompletionSettingsSaved(state.chats, state.currentChatIndex));
  }

  void saveShowSystemPrompt(
    bool systemPromptsAreVisible,
  ) {
    Chat chat = getCurrentChat(state.currentChatIndex);
    chat.chatCompletionSettings.systemPromptsAreVisible =
        systemPromptsAreVisible;
    emit(ChatCompletionSettingsSaved(state.chats, state.currentChatIndex));
  }

  void saveSendEmptyMessage(
    bool sendEmptyMessage,
  ) {
    Chat chat = getCurrentChat(state.currentChatIndex);
    chat.chatCompletionSettings.sendEmptyMessage = sendEmptyMessage;
    emit(ChatCompletionSettingsSaved(state.chats, state.currentChatIndex));
  }

  void saveCurrentMessages(
    List<Message> messages,
  ) {
    Chat chat = getCurrentChat(state.currentChatIndex);
    chat.messages = messages;
    emit(ChatCompletionMessagesSaved(state.chats, state.currentChatIndex));
  }

  void clearChat() {
    Chat chat = getCurrentChat(state.currentChatIndex);
    chat.messages = [];
    emit(ChatCompletionMessagesSaved(state.chats, state.currentChatIndex));
  }

  void deleteChat([int? chatIndex]) {
    state.chats.removeAt(chatIndex ?? state.currentChatIndex);
    emit(ChatCompletionMessagesSaved(state.chats, state.currentChatIndex));
  }

  void selectChat(
    int chatIndex,
  ) {
    emit(ChatCompletionChatSelected(state.chats, chatIndex));
  }

  void createNewChat() {
    Chat newChat = Chat.initial();
    state.chats.add(newChat);
    int currentIndex = state.chats.length - 1;
    emit(ChatCompletionChatSelected(state.chats, currentIndex));
  }

  @override
  ChatCompletionState fromJson(Map<String, dynamic> json) {
    List<dynamic> jsonChats = json['chats'];

    List<Chat> chats =
        jsonChats.map((chatJson) => Chat.fromJson(chatJson)).toList();

    int currentChatIndex = json['currentChatIndex'] as int;
    return ChatCompletionRetrievedFromMemory(chats, currentChatIndex);
  }

  @override
  Map<String, dynamic>? toJson(ChatCompletionState state) {
    return {
      'chats': state.chats.map((chat) => chat.toJson()).toList(),
      'currentChatIndex': state.currentChatIndex
    };
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print("error in chat_completion_cubit conversion:");
    print(error);
    super.onError(error, stackTrace);
  }
}
