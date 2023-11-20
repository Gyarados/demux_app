import 'package:demux_app/app/pages/chat/cubit/chat_completion_cubit.dart';
import 'package:demux_app/app/pages/settings/cubit/app_settings_cubit.dart';
import 'package:demux_app/app/widgets/pages_drawer/cubit/api_pages_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_strategy/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app/app.dart';

void main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
