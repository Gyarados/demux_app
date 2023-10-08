import 'package:demux_app/app/widgets/app_bar.dart';
import 'package:demux_app/app/widgets/pages_drawer/pages_drawer.dart';
import 'package:flutter/material.dart';

Scaffold getPageScaffold(Widget child,
    {required BuildContext context,
    required String pageName,
    String? pageEndpoint,
    String? apiReferenceUrl}) {
  return Scaffold(
    appBar: getAppBar(
        context: context,
        pageName: pageName,
        pageEndpoint: pageEndpoint,
        apiReferenceUrl: apiReferenceUrl),
    drawer: PagesDrawer(),
    body: Container(color: Colors.blueGrey[700], child: child),
  );
}
