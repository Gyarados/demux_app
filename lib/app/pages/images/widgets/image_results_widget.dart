import 'dart:io';

import 'package:demux_app/app/pages/images/cubit/image_api_cubit.dart';
import 'package:demux_app/app/pages/images/cubit/image_api_states.dart';
import 'package:demux_app/domain/storage_permission.dart';
import 'package:flutter/material.dart';
import 'package:demux_app/app/pages/images/widgets/downloadable_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

List<DownloadableImage> getImages(List<String> imageUrls) {
  return imageUrls
      .map(
        (url) => DownloadableImage(url: url),
      )
      .toList();
}

List<Widget> getPlaceholders() {
  int numPlaceholders = 4;
  int maxAlpha = 100;
  return List.generate(
      numPlaceholders,
      (index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey.shade600.withAlpha(
                      maxAlpha - (index * maxAlpha / numPlaceholders).toInt()),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
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

Widget getImageResultsWidget(ImageApiCubit cubit) {
  return BlocBuilder<ImageApiCubit, ImageApiState>(
    bloc: cubit,
    builder: (context, state) {
      List<DownloadableImage> downloadableImages = getImages(state.urls);
      return Container(
        padding: EdgeInsets.only(top: 16),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    downloadableImages.length == 1
                        ? "${downloadableImages.length} Image"
                        : "${downloadableImages.length} Images",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade200),
                  ),
                  TextButton(
                    onPressed: downloadableImages.isNotEmpty
                        ? () async {
                            await grantExternalStoragePermission();

                            List<Future> futures = [];
                            for (var downloadableImage in downloadableImages) {
                              futures.add(downloadableImage.downloadImage());
                            }
                            await Future.wait(futures);

                            Directory directory =
                                await downloadableImages.first.getDirectory();

                            showDownloadsSnackbar(context, directory);
                          }
                        : null,
                    child: Text("Download all"),
                  ),
                ],
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
