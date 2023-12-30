import 'dart:async';
import 'dart:typed_data';

import 'package:demux_app/app/pages/chat/cubit/demux_chat_completion_cubit.dart';
import 'package:demux_app/app/pages/chat/cubit/demux_chat_completion_states.dart';
import 'package:demux_app/app/pages/chat/utils/copy_text.dart';
import 'package:demux_app/app/pages/chat/utils/syntax_highlighter.dart';
import 'package:demux_app/app/pages/images/utils/image_processing.dart';
import 'package:demux_app/app/pages/settings/cubit/app_settings_cubit.dart';
import 'package:demux_app/app/utils/show_snackbar.dart';
import 'package:demux_app/data/models/demux_chat.dart';
import 'package:demux_app/data/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class DemuxChatWidget extends StatefulWidget {
  const DemuxChatWidget({super.key});

  @override
  State<DemuxChatWidget> createState() => _DemuxChatWidgetState();
}

class _DemuxChatWidgetState extends State<DemuxChatWidget> {
  final messageEditController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final userMessageController = TextEditingController();
  int? messageBeingEdited;
  FocusNode messageEditFocusNode = FocusNode();
  FocusNode messagePromptFocusNode = FocusNode();
  int messagePromptMaxLines = 1;
  double messagePromptPadding = 0;
  bool needsScroll = false;
  bool isScrollAtTop = true;
  bool isScrollAtBottom = true;
  DemuxChat currentChat = DemuxChat(messages: []);
  late List<Message> messages = currentChat.messages;
  bool loading = false;
  bool systemPromptsAreVisible = true;
  late DemuxChatCompletionCubit chatCompletionCubit;
  late AppSettingsCubit appSettingsCubit;
  StreamController? streamController;

  Uint8List? selectedImage;

  bool loadingSelectedImage = false;

  @override
  void initState() {
    streamController?.close();
    chatCompletionCubit = BlocProvider.of<DemuxChatCompletionCubit>(context);
    appSettingsCubit = BlocProvider.of<AppSettingsCubit>(context);
    scrollController.addListener(scrollListener);
    messagePromptFocusNode.addListener(messagePromptListener);
    needsScroll = true;
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    userMessageController.dispose();
    streamController?.close();
    super.dispose();
  }

  messagePromptListener() {
    if (messagePromptFocusNode.hasFocus) {
      setState(() {
        messagePromptMaxLines = 10;
        messagePromptPadding = 12;
      });
    } else {
      setState(() {
        messagePromptMaxLines = 1;
        messagePromptPadding = 0;
      });
    }
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

  void animateToEnd({int milliseconds = 500}) async {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: milliseconds),
      curve: Curves.easeInOut,
    );
  }

  void jumpToEnd() async {
    scrollController.jumpTo(
      scrollController.position.maxScrollExtent,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (needsScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => jumpToEnd());
      needsScroll = false;
    }

    return BlocConsumer<DemuxChatCompletionCubit, DemuxChatCompletionState>(
        listener: (context, state) {
      if (state is ChatCompletionChatSelected) {
        stopGenerating();
        loading = false;
        needsScroll = true;
      }
      if (state is ChatCompletionReturned) {
        loading = true;
        streamController = state.streamController;
        getStreamedResponse();
      }
    }, builder: (context, state) {
      currentChat = state.currentChat;
      messages = currentChat.messages;
      return Stack(
        children: [
          getChatMessagesV3(),
          Align(alignment: Alignment.bottomCenter, child: getMessageControls()),
        ],
      );
    });
  }

  Widget? getFloatingActionButton() {
    return isScrollAtBottom
        ? null
        : Container(
            margin: const EdgeInsets.only(bottom: 60),
            child: FloatingActionButton(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                onPressed: () {
                  setState(() {
                    animateToEnd();
                  });
                },
                mini: true,
                child: const Icon(Icons.keyboard_double_arrow_down_rounded)),
          );
  }

  void stopGenerating() {
    setState(() {
      streamController?.close();
    });
  }

  void typeEllipsisWhileWaiting() {
    setState(() {
      messages.last.content = "...";
    });
  }

  void getStreamedResponse() async {
    try {
      setState(() {
        needsScroll = isListViewScrolledToMax();
        loading = true;
      });
      String assistantMessageContent = "";
      typeEllipsisWhileWaiting();
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
        showSnackbar(err.toString(), context,
            criticality: MessageCriticality.error);
      }, onDone: () {
        setState(() {
          loading = false;
        });
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
    chatCompletionCubit.getChatCompletion(
      userMessageContent,
      image: selectedImage,
    );

    setState(() {
      userMessageController.clear();
      selectedImage = null;
      needsScroll = true;
    });
  }

  Widget getMessageControls() {
    return Padding(
        padding: const EdgeInsets.all(8),
        child: AnimatedContainer(
          curve: Curves.bounceInOut,
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(left: 4, right: 4, top: 0, bottom: 0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 4,
                blurRadius: 5,
                offset: const Offset(0, 0),
              ),
            ],
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (chatCompletionCubit.modelHasVision() && selectedImage == null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.only(bottom: 24),
                  icon: const Icon(Icons.add_photo_alternate),
                  onPressed: selectImageToSend,
                ),
              if (chatCompletionCubit.modelHasVision() && selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                      height: 40,
                      width: 40,
                      child: Stack(children: [
                        Align(
                          alignment: Alignment.center,
                          child: Image.memory(
                          selectedImage!,
                        )),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                selectedImage = null;
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.red,
                            )),
                      ])),
                ),
              Expanded(
                child: Padding(
                    padding: EdgeInsets.all(4),
                    child: TextField(
                      enabled: !loading,
                      controller: userMessageController,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: "Message",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(4),
                      ),
                      focusNode: messagePromptFocusNode,
                      maxLines: messagePromptMaxLines,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                    )),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.only(bottom: 24),
                icon: loading ? const Icon(Icons.stop) : const Icon(Icons.send),
                onPressed: loading ? stopGenerating : sendMessage,
              ),
            ],
          ),
        ));
  }

  void selectImageToSend() async {
    setState(() {
      loadingSelectedImage = true;
    });

    try {
      XFile? imageFile = await pickImage(ImageSource.gallery);
      if (imageFile != null) {
        Uint8List pngBytes = await processImageFile(
          imageFile,
          resize: false,
          compress: false,
        );
        setState(() {
          selectedImage = pngBytes;
        });
      }
    } catch (e) {
      showSnackbar(e.toString(), context,
          criticality: MessageCriticality.error);
    }

    setState(() {
      loadingSelectedImage = false;
    });
  }

  Widget getEditingMessageWidget(int index) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(
            onPressed: () {
              stopEditingMessage(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              messages[index].content = messageEditController.text;
              stopEditingMessage(context);
              chatCompletionCubit.saveCurrentMessages(messages);
            },
            child: const Text("Save"),
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

  Widget chatMessagesItemBuilder(BuildContext context, int index) {
    if (index == messages.length) {
      return loading || messages.isEmpty
          ? const SizedBox.shrink()
          : Center(
              child: TextButton(
                onPressed: sendContinueMessage,
                child: const Text("Continue"),
              ),
            );
    }

    if (!systemPromptsAreVisible && messages[index].role == "system") {
      return const SizedBox.shrink();
    }

    return chatMessageWidget(index);
  }

  List<Widget> chatMessagesWidgetList(BuildContext context) {
    List<Widget> messageWidgetList = [];
    messages.asMap().forEach((index, message) {
      var messageWidget = chatMessagesItemBuilder(context, index);
      messageWidgetList.add(messageWidget);
    });
    var continueWidget = chatMessagesItemBuilder(context, messages.length);
    messageWidgetList.add(continueWidget);
    return messageWidgetList;
  }

  Widget getChatMessagesV3() {
    return Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: getFloatingActionButton(),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(8),
          controller: scrollController,
          child: Column(
            children: [
              ...chatMessagesWidgetList(context),
              Container(
                height: 90,
              )
            ],
          ),
        ));
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
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Container(
            decoration: BoxDecoration(
                color: getMessageColor(messages[index].role),
                borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              dense: false,
              contentPadding:
                  const EdgeInsets.only(left: 8, top: 0, bottom: 8, right: 8),
              horizontalTitleGap: 0,
              title: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.all(6),
                          child: Row(children: [
                            Icon(
                                getMessageIcon(
                                  messages[index].role,
                                ),
                                size: 30,
                                color: Colors.blueGrey),
                            if (messages[index].modelUsed != null)
                              const SizedBox(
                                width: 8,
                              ),
                            if (messages[index].modelUsed != null)
                              Text(
                                messages[index].modelUsed!,
                                style: const TextStyle(fontSize: 14),
                              )
                          ]),
                        ),
                        MenuAnchor(
                          menuChildren: <Widget>[
                            MenuItemButton(
                              child: const Text("Copy"),
                              onPressed: () {
                                copyMessage(context, messages[index].content);
                              },
                            ),
                            MenuItemButton(
                              onPressed: () {
                                startEditingMessage(context, index);
                                chatCompletionCubit
                                    .saveCurrentMessages(messages);
                              },
                              child: const Text("Edit"),
                            ),
                            MenuItemButton(
                              onPressed: () {
                                setState(() {
                                  messages.removeAt(index);
                                  chatCompletionCubit
                                      .saveCurrentMessages(messages);
                                });
                              },
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                          builder: (BuildContext context,
                              MenuController controller, Widget? child) {
                            return IconButton(
                              onPressed: () {
                                if (controller.isOpen) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }
                              },
                              icon: const Icon(Icons.more_vert),
                            );
                          },
                        ),
                      ])),
              titleAlignment: ListTileTitleAlignment.top,
              subtitle: messageBeingEdited == index
                  ? getEditingMessageWidget(index)
                  : Column(children: [
                      if (messages[index].image != null)
                        Image.memory(
                          messages[index].image!,
                          fit: BoxFit.fitHeight,
                        ),
                      if (messages[index].image != null)
                      SizedBox(height: 8,),
                      SelectionArea(
                          child: MarkdownBody(
                        data: messages[index].content,
                        onTapText: () {},
                        onTapLink: (text, url, title) {
                          launchUrl(Uri.parse(url!));
                        },
                        softLineBreak: false,
                        fitContent: false,
                        shrinkWrap: true,
                        builders: {
                          'code': CodeElementBuilder(
                            textScaleFactor:
                                appSettingsCubit.getTextScaleFactor(),
                          ),
                        },
                        styleSheet: MarkdownStyleSheet(
                          textScaleFactor:
                              appSettingsCubit.getTextScaleFactor(),
                        ),
                      ))
                    ]),
            )));
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
