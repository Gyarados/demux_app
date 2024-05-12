import 'package:demux_app/app/app.dart';
import 'package:demux_app/app/pages/chat/cubit/chat_completion_cubit.dart';
import 'package:demux_app/app/pages/settings/cubit/app_settings_cubit.dart';
import 'package:demux_app/app/widgets/pages_drawer/cubit/api_pages_cubit.dart';
import 'package:demux_app/domain/constants.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher, kIsWeb;
import 'package:url_strategy/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: refactor Firebase integration to service
  if (ENABLE_FIREBASE) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getTemporaryDirectory(),
  );

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<ApiPagesCubit>(
        create: (BuildContext context) => ApiPagesCubit(),
      ),
      BlocProvider<AppSettingsCubit>(
        create: (BuildContext context) => AppSettingsCubit(),
      ),
      BlocProvider<ChatCompletionCubit>(
        create: (BuildContext context) => ChatCompletionCubit(),
      ),
      // BlocProvider<ImageResultsCubit>(
      //   create: (BuildContext context) => ImageResultsCubit(),
      // ),
      // BlocProvider<EditImageResultsCubit>(
      //   create: (BuildContext context) => EditImageResultsCubit(),
      // ),
      // BlocProvider<VariationImageResultsCubit>(
      //   create: (BuildContext context) => VariationImageResultsCubit(),
      // ),
      // BlocProvider<GenerationImageResultsCubit>(
      //   create: (BuildContext context) => GenerationImageResultsCubit(),
      // ),
    ],
    child: const App(),
  ));
}
