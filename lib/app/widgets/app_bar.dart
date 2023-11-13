import 'package:demux_app/app/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

AppBar getAppBar(
    {required BuildContext context,
    required String pageName,
    String? pageEndpoint,
    String? apiReferenceUrl}) {
  return AppBar(
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    actions: apiReferenceUrl != null
        ? [
            IconButton(
                onPressed: () async {
                  Uri apiReferenceUri = Uri.parse(apiReferenceUrl);
                  try {
                    if (await canLaunchUrl(apiReferenceUri)) {
                      await launchUrl(apiReferenceUri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      throw 'Could not launch $apiReferenceUri';
                    }
                  } catch (e) {
                    showSnackbar(e.toString(), context,
                        criticality: MessageCriticality.error);
                  }
                },
                icon: Icon(
                  Icons.help_outline,
                  color: Colors.white,
                ))
          ]
        : null,
    title: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: pageName, // \n creates a new line
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          if (pageEndpoint != null)
            TextSpan(
              text: '\n$pageEndpoint',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
        ],
      ),
    ),
    toolbarHeight: 45,
    backgroundColor: Colors.blueGrey,
    shadowColor: Colors.black,
    elevation: 3,
  );
}
