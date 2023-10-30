import 'package:demux_app/app/pages/chat/chat_completion_page.dart';
import 'package:demux_app/app/pages/images/image_edit_page.dart';
import 'package:demux_app/app/pages/images/image_generation_page.dart';
import 'package:demux_app/app/pages/images/image_variation_page.dart';
import 'package:demux_app/app/pages/settings/app_settings_page.dart';
import 'package:demux_app/app/pages/settings/cubit/app_settings_cubit.dart';
import 'package:demux_app/app/widgets/app_bar.dart';
import 'package:demux_app/app/widgets/pages_drawer/cubit/pages_drawer_cubit.dart';
import 'package:demux_app/app/widgets/pages_drawer/cubit/pages_drawer_states.dart';
import 'package:demux_app/app/widgets/pages_drawer/pages_drawer.dart';
import 'package:demux_app/data/models/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildRunnableApp({
  required bool isWeb,
  required double webAppWidth,
  required Widget app,
}) {
  if (!isWeb) {
    return app;
  }

  return Container(
    color: Colors.blueGrey.shade200,
    child: Center(
      child: ClipRect(
        child: SizedBox(
          width: webAppWidth,
          child: app,
        ),
      ),
    ),
  );
}


class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late AppSettingsCubit appSettingsCubit;
  late PagesDrawerCubit pagesDrawerCubit;

  // ChatCompletionPage chatCompletionPage = ChatCompletionPage();
  // ImageGenerationPage imageGenerationPage = ImageGenerationPage();
  // ImageEditPage imageEditPage = ImageEditPage();
  // ImageVariationPage imageVariationPage = ImageVariationPage();
  // AppSettingsPage appSettingsPage = AppSettingsPage();
  @override
  void initState() {
    appSettingsCubit = BlocProvider.of<AppSettingsCubit>(context);
    pagesDrawerCubit = BlocProvider.of<PagesDrawerCubit>(context);
    super.initState();
  }

  Widget getCurrentPage(PageRoutes pageRoute) {
    switch (pageRoute) {
      case PageRoutes.chatCompletion:
        return ChatCompletionPage();
      case PageRoutes.imageGeneration:
        return ImageGenerationPage();
      case PageRoutes.imageEdit:
        return ImageEditPage();
      case PageRoutes.imageVariation:
        return ImageVariationPage();
      case PageRoutes.appSettings:
        return AppSettingsPage();
      default:
        return ChatCompletionPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettings>(
        builder: (context, appSettingsState) => MaterialApp(
              title: 'Demux',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
                  textTheme: GoogleFonts.poppinsTextTheme(),
                  // brightness: state.isDarkMode ? Brightness.dark : Brightness.light,
                  primarySwatch: Colors.blueGrey,
                  primaryColor: Colors.blueGrey,
                  // hintColor: Colors.blueGrey,
                  // focusColor: Colors.blueGrey,
                  // indicatorColor: Colors.blueGrey,
                  // scaffoldBackgroundColor: Colors.white,
                  scrollbarTheme: ScrollbarThemeData(thumbColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey.shade300),
                  trackColor: MaterialStateColor.resolveWith((states) => Colors.transparent)),
                  textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueGrey,
                          disabledBackgroundColor: Colors.grey.shade400)),
                  checkboxTheme: CheckboxThemeData(
                      fillColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.blueGrey;
                    } else {
                      return Colors.transparent;
                    }
                  }))),
              debugShowCheckedModeBanner: false,
              home: BlocBuilder<PagesDrawerCubit, PageRoutes>(
                builder: (context, pageRoute) => Scaffold(
                  appBar: getAppBar(
                    context: context,
                    pageName: pageRoute.pageName,
                    pageEndpoint: pageRoute.pageEndpoint,
                    apiReferenceUrl: pageRoute.apiReferenceUrl,
                  ),
                  drawer: PagesDrawer(),
                  body: Container(
                      color: Colors.blueGrey[700],
                      child: getCurrentPage(pageRoute)),
                ),
              ),
            ));
  }
}
