import 'package:demux_app/app/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> copyMessage(BuildContext context, String message) async {
  try {
    await Clipboard.setData(ClipboardData(text: message));
    showSnackbar('Message copied to your clipboard!', context);
  } catch (e) {
    showSnackbar('Failed to copy message', context,
        criticality: MessageCriticality.error);
  }
}
