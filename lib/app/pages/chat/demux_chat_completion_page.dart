import 'package:auto_route/auto_route.dart';
import 'package:demux_app/app/pages/chat/cubit/demux_chat_completion_cubit.dart';
import 'package:demux_app/app/pages/chat/cubit/demux_chat_completion_states.dart';
import 'package:demux_app/app/pages/chat/widgets/demux_chat_widget.dart';
import 'package:demux_app/app/pages/chat/widgets/chat_settings_widget.dart';
import 'package:demux_app/app/pages/settings/cubit/app_settings_cubit.dart';
import 'package:demux_app/app/widgets/introduction_cta.dart';
import 'package:demux_app/data/models/app_settings.dart';
import 'package:demux_app/data/models/demux_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class DemuxChatCompletionPage extends StatefulWidget {
  const DemuxChatCompletionPage({super.key});

  @override
  State<DemuxChatCompletionPage> createState() => _DemuxChatCompletionPageState();
}

class _DemuxChatCompletionPageState extends State<DemuxChatCompletionPage>
    with SingleTickerProviderStateMixin {
  late AppSettingsCubit appSettingsCubit;
  late DemuxChatCompletionCubit chatCompletionCubit;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  List<DemuxChat> chats = [];
  List<DemuxChat> selectedChats = [];
  DemuxChat currentChat = DemuxChat(messages: []);

  TextEditingController chatRenameController = TextEditingController();
  DemuxChat? chatBeingRenamed;

  @override
  void initState() {
    appSettingsCubit = BlocProvider.of<AppSettingsCubit>(context);
    chatCompletionCubit = DemuxChatCompletionCubit();
    // chatCompletionCubit.setApiPagePath(widget.pageRoutePath);
    // chatCompletionCubit.setApiKey(appSettingsCubit.getOpenAiApiKey());
    updateChatsFromState(chatCompletionCubit.state);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DemuxChatCompletionCubit>(
      create: (BuildContext context) => chatCompletionCubit,
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.transparent,
          body: DemuxChatWidget()),
    );
  }

  Widget getChatAndSettingsTabController() {
    return DefaultTabController(
        length: 2,
        child: Column(children: [
          Container(
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(10)),
                  child: Row(children: [
                    const Expanded(
                        child: TabBar(
                      indicatorPadding: EdgeInsets.all(3),
                      dividerColor: Colors.blueGrey,
                      labelColor: Colors.white,
                      indicatorColor: Colors.white,
                      unselectedLabelColor: Colors.white,
                      tabs: [
                        Tab(
                          text: "DemuxChat",
                        ),
                        Tab(
                          text: "Settings",
                        )
                      ],
                    )),
                    getChatListIconButton()
                  ]))),
          Expanded(
              child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                BlocBuilder<AppSettingsCubit, AppSettings>(
                    builder: (context, state) {
                  return Stack(
                    children: [
                      const DemuxChatWidget(),
                      if (appSettingsCubit.showIntroductionMessages() &&
                          appSettingsCubit.openAiApiKeyIsMissing())
                        const IntrodutionCTAWidget(),
                    ],
                  );
                }),

                // ChatWidget(),
                const ChatSettingsWidget(),
              ])),
        ]));
  }

  Widget getChatListIconButton() {
    return IconButton(
        onPressed: () {
          scaffoldKey.currentState!.openEndDrawer();
        },
        icon: const Icon(
          Icons.chat,
          color: Colors.white,
        ));
  }

  void updateChatsFromState(DemuxChatCompletionState state) {
    setState(() {
      chats = state.chats;
      currentChat = state.currentChat;
    });
  }

}
