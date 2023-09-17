import 'package:demux_app/app/pages/chat/cubit/chat_completion_cubit.dart';
import 'package:demux_app/app/pages/chat/cubit/chat_completion_states.dart';
import 'package:demux_app/app/pages/chat/widgets/chat_widget.dart';
import 'package:demux_app/app/pages/chat/widgets/settings_widget.dart';
import 'package:demux_app/data/models/chat.dart';
import 'package:demux_app/domain/constants.dart';
import 'package:demux_app/app/pages/base_openai_api_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCompletionPage extends OpenAIBasePage {
  @override
  final String pageName = "Chat Completion";
  @override
  final String pageEndpoint = OPENAI_CHAT_COMPLETION_ENDPOINT;
  @override
  final String apiReferenceUrl = OPENAI_CHAT_COMPLETION_REFERENCE;

  ChatCompletionPage({super.key});

  @override
  State<ChatCompletionPage> createState() => _ChatCompletionPageState();
}

class _ChatCompletionPageState extends State<ChatCompletionPage>
    with SingleTickerProviderStateMixin {
  ChatCompletionCubit chatCompletionCubit = ChatCompletionCubit();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  List<Chat> chats = [];
  List<Chat> selectedChats = [];
  Chat currentChat = Chat.initial();

  bool _showCheckbox = false;

  @override
  void initState() {
    updateChatsFromState(chatCompletionCubit.state);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => chatCompletionCubit,
        child: Scaffold(
            key: scaffoldKey,
            endDrawer: BlocListener<ChatCompletionCubit, ChatCompletionState>(
              listenWhen: (previous, current) =>
                  !(previous is ChatCompletionMessagesSaved &&
                      current is ChatCompletionMessagesSaved),
              listener: (context, state) {
                print("drawer listener called: $state");
                updateChatsFromState(state);
              },
              child: getChatListDrawer(context),
            ),
            onEndDrawerChanged: (isOpened) {
              if (!isOpened) {
                setState(() {
                  _showCheckbox = false;
                  selectedChats.clear();
                });
              }
            },
            body: DefaultTabController(
                length: 2,
                child: Column(children: [
                  Container(
                      color: Colors.blueGrey,
                      child: Row(children: [
                        Expanded(
                            child: TabBar(
                          tabs: [
                            Tab(
                              text: "Chat",
                            ),
                            Tab(
                              text: "Settings",
                            )
                          ],
                        )),
                        getChatListIconButton()
                      ])),
                  Expanded(
                      child: TabBarView(children: [
                    ChatWidget(),
                    ChatSettingsWidget(),
                  ])),
                ]))));
  }

  Widget getChatListIconButton() {
    return IconButton(
        onPressed: () {
          scaffoldKey.currentState!.openEndDrawer();
        },
        icon: Icon(
          Icons.chat,
          color: Colors.white,
        ));
  }

  Drawer getChatListDrawer(BuildContext context) {
    // chats.forEach(
    //     (chat) => print("$chat ${chat == currentChat ? '- selected' : ''}"));
    return Drawer(
      child: Column(children: [
        Container(
          color: Colors.white,
          child: Center(
              child: _showCheckbox
                  ? TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red),
                      onPressed: () {
                        chatCompletionCubit.deleteMultipleChats(selectedChats);
                        setState(() {
                          selectedChats.clear();
                          _showCheckbox = false;
                        });
                      },
                      child: Text("Delete"))
                  : TextButton(
                      onPressed: () {
                        chatCompletionCubit.createNewChat();
                        setState(() {});
                      },
                      child: Text("Create new chat"))),
        ),
        // Expanded(
        //     child: ListView.builder(
        //   padding: EdgeInsets.zero,
        //   itemCount: chats.length,
        //   itemBuilder: getChatListItem,
        // )),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            children:
                chats.map((chat) => getChatListItem(context, chat)).toList(),
          ),
        ))
      ]),
    );
  }

  void updateChatsFromState(ChatCompletionState state) {
    setState(() {
      chats = state.chats;
      currentChat = state.currentChat;
    });
  }

  Widget getChatListItem(BuildContext context, Chat chat) {
    bool isCurrent = chat == currentChat;
    GlobalKey expansionTileKey = GlobalKey();
    GlobalKey listTileKey = GlobalKey();
    GlobalKey gestureDetectorKey = GlobalKey();
    return GestureDetector(
        key: gestureDetectorKey,
        onLongPress: () {
          setState(() {
            _showCheckbox = !_showCheckbox;
          });
          if (_showCheckbox) {
            selectedChats.add(chat);
          } else {
            selectedChats.clear();
          }
        },
        child: _showCheckbox
            ? getChatListItemListTile(listTileKey, isCurrent, chat)
            : getChatListItemExpansionTile(
                expansionTileKey, listTileKey, isCurrent, chat));
  }

  Widget getChatListItemListTile(
      GlobalKey listTileKey, bool isCurrent, Chat chat) {
    return ListTile(
      key: listTileKey,
      selectedColor: Colors.white,
      selectedTileColor: Colors.blueGrey,
      contentPadding: EdgeInsets.only(left: 8),
      trailing: Checkbox(
        value: selectedChats.contains(chat),
        onChanged: (value) {
          setState(() {
            if (value!) {
              selectedChats.add(chat);
            } else {
              selectedChats.remove(chat);
            }
          });
        },
      ),
      onTap: () {
        setState(() {
          bool chatIsSelected = selectedChats.contains(chat);
          if (chatIsSelected) {
            selectedChats.remove(chat);
          } else {
            selectedChats.add(chat);
          }
        });
      },
      title: Text(
        chat.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        "Last updated ${chat.lastUpdated.toLocal().toString()}",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      selected: isCurrent,
    );
  }

  Widget getChatListItemExpansionTile(GlobalKey expansionTileKey,
      GlobalKey listTileKey, bool isCurrent, Chat chat) {
    return ExpansionTile(
      key: expansionTileKey,
      collapsedTextColor: isCurrent ? Colors.white : Colors.black,
      collapsedIconColor: isCurrent ? Colors.white : Colors.black,
      collapsedBackgroundColor: isCurrent ? Colors.blueGrey : Colors.white,
      textColor: isCurrent ? Colors.white : Colors.black,
      iconColor: isCurrent ? Colors.white : Colors.black,
      backgroundColor: isCurrent ? Colors.blueGrey : Colors.white,
      tilePadding: EdgeInsets.only(right: 8),
      title: ListTile(
        key: listTileKey,
        selectedColor: Colors.white,
        selectedTileColor: Colors.blueGrey,
        title: Text(
          chat.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          "Last updated ${chat.lastUpdated.toLocal().toString()}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        selected: isCurrent,
        onTap: isCurrent
            ? null
            : () {
                chatCompletionCubit.selectChat(chat);
                Navigator.of(context).pop();
              },
      ),
      children: [
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red),
                    onPressed: () {
                      chatCompletionCubit.deleteChat(chat);
                    },
                    child: Text("Delete")),
                TextButton(onPressed: () {}, child: Text("Rename")),
              ],
            ))
      ],
    );
  }
}
