import 'package:demux_app/app/pages/chat/cubit/chat_completion_states.dart';
import 'package:demux_app/data/models/chat_completion_settings.dart';
import 'package:demux_app/data/models/message.dart';
import 'package:demux_app/domain/openai_repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ChatCompletionCubit extends HydratedCubit<ChatCompletionState> {
  final repository = OpenAiRepository();

  ChatCompletionCubit()
      : super(ChatCompletionInitial(ChatCompletionSettings.initial(), []));

  void getChatCompletion(String userMessageContent) {
    emit(ChatCompletionLoading(state.chatCompletionSettings, state.messages));

    String systemPrompt = state.chatCompletionSettings.systemPrompt ?? "";
    if (systemPrompt.isNotEmpty) {
      Message systemMessage = Message("system", systemPrompt);
      state.messages.add(systemMessage);
      state.chatCompletionSettings.systemPrompt = "";
      emit(ChatCompletionSettingsChanged(
          state.chatCompletionSettings, state.messages));
    }

    bool sendEmptyMessage =
        state.chatCompletionSettings.sendEmptyMessage ?? true;
    if (userMessageContent.isNotEmpty || sendEmptyMessage) {
      Message userMessage = Message("user", userMessageContent);
      state.messages.add(userMessage);
      emit(ChatCompletionMessagesSaved(
          state.chatCompletionSettings, state.messages));
    }

    var streamController = repository.getChatResponseStream(
      state.chatCompletionSettings,
      state.messages,
    );

    Message assistantMessage = Message("assistant", "");
    state.messages.add(assistantMessage);

    emit(ChatCompletionReturned(
      state.chatCompletionSettings,
      state.messages,
      streamController: streamController,
    ));
  }

  void saveSelectedModel(
    String selectedModel,
  ) {
    state.chatCompletionSettings.model = selectedModel;
    emit(ChatCompletionSettingsSaved(
        state.chatCompletionSettings, state.messages));
  }

  void saveTemperature(
    String temperatureString,
  ) {
    double temperature = double.parse(temperatureString);
    state.chatCompletionSettings.temperature = temperature;
    emit(ChatCompletionSettingsSaved(
        state.chatCompletionSettings, state.messages));
  }

  void saveSystemPrompt(
    String systemPrompt,
  ) {
    state.chatCompletionSettings.systemPrompt = systemPrompt;
    emit(ChatCompletionSettingsSaved(
        state.chatCompletionSettings, state.messages));
  }

  void saveCurrentMessages(
    List<Message> messages,
  ) {
    emit(ChatCompletionMessagesSaved(state.chatCompletionSettings, messages));
  }

  @override
  ChatCompletionState fromJson(Map<String, dynamic> json) {
    return ChatCompletionRetrievedFromMemory(
      ChatCompletionSettings.fromJson(json['settings']),
      jsonToMessageList(json['messages']),
    );
  }

  @override
  Map<String, dynamic>? toJson(ChatCompletionState state) {
    return {
      'settings': state.chatCompletionSettings.toJson(),
      'messages': messageListToJson(state.messages),
    };
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print(error);

    // Always call super.onError with the current error and stackTrace
    super.onError(error, stackTrace);
  }
}
