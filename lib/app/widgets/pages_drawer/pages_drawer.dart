import 'package:demux_app/app/utils/show_snackbar.dart';
import 'package:demux_app/app/widgets/pages_drawer/cubit/api_pages_cubit.dart';
import 'package:demux_app/app/widgets/pages_drawer/cubit/page_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class PagesDrawer extends StatefulWidget {
  const PagesDrawer({super.key});

  @override
  State<PagesDrawer> createState() => _PagesDrawerState();
}

class _PagesDrawerState extends State<PagesDrawer> {
  late ApiPagesCubit pagesDrawerCubit;
  String appVersion = '...';

  @override
  void initState() {
    pagesDrawerCubit = BlocProvider.of<ApiPagesCubit>(context);
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        appVersion = packageInfo.version;
      });
    }).catchError((error, stackTrace) {
      print("Error: $error");
    });
    super.initState();
  }

  Widget getPageRouteIcon(DemuxPageRoute route) {
    switch (route.classification) {
      case 'Text to Text':
        return const Icon(Icons.chat);
      case 'Text to Image':
        return const Icon(Icons.image);
      case 'Image to Image':
        return const Icon(Icons.photo_library);
      case 'Text & Image to Image':
        return const Icon(Icons.edit);
      default:
        return const Icon(Icons.help);
    }
  }

  List<Widget> getListTilesFromPageRoutes(
      List<DemuxPageRoute> pageRoutes, BuildContext context) {
    return pageRoutes.map((route) {
      bool selected = pagesDrawerCubit.getCurrentPageRoute() == route;
      return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected ? Colors.blueGrey : Colors.transparent,
          ),
          child: ListTile(
            leading: getPageRouteIcon(route),
            selectedColor: Colors.white,
            title: Text(route.pageName),
            selected: selected,
            onTap: () async {
              await FirebaseAnalytics.instance.logScreenView(
                screenName: route.path,
              );
              pagesDrawerCubit.navigateTo(route);
              Navigator.of(context).pop();
            },
          ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
            child: SingleChildScrollView(
                child: Column(children: [
          const DrawerHeader(
            child: Image(image: AssetImage('assets/app_icon.png')),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blueGrey.shade100.withOpacity(0.5)),
                child: ExpansionTile(
                  shape: InputBorder.none,
                  title: const Text("OpenAI API"),
                  initiallyExpanded: pagesDrawerCubit
                      .isPageFromOpenAi(pagesDrawerCubit.getCurrentPageRoute()),
                  children: getListTilesFromPageRoutes(
                      DemuxPageRoute.openAiPages, context),
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blueGrey.shade100.withOpacity(0.5)),
                child: ExpansionTile(
                  shape: InputBorder.none,
                  title: const Text("Stability AI API"),
                  initiallyExpanded: pagesDrawerCubit.isPageFromStabilityAi(
                      pagesDrawerCubit.getCurrentPageRoute()),
                  children: getListTilesFromPageRoutes(
                      DemuxPageRoute.stabilityAiPages, context),
                )),
          ),
          const ListTile(
            title: Text(
              "Anthropic API (Soon)",
              style: TextStyle(color: Colors.black26),
            ),
          ),
          // ListTile(
          //   title: Text("Llama API (Soon)"),
          // ),
          // ListTile(
          //   title: Text("Google API (Soon)"),
          // )
        ]))),
        Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ListTile(
            leading: const Icon(Icons.settings),
            selectedTileColor: Colors.blueGrey,
            selectedColor: Colors.white,
            title: Text(DemuxPageRoute.appSettings.pageName),
            selected: pagesDrawerCubit.getCurrentPageRoute() ==
                DemuxPageRoute.appSettings,
            onTap: () {
              pagesDrawerCubit.navigateTo(DemuxPageRoute.appSettings);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            dense: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(appVersion),
                const Text("•"),
                TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black),
                  child: const Text("About us"),
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
