import 'dart:io';

import 'package:demux_app/app/pages/images/cubit/image_api_cubit.dart';
import 'package:demux_app/app/pages/images/cubit/image_api_states.dart';
import 'package:demux_app/domain/storage_permission.dart';
import 'package:flutter/material.dart';
import 'package:demux_app/app/pages/images/widgets/downloadable_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

List<DownloadableImage> getImagesFromState(ImageApiState state) {
  if (state.b64Strings != null) {
    return state.b64Strings!
        .map((b64String) => DownloadableImage(b64String: b64String))
        .toList();
  }
  if (state.urls != null) {
    return state.urls!.map((url) => DownloadableImage(url: url)).toList();
  } else {
    return [];
  }
}

List<Widget> getPlaceholders() {
  int numPlaceholders = 4;
  int maxAlpha = 100;
  return List.generate(
      numPlaceholders,
      (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade600.withAlpha(
                      maxAlpha - index * maxAlpha ~/ numPlaceholders),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              height: 100,
            ),
          ));
}

void showDownloadsSnackbar(BuildContext context, Directory directory) {
  final snackBar = SnackBar(
    content: Text('Images downloaded to ${directory.path}'),
    // action: SnackBarAction(
    //   label: 'Open',
    //   textColor: Colors.white,
    //   onPressed: () {
    //     OpenFile.open(
    //       '${directory.path}/',
    //     );
    //   },
    // ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class ImageResultsWidget extends StatefulWidget {
  final ImageApiCubit cubit;
  const ImageResultsWidget(this.cubit, {super.key});

  @override
  State<ImageResultsWidget> createState() => _ImageResultsWidgetState();
}

class _ImageResultsWidgetState extends State<ImageResultsWidget> {
  List<String> imageSources = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageApiCubit, ImageApiState>(
      bloc: widget.cubit,
      builder: (context, state) {
        List<DownloadableImage> downloadableImages = getImagesFromState(state);
        return Container(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  top: 0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blueGrey.shade100,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(children: [
                    if (state.prompt != null)
                      Padding(
                          padding: const EdgeInsets.only(
                              top: 8, left: 8, right: 8, bottom: 0),
                          child: Text('"${state.prompt!}"',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blueGrey.shade800))),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            downloadableImages.length == 1
                                ? "${downloadableImages.length} image"
                                : "${downloadableImages.length} images",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade800),
                          ),
                          TextButton(
                            onPressed: downloadableImages.isNotEmpty
                                ? () async {
                                    await grantExternalStoragePermission();

                                    List<Future> futures = [];
                                    for (var downloadableImage
                                        in downloadableImages) {
                                      futures.add(
                                          downloadableImage.downloadImage());
                                    }
                                    await Future.wait(futures);

                                    Directory directory =
                                        await downloadableImages.first
                                            .getDirectory();

                                    showDownloadsSnackbar(context, directory);
                                  }
                                : null,
                            child: const Text("Download all"),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
              // if (imageUrls.isEmpty) ...getPlaceholders(),
              if (downloadableImages.isNotEmpty) ...downloadableImages,
            ],
          ),
        );
      },
    );
  }
}
