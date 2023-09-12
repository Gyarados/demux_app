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
  int _selectedChatIndex = 0;

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
          endDrawer: Builder(builder: (context) => getChatListDrawer(context)),
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
              ]))),
    );
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
    return Drawer(child: BlocBuilder<ChatCompletionCubit, ChatCompletionState>(
        builder: (context, state) {
      updateChatsFromState(state);
      return Column(children: [
        Container(
            width: double.infinity,
            color: Colors.white,
            child: TextButton(
                onPressed: () {
                  chatCompletionCubit.createNewChat();
                  setState(() {});
                },
                child: Text("Create new chat"))),
        Expanded(
            child: ListView(
          reverse: true,
          padding: EdgeInsets.zero,
          children: getChatListItems(context),
        ))
      ]);
    }));
  }

  void updateChatsFromState(ChatCompletionState state) {
    chats = state.chats;
    _selectedChatIndex = state.currentChatIndex;
  }

  List<ExpansionTile> getChatListItems(BuildContext context) {
    return chats.asMap().entries.map((entry) {
      int index = entry.key;
      String chatName = "New chat";
      if (entry.value.messages.isNotEmpty) {
        String firstMessage = entry.value.messages.first.content;
        chatName = firstMessage;
      }
      bool isSelected = _selectedChatIndex == index;
      return ExpansionTile(
        collapsedBackgroundColor: isSelected ? Colors.blueGrey : Colors.white,
        backgroundColor: isSelected ? Colors.blueGrey : Colors.white,
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
                        chatCompletionCubit.deleteChat(index);
                        setState(() {});
                      },
                      child: Text("Delete")),
                  TextButton(onPressed: () {}, child: Text("Rename")),
                ],
              ))
        ],
        title: ListTile(
          selectedColor: Colors.white,
          selectedTileColor: Colors.blueGrey,
          // trailing: IconButton(icon: Icon(Icons.close), onPressed: (){},),
          title: Text(
            chatName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          selected: isSelected,
          onTap: () {
            setState(() {
              _selectedChatIndex = index;
            });
            chatCompletionCubit.selectChat(_selectedChatIndex);
            Navigator.of(context).pop();
          },
        ),
      );
    }).toList();
  }
}
