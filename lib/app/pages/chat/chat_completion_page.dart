import 'dart:async';

import 'package:demux_app/app/constants.dart';
import 'package:demux_app/app/pages/base_openai_api_page.dart';
import 'package:demux_app/app/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown_selectionarea.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatCompletionPage extends OpenAIBasePage {
  @override
  final String pageName = "Chat Completion";
  @override
  final String pageEndpoint = OPENAI_CHAT_COMPLETION_ENDPOINT;
  @override
  final String apiReferenceURL = OPENAI_CHAT_COMPLETION_REFERENCE;

  ChatCompletionPage({super.key});

  @override
  State<ChatCompletionPage> createState() => _ChatCompletionPageState();
}

class _ChatCompletionPageState extends State<ChatCompletionPage> {
  final systemPromptController = TextEditingController();
  final userMessageController = TextEditingController();
  final messageEditController = TextEditingController();
  final temperatureController = TextEditingController(text: "0.5");
  final topPController = TextEditingController();
  final quantityController = TextEditingController();
  final stopController = TextEditingController();
  final maxTokensController = TextEditingController();
  final presencePenaltyController = TextEditingController();
  final frequencyPenaltyController = TextEditingController();
  final logitBiasController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ExpansionTileController settingsExpandController =
      ExpansionTileController();
  bool systemPromptsAreVisible = true;
  int systemPromptMaxLines = 1;
  int messagePromptMaxLines = 1;
  FocusNode systemPromptFocusNode = FocusNode();
  FocusNode messagePromptFocusNode = FocusNode();
  bool sendEmptyMessage = false;
  StreamController? streamController;
  List<Map<String, String>> messages = [];
  bool loading = false;
  bool needsScroll = false;
  bool isScrollAtTop = true;
  bool isScrollAtBottom = true;
  List<String> modelList = OPENAI_CHAT_COMPLETION_MODEL_LIST;
  late String selectedModel = "gpt-3.5-turbo";
  int? messageBeingEdited;
  FocusNode messageEditFocusNode = FocusNode();

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

  systemPromptListener() {
    if (systemPromptFocusNode.hasFocus) {
      setState(() {
        systemPromptMaxLines = 5;
      });
    } else {
      setState(() {
        systemPromptMaxLines = 1;
      });
    }
  }

  messagePromptListener() {
    if (messagePromptFocusNode.hasFocus) {
      setState(() {
        messagePromptMaxLines = 5;
        settingsExpandController.collapse();
      });
    } else {
      setState(() {
        messagePromptMaxLines = 1;
      });
    }
  }

  @override
  void initState() {
    scrollController.addListener(scrollListener);
    systemPromptFocusNode.addListener(systemPromptListener);
    messagePromptFocusNode.addListener(messagePromptListener);
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    if (needsScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => jumpToEnd());
      needsScroll = false;
    }

    return Scaffold(
        floatingActionButton: getFloatingActionButton(),
        body: Column(children: [
          getAPISettings(),
          Expanded(
            child: getChatMessages(),
          ),
          getMessageControls(),
        ]));
  }

  @override
  void dispose() {
    systemPromptController.dispose();
    userMessageController.dispose();
    temperatureController.dispose();
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  Widget getAPISettings() {
    return Container(
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.blueGrey[200]!)),
        child: ExpansionTile(
          controller: settingsExpandController,
          maintainState: true,
          tilePadding: EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.settings),
              Text(selectedModel),
              Icon(Icons.thermostat),
              Text(temperatureController.text),
            ],
          ),
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: 'Model',
                      contentPadding: EdgeInsets.all(0.0),
                    ),
                    value: selectedModel,
                    onChanged: !loading
                        ? (String? value) {
                            setState(() {
                              selectedModel = value!;
                            });
                          }
                        : null,
                    items:
                        modelList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    enabled: !loading,
                    textAlign: TextAlign.center,
                    controller: temperatureController,
                    decoration: InputDecoration(
                      labelText: 'Temperature',
                      contentPadding: EdgeInsets.all(0.0),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            TextField(
              focusNode: systemPromptFocusNode,
              enabled: !loading,
              controller: systemPromptController,
              maxLines: systemPromptMaxLines,
              minLines: 1,
              decoration: InputDecoration(
                labelText: 'System prompt',
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Show system prompts'),
                Checkbox(
                  value: systemPromptsAreVisible,
                  onChanged: (newValue) {
                    setState(() {
                      systemPromptsAreVisible = newValue!;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Send empty message'),
                Checkbox(
                  value: sendEmptyMessage,
                  onChanged: (newValue) {
                    setState(() {
                      sendEmptyMessage = newValue!;
                    });
                  },
                ),
              ],
            ),
          ],
        ));
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

  void startEditingMessage(BuildContext context, int index) {
    setState(() {
      messageBeingEdited = index;
      messageEditController.text = messages[index]["content"]!;
    });
    FocusScope.of(context).unfocus();
  }

  void stopEditingMessage(BuildContext context) {
    setState(() {
      messageBeingEdited = null;
    });
    FocusScope.of(context).unfocus();
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

  Widget chatMessageWidget(int index) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.only(left: 8, top: 0, bottom: 8, right: 8),
      horizontalTitleGap: 0,
      tileColor: getMessageColor(messages[index]["role"]!),
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
                            copyMessage(context, messages[index]["content"]!);
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
              getMessageIcon(messages[index]["role"]!),
            )),
            Expanded(
                child: Icon(
              Icons.more_horiz,
              color: Colors.black,
            ))
          ])),
      titleAlignment: ListTileTitleAlignment.top,
      title: messageBeingEdited == index
          ? Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          stopEditingMessage(context);
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          messages[index]["content"] =
                              messageEditController.text;
                          stopEditingMessage(context);
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
            )
          : SelectionArea(
              child: MarkdownBody(
              data: messages[index]["content"]!,
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

  Widget getChatMessages() {
    return ListView.builder(
      shrinkWrap: true,
      controller: scrollController,
      itemCount: messages.length + 1,
      itemBuilder: (context, index) {
        if (!systemPromptsAreVisible && messages[index]["role"]! == "system") {
          return const SizedBox.shrink();
        }
        if (index == messages.length) {
          return loading || messages.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 150),
                  child: TextButton(
                      onPressed: loading ? null : sendContinueMessage,
                      child: Text("Continue")));
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

  Color getMessageColor(String role) {
    return role == "user" ? Colors.blueGrey.shade50 : Colors.white;
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

  void stopGenerating() {
    setState(() {
      streamController!.close();
    });
  }

  void sendMessage() async {
    setState(() {
      loading = true;
    });

    settingsExpandController.collapse();
    String systemPrompt = systemPromptController.text;
    String userMessageContent = userMessageController.text;
    late double temperature;
    try {
      temperature = double.parse(temperatureController.text);
    } catch (e) {
      showSnackbar("Invalid temperature", context,
          criticality: MessageCriticality.warning);
      return;
    }
    bool isStream = true;

    if (systemPrompt.isNotEmpty) {
      Map<String, String> systemMessage = {
        "role": "system",
        "content": systemPrompt
      };
      setState(() {
        messages.add(systemMessage);
        systemPromptController.clear();
      });
    }

    if (userMessageContent.isNotEmpty || sendEmptyMessage) {
      Map<String, String> userMessage = {
        "role": "user",
        "content": userMessageContent
      };
      setState(() {
        messages.add(userMessage);
      });
    }

    setState(() {
      userMessageController.clear();
      needsScroll = true;
    });

    Map<String, dynamic> body = {
      'model': selectedModel,
      'messages': messages,
      'temperature': temperature,
      'stream': isStream,
    };

    if (false) {
      body['top_p'] = '';
      body['n'] = '';
      body['stop'] = '';
      body['max_tokens'] = '';
      body['presence_penalty'] = '';
      body['frequency_penalty'] = '';
      body['logit_bias'] = '';
      body['user'] = '';
    }

    try {
      streamController = widget.openAI.streamPost(widget.pageEndpoint, body);
      Map<String, String> assistantMessage = {
        "role": "assistant",
        "content": ""
      };
      setState(() {
        messages.add(assistantMessage);
        needsScroll = isListViewScrolledToMax();
      });
      String assistantMessageContent = "";
      streamController!.stream.listen((event) {
        assistantMessageContent += event;
        setState(() {
          messages.last["content"] = assistantMessageContent;
          needsScroll = isListViewScrolledToMax();
        });
      }, onError: (err) {
        print(err);
      }, onDone: () {
        setState(() {
          loading = false;
        });
      });
    } catch (e) {
      showSnackbar(e.toString(), context,
          criticality: MessageCriticality.error);
    }
  }
}
