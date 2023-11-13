import 'package:demux_app/app/pages/chat/chat_completion_page.dart';
import 'package:demux_app/app/pages/images/image_edit_page.dart';
import 'package:demux_app/app/pages/images/image_generation_page.dart';
import 'package:demux_app/app/pages/images/image_variation_page.dart';
import 'package:demux_app/app/pages/images/stability_ai_text_to_image_page.dart';
import 'package:demux_app/app/pages/settings/app_settings_page.dart';
import 'package:demux_app/app/pages/settings/cubit/app_settings_cubit.dart';
import 'package:demux_app/app/widgets/app_bar.dart';
import 'package:demux_app/app/widgets/limited_width.dart';
import 'package:demux_app/app/widgets/pages_drawer/cubit/api_pages_cubit.dart';
import 'package:demux_app/app/widgets/pages_drawer/cubit/page_routes.dart';
import 'package:demux_app/app/widgets/pages_drawer/pages_drawer.dart';
import 'package:demux_app/data/models/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late AppSettingsCubit appSettingsCubit;
  late ApiPagesCubit pagesDrawerCubit;

  @override
  void initState() {
    appSettingsCubit = BlocProvider.of<AppSettingsCubit>(context);
    pagesDrawerCubit = BlocProvider.of<ApiPagesCubit>(context);
    super.initState();
  }

  Widget getCurrentPage(DemuxPageRoute pageRoute) {
    switch (pageRoute) {
      // OpenAI
      case DemuxPageRoute.openAiChatCompletion:
        return ChatCompletionPage();
      case DemuxPageRoute.openAiImageGeneration:
        return ImageGenerationPage();
      case DemuxPageRoute.openAiImageEdit:
        return ImageEditPage();
      case DemuxPageRoute.openAiImageVariation:
        return ImageVariationPage();

      // Stability AI
      case DemuxPageRoute.stabilityAiImageGeneration:
        return StabilityAiTextToImagePage();

      // App
      case DemuxPageRoute.appSettings:
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
                  scrollbarTheme: ScrollbarThemeData(
                      thumbColor: MaterialStateColor.resolveWith(
                          (states) => Colors.blueGrey.shade300),
                      trackColor: MaterialStateColor.resolveWith(
                          (states) => Colors.transparent)),
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
              home: BlocBuilder<ApiPagesCubit, DemuxPageRoute>(
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
                      child: getLimitedWidthWidget(
                          width: 1600, child: getCurrentPage(pageRoute))),
                ),
              ),
            ));
  }
}
