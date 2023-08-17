import 'dart:typed_data';

import 'package:flutter/material.dart';

class SelectedImageWidget extends StatelessWidget {
  final Uint8List selectedImage;
  final bool loadingResults;
  final Function() closeButtonOnPressed;

  const SelectedImageWidget({
    super.key,
    required this.selectedImage,
    required this.loadingResults,
    required this.closeButtonOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30))),
                  child: IconButton(
                    padding: EdgeInsets.all(0),
                    onPressed: loadingResults ? null : closeButtonOnPressed,
                    icon: Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                  )),
            ],
          ),
          Image.memory(
            selectedImage,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );

    // return Stack(
    //   children: [
    //     Image.memory(
    //       selectedImage,
    //       fit: BoxFit.cover,
    //     ),
    //     Align(
    //       alignment: Alignment(1, 0),
    //       child: IconButton(
    //         onPressed: loadingResults ? null : closeButtonOnPressed,
    //         icon: Icon(
    //           Icons.close,
    //           color: Colors.red,
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }
}
