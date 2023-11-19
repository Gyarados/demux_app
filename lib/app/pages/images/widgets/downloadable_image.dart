import 'dart:convert';

import 'package:demux_app/app/utils/random_string.dart';
import 'package:demux_app/app/utils/show_snackbar.dart';
import 'package:demux_app/domain/storage_permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class DownloadableImage extends StatelessWidget {
  final String? url;
  final String? b64String;

  const DownloadableImage({
    super.key,
    this.url,
    this.b64String,
  });

  Future<Directory> getDirectory() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory("/storage/emulated/0/Download");
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    if (directory == null) {
      throw Exception("Unable to use download or external directory");
    }
    directory = Directory('${directory.path}/Demux');
    directory.createSync();
    return directory;
  }

  void saveToFile(Uint8List bytes, String filename,
      {BuildContext? context}) async {
    File file;
    Directory directory;
    try {
      directory = await getDirectory();
      file = File('${directory.path}/$filename');
      await file.writeAsBytes(bytes, mode: FileMode.writeOnly);
    } catch (e) {
      print(e);
      if (context != null) {
        showSnackbar('Failed to download image', context,
            criticality: MessageCriticality.error);
      }
      return;
    }

    if (context != null) {
      final snackBar = SnackBar(
        content: Text('Image downloaded to ${directory.path}'),
        action: SnackBarAction(
          label: 'Open',
          textColor: Colors.white,
          onPressed: () {
            OpenFile.open(file.path);
          },
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> downloadImage([BuildContext? context]) async {
    if (b64String != null) {
      var bytes = base64Decode(b64String!);
      String filename = "${randomString(16)}.png";
      saveToFile(bytes, filename, context: context);
    } else {
      Uri uri = Uri.parse(url!);
      String filename = uri.pathSegments.last;
      var response = await http.get(uri);
      var bytes = response.bodyBytes;
      saveToFile(bytes, filename, context: context);
    }
  }

  Widget frameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded || frame != null) {
      return child;
    }
    return const SpinKitRing(
      color: Colors.white,
    );
  }

  Widget loadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) {
      return child;
    }
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.grey.shade300,
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        ));
  }

  Widget errorBuilder(
      BuildContext context, Object exception, StackTrace? stackTrace) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Colors.grey.shade700),
            child: Column(children: [
              Icon(
                Icons.broken_image_outlined,
                color: Colors.grey.shade600,
                size: 150,
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Failed to load image',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.justify,
                    softWrap: true,
                  )),
            ]),
          ),
        ));
  }

  Image getImage() {
    if (b64String != null) {
      return Image.memory(
        base64Decode(b64String!),
        frameBuilder: frameBuilder,
        errorBuilder: errorBuilder,
      );
    } else {
      return Image.network(
        url!,
        loadingBuilder: loadingBuilder,
        errorBuilder: errorBuilder,
      );
    }
  }

  // Future<void> downloadImageFromUrl([BuildContext? context]) async {
  //   Uri uri = Uri.parse(url!);
  //   var response = await http.get(uri);
  //   File file;
  //   Directory directory;
  //   try {
  //     directory = await getDirectory();
  //     String filename = uri.pathSegments.last;
  //     file = File('${directory.path}/$filename');
  //     await file.writeAsBytes(response.bodyBytes, mode: FileMode.writeOnly);
  //   } catch (e) {
  //     print(e);
  //     if (context != null) {
  //       showSnackbar('Failed to download image', context,
  //           criticality: MessageCriticality.error);
  //     }
  //     return;
  //   }

  //   if (context != null) {
  //     final snackBar = SnackBar(
  //       content: Text('Image downloaded to ${directory.path}'),
  //       action: SnackBarAction(
  //         label: 'Open',
  //         textColor: Colors.white,
  //         onPressed: () {
  //           OpenFile.open(file.path);
  //         },
  //       ),
  //     );

  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   }
  // }

  Future<void> copyUrl(BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: url!));
      showSnackbar('URL copied to your clipboard!', context);
    } catch (e) {
      showSnackbar('Failed to copy URL', context,
          criticality: MessageCriticality.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onLongPressStart: (details) {
            FocusScope.of(context).unfocus();
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                  details.globalPosition.dx,
                  details.globalPosition.dy,
                  details.globalPosition.dx,
                  details.globalPosition.dy),
              items: [
                PopupMenuItem(
                  child: TextButton(
                    child: const Text('Download'),
                    onPressed: () async {
                      Navigator.pop(context);
                      await grantExternalStoragePermission();
                      await downloadImage(context);
                    },
                  ),
                ),
                if (url != null)
                  PopupMenuItem(
                    child: TextButton(
                      child: const Text('Copy URL'),
                      onPressed: () {
                        Navigator.pop(context);
                        copyUrl(context);
                      },
                    ),
                  ),
              ],
            );
          },
          child: getImage(),
        ));
  }
}
