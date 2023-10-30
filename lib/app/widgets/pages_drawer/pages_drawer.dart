import 'package:demux_app/app/utils/show_snackbar.dart';
import 'package:demux_app/app/widgets/pages_drawer/cubit/pages_drawer_cubit.dart';
import 'package:demux_app/app/widgets/pages_drawer/cubit/pages_drawer_states.dart';
import 'package:demux_app/domain/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class PagesDrawer extends StatefulWidget {
  const PagesDrawer({super.key});

  @override
  State<PagesDrawer> createState() => _PagesDrawerState();
}

class _PagesDrawerState extends State<PagesDrawer> {
  late PagesDrawerCubit pagesDrawerCubit;
  String appVersion = '...';

  @override
  void initState() {
    pagesDrawerCubit = BlocProvider.of<PagesDrawerCubit>(context);
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        appVersion = packageInfo.version;
      });
    }).catchError((error, stackTrace) {
      print("Error: $error");
    });
    super.initState();
  }

  void onDrawerItemTapped(int index) {}

  List<ListTile> getListTilesFromPages(List pages, BuildContext context) {
    return pages.asMap().entries.map((entry) {
      return ListTile(
        title: Text("page.pageName"),
        selected: false,
        onTap: () {
          Navigator.of(context).pop();
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(children: [
          DrawerHeader(
            child: Image(image: AssetImage('assets/app_icon.png')),
          ),
          ExpansionTile(
            title: Text("OpenAI API"),
            initiallyExpanded: pagesDrawerCubit
                .isPageFromOpenAi(pagesDrawerCubit.getCurrentPage()),
            children: [
              ListTile(
                leading: Icon(Icons.chat_bubble_rounded),
                selectedTileColor: Colors.blueGrey,
                selectedColor: Colors.white,
                title: Text(PageRoutes.chatCompletion.pageName),
                selected: pagesDrawerCubit.getCurrentPage() ==
                    PageRoutes.chatCompletion,
                onTap: () {
                  pagesDrawerCubit.navigateTo(PageRoutes.chatCompletion);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                selectedTileColor: Colors.blueGrey,
                selectedColor: Colors.white,
                title: Text(PageRoutes.imageGeneration.pageName),
                selected: pagesDrawerCubit.getCurrentPage() ==
                    PageRoutes.imageGeneration,
                onTap: () {
                  pagesDrawerCubit.navigateTo(PageRoutes.imageGeneration);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                selectedTileColor: Colors.blueGrey,
                selectedColor: Colors.white,
                title: Text(PageRoutes.imageVariation.pageName),
                selected: pagesDrawerCubit.getCurrentPage() ==
                    PageRoutes.imageVariation,
                onTap: () {
                  pagesDrawerCubit.navigateTo(PageRoutes.imageVariation);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                selectedTileColor: Colors.blueGrey,
                selectedColor: Colors.white,
                title: Text(PageRoutes.imageEdit.pageName),
                selected:
                    pagesDrawerCubit.getCurrentPage() == PageRoutes.imageEdit,
                onTap: () {
                  pagesDrawerCubit.navigateTo(PageRoutes.imageEdit);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          ListTile(
            title: Text("Claude API (Soon)"),
          ),
          // ListTile(
          //   title: Text("Llama API (Soon)"),
          // ),
          // ListTile(
          //   title: Text("Google API (Soon)"),
          // )
        ]),
        Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ListTile(
            leading: Icon(Icons.settings),
            selectedTileColor: Colors.blueGrey,
            selectedColor: Colors.white,
            title: Text(PageRoutes.appSettings.pageName),
            selected:
                pagesDrawerCubit.getCurrentPage() == PageRoutes.appSettings,
            onTap: () {
              pagesDrawerCubit.navigateTo(PageRoutes.appSettings);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            dense: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(appVersion),
                Text("•"),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black),
                  child: Text("About us"),
                  onPressed: () async {
                    Uri uri = Uri.parse("https://www.desidera.dev");
                    try {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        throw 'Could not launch $uri';
                      }
                    } catch (e) {
                      showSnackbar(e.toString(), context,
                          criticality: MessageCriticality.error);
                    }
                  },
                )
              ],
            ),
            onTap: null,
          ),
        ]),
      ]),
    );
  }
}
