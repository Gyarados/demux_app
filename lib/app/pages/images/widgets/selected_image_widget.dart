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
    return Column(
      children: [
        Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
            child: Row(
              children: [
                const SizedBox(
                  width: 8,
                ),
                const Expanded(
                    child: Text(
                  "Selected image",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                )),
                IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: loadingResults ? null : closeButtonOnPressed,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                ),
              ],
            )),
        Image.memory(
          selectedImage,
          fit: BoxFit.cover,
        ),
      ],
    );
  }
}
