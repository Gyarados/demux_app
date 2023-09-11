import 'package:demux_app/app/pages/chat/cubit/chat_completion_cubit.dart';
import 'package:demux_app/app/pages/chat/widgets/chat_widget.dart';
import 'package:demux_app/app/pages/chat/widgets/settings_widget.dart';
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
  List<String> chatList = [
    "Chat 1",
    "Chat 2",
    "Chat 3",
  ];
  int _selectedChatIndex = 0;

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
          print("is this being called?");
          scaffoldKey.currentState!.openEndDrawer(); //<-- SEE HERE
        },
        icon: Icon(
          Icons.chat,
          color: Colors.white,
        ));
  }

  Drawer getChatListDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ...getChatListItems(context),
        ],
      ),
    );
  }

  List<ListTile> getChatListItems(BuildContext context) {
    return chatList.asMap().entries.map((entry) {
      int index = entry.key;
      String chatName = entry.value;
      return ListTile(
        title: Text(chatName),
        selected: _selectedChatIndex == index,
        onTap: () {
          setState(() {
            _selectedChatIndex = index;
          });
          Navigator.of(context).pop();
        },
      );
    }).toList();
  }
}
