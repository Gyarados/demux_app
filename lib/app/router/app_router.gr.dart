// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AppSettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AppSettingsPage(),
      );
    },
    ChatCompletionRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ChatCompletionPage(),
      );
    },
    ImageEditRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ImageEditPage(),
      );
    },
    ImageGenerationRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ImageGenerationPage(),
      );
    },
    ImageVariationRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ImageVariationPage(),
      );
    },
  };
}

/// generated route for
/// [AppSettingsPage]
class AppSettingsRoute extends PageRouteInfo<void> {
  const AppSettingsRoute({List<PageRouteInfo>? children})
      : super(
          AppSettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'AppSettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ChatCompletionPage]
class ChatCompletionRoute extends PageRouteInfo<void> {
  const ChatCompletionRoute({List<PageRouteInfo>? children})
      : super(
          ChatCompletionRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChatCompletionRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ImageEditPage]
class ImageEditRoute extends PageRouteInfo<void> {
  const ImageEditRoute({List<PageRouteInfo>? children})
      : super(
          ImageEditRoute.name,
          initialChildren: children,
        );

  static const String name = 'ImageEditRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ImageGenerationPage]
class ImageGenerationRoute extends PageRouteInfo<void> {
  const ImageGenerationRoute({List<PageRouteInfo>? children})
      : super(
          ImageGenerationRoute.name,
          initialChildren: children,
        );

  static const String name = 'ImageGenerationRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ImageVariationPage]
class ImageVariationRoute extends PageRouteInfo<void> {
  const ImageVariationRoute({List<PageRouteInfo>? children})
      : super(
          ImageVariationRoute.name,
          initialChildren: children,
        );

  static const String name = 'ImageVariationRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
