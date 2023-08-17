import 'package:flutter/material.dart';

enum MessageCriticality {
  info,
  warning,
  error,
}

Widget getSnackBarIcon(MessageCriticality criticality) {
  switch (criticality) {
    case MessageCriticality.info:
      return Icon(
        Icons.info,
        color: Colors.blueGrey,
      );
    case MessageCriticality.warning:
      return Icon(
        Icons.warning,
        color: Colors.amber,
      );
    case MessageCriticality.error:
      return Icon(
        Icons.error,
        color: Colors.red,
      );
  }
}

void showSnackbar(
  String message,
  BuildContext context, {
  MessageCriticality criticality = MessageCriticality.info,
}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    showCloseIcon: true,
    closeIconColor: Colors.white,
    content: ListTile(
      leading: getSnackBarIcon(criticality),
      title: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
    ),
  ));
}
