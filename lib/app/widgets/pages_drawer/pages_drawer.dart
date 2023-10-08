import 'package:demux_app/app/widgets/pages_drawer/cubit/pages_drawer_cubit.dart';
import 'package:demux_app/app/widgets/pages_drawer/cubit/pages_drawer_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PagesDrawer extends StatefulWidget {
  const PagesDrawer({super.key});

  @override
  State<PagesDrawer> createState() => _PagesDrawerState();
}

class _PagesDrawerState extends State<PagesDrawer> {
  late PagesDrawerCubit pagesDrawerCubit;

  @override
  void initState() {
    pagesDrawerCubit = BlocProvider.of<PagesDrawerCubit>(context);
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
            title: Text("OpenAI"),
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
          ListTile(
            title: Text("Llama API (Soon)"),
          ),
          ListTile(
            title: Text("Google API (Soon)"),
          )
        ]),
        ListTile(
          leading: Icon(Icons.settings),
          selectedTileColor: Colors.blueGrey,
          selectedColor: Colors.white,
          title: Text(PageRoutes.appSettings.pageName),
          selected: pagesDrawerCubit.getCurrentPage() == PageRoutes.appSettings,
          onTap: () {
            pagesDrawerCubit.navigateTo(PageRoutes.appSettings);
            Navigator.of(context).pop();
          },
        ),
      ]),
    );
  }
}
