import 'package:auto_route/auto_route.dart';
import 'package:demux_app/app/pages/chat/chat_completion_page.dart';
import 'package:demux_app/app/pages/images/image_edit_page.dart';
import 'package:demux_app/app/pages/images/image_generation_page.dart';
import 'package:demux_app/app/pages/images/image_variation_page.dart';
import 'package:demux_app/app/pages/settings/app_settings_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
            path: '/chat-completion',
            page: ChatCompletionRoute.page,
            initial: true),
        AutoRoute(path: '/image-generation', page: ImageGenerationRoute.page),
        AutoRoute(path: '/image-variation', page: ImageVariationRoute.page),
        AutoRoute(path: '/image-edit', page: ImageEditRoute.page),
        AutoRoute(path: '/app-settings', page: AppSettingsRoute.page),
      ];
}
