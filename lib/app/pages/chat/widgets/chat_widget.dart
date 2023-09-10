import 'dart:async';

import 'package:demux_app/app/pages/chat/cubit/chat_completion_cubit.dart';
import 'package:demux_app/app/pages/chat/cubit/chat_completion_states.dart';
import 'package:demux_app/app/utils/show_snackbar.dart';
import 'package:demux_app/data/models/chat_completion_settings.dart';
import 'package:demux_app/data/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final messageEditController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final userMessageController = TextEditingController();
  int? messageBeingEdited;
  FocusNode messageEditFocusNode = FocusNode();
  FocusNode messagePromptFocusNode = FocusNode();
  int messagePromptMaxLines = 1;
  bool needsScroll = false;
  bool isScrollAtTop = true;
  bool isScrollAtBottom = true;
  ChatCompletionSettings chatCompletionSettings =
      ChatCompletionSettings.initial();
  List<Message> messages = [];
  bool loading = false;
  bool systemPromptsAreVisible = true;
  late ChatCompletionCubit chatCompletionCubit;
  StreamController? streamController;

  @override
  void initState() {
    chatCompletionCubit = BlocProvider.of(context);
    scrollController.addListener(scrollListener);
    messagePromptFocusNode.addListener(messagePromptListener);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    userMessageController.dispose();
    super.dispose();
  }

  messagePromptListener() {
    if (messagePromptFocusNode.hasFocus) {
      setState(() {
        messagePromptMaxLines = 5;
      });
    } else {
      setState(() {
        messagePromptMaxLines = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (needsScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => jumpToEnd());
      needsScroll = false;
    }

    return BlocConsumer<ChatCompletionCubit, ChatCompletionState>(
        listener: (context, state) {
      if (state is ChatCompletionReturned) {
        loading = true;

        streamController = state.streamController;
        getStreamedResponse();
      }
    }, builder: (context, state) {
      chatCompletionSettings = state.chatCompletionSettings;
      systemPromptsAreVisible = chatCompletionSettings.systemPromptsAreVisible!;
      messages = state.messages;
      return Scaffold(
        floatingActionButton: getFloatingActionButton(),
        body: Column(children: [
          Expanded(child: getChatMessages()),
          getMessageControls(),
        ]),
      );
    });
  }

  Widget? getFloatingActionButton() {
    return isScrollAtBottom
        ? null
        : Container(
            margin: EdgeInsets.only(bottom: 50),
            child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    jumpToEnd();
                  });
                },
                mini: true,
                child: Icon(Icons.keyboard_double_arrow_down_rounded)),
          );
  }

  void stopGenerating() {
    setState(() {
      streamController!.close();
    });
  }

  void getStreamedResponse() async {
    try {
      setState(() {
        needsScroll = isListViewScrolledToMax();
        loading = true;
      });
      String assistantMessageContent = "";
      streamController!.stream.listen((event) {
        assistantMessageContent += event;
        setState(() {
          messages.last.content = assistantMessageContent;
          needsScroll = isListViewScrolledToMax();
        });
        chatCompletionCubit.saveCurrentMessages(messages);
      }, onError: (err) {
        print(err);
        setState(() {
          loading = false;
        });
      }, onDone: () {
        setState(() {
          loading = false;
        });
        chatCompletionCubit.saveCurrentMessages(messages);
      });
    } catch (e) {
      showSnackbar(e.toString(), context,
          criticality: MessageCriticality.error);
      setState(() {
        loading = false;
      });
    }
  }

  void sendMessage() async {
    setState(() {
      loading = true;
    });

    String userMessageContent = userMessageController.text;
    chatCompletionCubit.getChatCompletion(userMessageContent);

    setState(() {
      userMessageController.clear();
      needsScroll = true;
    });
  }

  Widget getMessageControls() {
    return Container(
      padding: EdgeInsets.all(0.0),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.blueGrey[200]!)),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              enabled: !loading,
              controller: userMessageController,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Message",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
              focusNode: messagePromptFocusNode,
              maxLines: messagePromptMaxLines,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            icon: loading ? Icon(Icons.stop) : Icon(Icons.send),
            onPressed: loading ? stopGenerating : sendMessage,
          ),
        ],
      ),
    );
  }

  void animateToEnd() async {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  void jumpToEnd() async {
    scrollController.jumpTo(
      scrollController.position.maxScrollExtent,
    );
  }

  scrollListener() {
    final maxScroll = scrollController.position.maxScrollExtent;
    final minScroll = scrollController.position.minScrollExtent;
    if (scrollController.position.pixels >= maxScroll) {
      setState(() {
        isScrollAtTop = false;
        isScrollAtBottom = true;
      });
    } else if (scrollController.position.pixels <= minScroll) {
      setState(() {
        isScrollAtTop = true;
        isScrollAtBottom = false;
      });
    } else {
      setState(() {
        isScrollAtTop = false;
        isScrollAtBottom = false;
      });
    }
  }

  Widget getEditingMessageWidget(int index) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(
            onPressed: () {
              stopEditingMessage(context);
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              messages[index].content = messageEditController.text;
              stopEditingMessage(context);
              chatCompletionCubit.saveCurrentMessages(messages);
            },
            child: Text("Save"),
          ),
        ]),
        TextField(
          maxLines: null,
          controller: messageEditController,
          focusNode: messageEditFocusNode,
        ),
      ],
    );
  }

  Future<void> copyMessage(BuildContext context, String message) async {
    try {
      await Clipboard.setData(ClipboardData(text: message));
      showSnackbar('Message copied to your clipboard!', context);
    } catch (e) {
      showSnackbar('Failed to copy message', context,
          criticality: MessageCriticality.error);
    }
  }

  void startEditingMessage(BuildContext context, int index) {
    setState(() {
      messageBeingEdited = index;
      messageEditController.text = messages[index].content;
    });
    FocusScope.of(context).unfocus();
  }

  void stopEditingMessage(BuildContext context) {
    setState(() {
      messageBeingEdited = null;
    });
    FocusScope.of(context).unfocus();
  }

  Widget getChatMessages() {
    return ListView.builder(
      shrinkWrap: true,
      controller: scrollController,
      itemCount: messages.length + 1,
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return loading || messages.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 150),
                  child: TextButton(
                      onPressed: sendContinueMessage, child: Text("Continue")));
        }

        if (!systemPromptsAreVisible && messages[index].role == "system") {
          return const SizedBox.shrink();
        }

        return chatMessageWidget(index);
      },
    );
  }

  void sendContinueMessage() {
    userMessageController.text = 'Continue';
    sendMessage();
  }

  bool isListViewScrolledToMax() {
    if (!scrollController.hasClients) return true;
    return scrollController.position.atEdge &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent;
  }

  Widget chatMessageWidget(int index) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.only(left: 8, top: 0, bottom: 8, right: 8),
      horizontalTitleGap: 0,
      tileColor: getMessageColor(messages[index].role),
      leading: GestureDetector(
          onTapDown: (details) => loading
              ? null
              : showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                  ),
                  items: [
                      PopupMenuItem(
                        child: TextButton(
                          child: Text('Copy'),
                          onPressed: () {
                            Navigator.pop(context);
                            copyMessage(context, messages[index].content);
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: TextButton(
                          child: Text('Edit'),
                          onPressed: () {
                            Navigator.pop(context);
                            startEditingMessage(context, index);
                          },
                        ),
                      ),
                      PopupMenuItem(
                        child: TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red),
                          child: Text('Delete'),
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              messages.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ]),
          child: Column(children: [
            Expanded(
                child: Icon(
              getMessageIcon(messages[index].role),
            )),
            Expanded(
                child: Icon(
              Icons.more_horiz,
              color: Colors.black,
            ))
          ])),
      titleAlignment: ListTileTitleAlignment.top,
      title: messageBeingEdited == index
          ? getEditingMessageWidget(index)
          : SelectionArea(
              child: MarkdownBody(
              data: messages[index].content,
              onTapLink: (text, url, title) {
                launchUrl(Uri.parse(url!));
              },
              styleSheet: MarkdownStyleSheet(
                  code: TextStyle(
                    color: Colors.blueGrey.shade100,
                    backgroundColor: Colors.grey.shade800,
                  ),
                  codeblockDecoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(5))),
            )),
    );
  }
}

Color getMessageColor(String role) {
  switch (role) {
    case 'user':
      return Colors.blueGrey.shade50;
    case 'assistant':
      return Colors.white;
    case 'system':
      return Colors.white;
    default:
      return Colors.white;
  }
}

IconData getMessageIcon(String role) {
  switch (role) {
    case 'user':
      return Icons.person;
    case 'assistant':
      return Icons.smart_toy_outlined;
    case 'system':
      return Icons.settings;
    default:
      return Icons.error;
  }
}
