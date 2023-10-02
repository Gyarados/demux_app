import 'package:demux_app/app/pages/chat/cubit/chat_completion_cubit.dart';
import 'package:demux_app/app/pages/images/widgets/image_results/cubit/image_results_cubit.dart';
import 'package:demux_app/app/pages/settings/cubit/app_settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getTemporaryDirectory());

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<AppSettingsCubit>(
        create: (BuildContext context) => AppSettingsCubit(),
      ),
      BlocProvider<ChatCompletionCubit>(
        create: (BuildContext context) => ChatCompletionCubit(),
      ),
      BlocProvider<ImageResultsCubit>(
        create: (BuildContext context) => ImageResultsCubit(),
      ),
      BlocProvider<EditImageResultsCubit>(
        create: (BuildContext context) => EditImageResultsCubit(),
      ),
      BlocProvider<VariationImageResultsCubit>(
        create: (BuildContext context) => VariationImageResultsCubit(),
      ),
      BlocProvider<GenerationImageResultsCubit>(
        create: (BuildContext context) => GenerationImageResultsCubit(),
      ),
    ],
    child: const App(),
  ));
}
