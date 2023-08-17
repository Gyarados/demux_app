import 'dart:io';

import 'package:flutter/material.dart';
import 'package:demux_app/app/pages/images/widgets/downloadable_image.dart';

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

Widget getImageResultsWidget(
    BuildContext context, List<String> imageUrls, bool loadingResults) {
  loadingResults = true;
  List<DownloadableImage> downloadableImages = getImages(imageUrls);
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
                imageUrls.length == 1
                    ? "${imageUrls.length} Image"
                    : "${imageUrls.length} Images",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade200),
              ),
              TextButton(
                onPressed: imageUrls.isNotEmpty
                    ? () async {
                        for (var downloadableImage in downloadableImages) {
                          await downloadableImage.downloadImage();
                        }
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
        if (imageUrls.isNotEmpty) ...downloadableImages,
      ],
    ),
  );
}
