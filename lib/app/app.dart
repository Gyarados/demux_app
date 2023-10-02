import 'package:demux_app/app/pages/base_openai_api_page.dart';
import 'package:demux_app/app/pages/chat/chat_completion_page.dart';
import 'package:demux_app/app/pages/images/image_edit_page.dart';
import 'package:demux_app/app/pages/images/image_generation_page.dart';
import 'package:demux_app/app/pages/images/image_variation_page.dart';
import 'package:demux_app/app/pages/settings/app_settings_page.dart';
import 'package:demux_app/app/pages/settings/cubit/app_settings_cubit.dart';
import 'package:demux_app/app/utils/show_snackbar.dart';
import 'package:demux_app/data/models/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final AppSettingsCubit appSettingsCubit = AppSettingsCubit();
  int _selectedDrawerIndex = 0;

  static List<OpenAIBasePage> pages = [
    ChatCompletionPage(),
    ImageGenerationPage(),
    ImageEditPage(),
    ImageVariationPage(),
    AppSettingsPage()
  ];

  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedDrawerIndex = index;
    });
  }

  OpenAIBasePage getCurrentPage() {
    return pages[_selectedDrawerIndex];
  }

  AppBar getAppBar(String titleText, BuildContext context) {
    return AppBar(
      actions: getCurrentPage().apiReferenceUrl != null
          ? [
              IconButton(
                  onPressed: () async {
                    Uri apiReferenceUri =
                        Uri.parse(getCurrentPage().apiReferenceUrl!);
                    try {
                      if (await canLaunchUrl(apiReferenceUri)) {
                        await launchUrl(apiReferenceUri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        throw 'Could not launch $apiReferenceUri';
                      }
                    } catch (e) {
                      showSnackbar(e.toString(), context,
                          criticality: MessageCriticality.error);
                    }
                  },
                  icon: Icon(
                    Icons.help_outline,
                    color: Colors.white,
                  ))
            ]
          : null,
      title: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
              text: getCurrentPage().pageName, // \n creates a new line
              style: TextStyle(fontSize: 18),
            ),
            if (getCurrentPage().pageEndpoint != null)
              TextSpan(
                text: '\n${getCurrentPage().pageEndpoint}',
                style: TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
      toolbarHeight: 45,
    );
  }

  List<ListTile> getListTilesFromPages(BuildContext context) {
    return pages.asMap().entries.map((entry) {
      int index = entry.key;
      OpenAIBasePage page = entry.value;

      return ListTile(
        title: Text(page.pageName),
        selected: _selectedDrawerIndex == index,
        onTap: () {
          _onDrawerItemTapped(index);
          Navigator.of(context).pop();
        },
      );
    }).toList();
  }

  Drawer getDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Text('Demux'),
          ),
          ...getListTilesFromPages(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettings>(
      bloc: appSettingsCubit,
      builder:(context, state) => MaterialApp(
      title: 'Demux',
      theme: ThemeData(
          // brightness: state.isDarkMode ? Brightness.dark : Brightness.light,
          primarySwatch: Colors.blueGrey,
          primaryColor: Colors.blueGrey,
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueGrey,
                  disabledBackgroundColor: Colors.grey.shade400))),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: getAppBar("Demux", context),
        drawer: Builder(builder: (context) => getDrawer(context)),
        body: Container(color: Colors.blueGrey[700], child: getCurrentPage()),
      ),
    ));
  }
}
