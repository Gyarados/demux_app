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
  Chat currentChat = Chat.initial();

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
            endDrawer: BlocBuilder<ChatCompletionCubit, ChatCompletionState>(
                builder: (context, state) {
              updateChatsFromState(state);
              return getChatListDrawer(context);
            }),
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
    return Drawer(
      child: Column(children: [
        Container(
            color: Colors.white,
            child: TextButton(
                onPressed: () {
                  chatCompletionCubit.createNewChat();
                  setState(() {});
                },
                child: Text("Create new chat"))),
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
    chats = state.chats;
    currentChat = state.currentChat;
    // print(chats);
    // print(currentChat);
  }

  Widget getChatListItem(BuildContext context, Chat chat) {
    bool isSelected = chat == currentChat;
    print("chat: $chat");
    print("currentChat: $currentChat");
    print("isSelected: $isSelected");
    GlobalKey key = GlobalKey();
    return ExpansionTile(
      key: key,
      
            collapsedTextColor: isSelected ? Colors.white : Colors.black,
      collapsedIconColor: isSelected ? Colors.white : Colors.black,
      collapsedBackgroundColor: isSelected ? Colors.blueGrey : Colors.white,

      textColor: isSelected ? Colors.white : Colors.black,
      iconColor: isSelected ? Colors.white : Colors.black,
      backgroundColor: isSelected ? Colors.blueGrey : Colors.white,

      tilePadding: EdgeInsets.only(right: 8),

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
                      // setState(() {});
                    },
                    child: Text("Delete")),
                TextButton(onPressed: () {}, child: Text("Rename")),
              ],
            ))
      ],
      // title: GestureDetector(
      //     onTap: () {
      //       chatCompletionCubit.selectChat(chat);
      //       setState(() {});

      //       // Navigator.of(context).pop();
      //     },
      //     child: Text(
      //       chat.name,
      //       maxLines: 1,
      //       overflow: TextOverflow.ellipsis,
      //     )),
      // subtitle: Text(
      //   chat.uuid,
      //   maxLines: 1,
      //   overflow: TextOverflow.ellipsis,
      // ),
      title: ListTile(
        selectedColor: Colors.white,
        selectedTileColor: Colors.blueGrey,
        title: Text(
          chat.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          chat.uuid,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        selected: isSelected,
        onTap: isSelected ? null:() {
          chatCompletionCubit.selectChat(chat);
          // Navigator.of(context).pop();
        },
      ),
    );
  }
}
