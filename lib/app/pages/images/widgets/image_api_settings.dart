import 'dart:typed_data';

import 'package:demux_app/domain/constants.dart';
import 'package:demux_app/app/pages/images/widgets/edit_area_painter.dart';
import 'package:demux_app/app/pages/images/widgets/selectable_area_image_widget.dart';
import 'package:demux_app/app/pages/images/widgets/selected_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown_selectionarea.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget getAPISettingsContainer({
  required List<Widget> children,
}) {
  return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
              color: Colors.black,
              blurRadius: 10,
              spreadRadius: 1,
              blurStyle: BlurStyle.normal),
        ],
      ),
      child: Column(children: children));
}

Widget getImageQuantityAndSizeRow({
  required bool loadingResults,
  required String selectedImageSize,
  required TextEditingController imageQuantityController,
  required void Function(String?)? imageSizeOnChanged,
}) {
  return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: imageQuantityController,
            enabled: !loadingResults,
            decoration: InputDecoration(
              labelText: 'Quantity (1-10)',
              contentPadding: EdgeInsets.all(0.0),
            ),
            keyboardType: TextInputType.number,
          )),
          Expanded(
              child: DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: 'Size',
              contentPadding: EdgeInsets.all(0.0),
            ),
            value: selectedImageSize,
            onChanged: !loadingResults ? imageSizeOnChanged : null,
            items: OPENAI_IMAGE_SIZE_LIST
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )),
        ],
      ));
}

Widget getDescriptionTextField({
  required bool loadingResults,
  required TextEditingController descriptionController,
}) {
  return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
      child: TextField(
        controller: descriptionController,
        enabled: !loadingResults,
        maxLines: 5,
        minLines: 1,
        decoration: InputDecoration(
          labelText: 'Description',
        ),
      ));
}

Widget getGalleryCameraImagePicker({
  required bool loadingResults,
  required bool loadingSelectedImage,
  required void Function()? galleryOnPressed,
  required void Function()? cameraOnPressed,
}) {
  return Padding(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          padding: EdgeInsets.all(8),
          child: Column(children: [
            Row(children: [
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(top: 0, right: 16, left: 16),
                      child: ElevatedButton.icon(
                        onPressed: loadingResults || loadingSelectedImage
                            ? null
                            : galleryOnPressed,
                        icon: Icon(
                          Icons.file_upload,
                          color: Colors.white,
                        ),
                        label: Text(
                          "Gallery",
                          style: TextStyle(color: Colors.white),
                        ),
                      ))),
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(top: 0, right: 16, left: 16),
                      child: ElevatedButton.icon(
                        onPressed: loadingResults || loadingSelectedImage
                            ? null
                            : cameraOnPressed,
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                        label: Text(
                          "Camera",
                          style: TextStyle(color: Colors.white),
                        ),
                      ))),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.image,
                  size: 75,
                  color: Colors.grey.shade500,
                ),
                MarkdownBody(
                    data: "- PNG\n- 1:1 aspect ratio (square)\n- Maximum 4MB"),
              ],
            ),
          ])));
}

Widget getSendButton(
    {required String text,
    required void Function() sendButtonOnPressed,
    bool enabled = true,
    bool loadingResults = false}) {
  return Padding(
      padding: EdgeInsets.only(top: 16),
      child: GestureDetector(
          onTap: loadingResults ? null : sendButtonOnPressed,
          child: Container(
            height: 30,
            width: double.infinity,
            decoration: BoxDecoration(
              color: loadingResults ? Colors.grey[200] : Colors.blueGrey,
            ),
            child: Center(
                child: loadingResults
                    ? SpinKitFadingCube(
                        color: Colors.blueGrey,
                        size: 15,
                      )
                    : Text(
                        text,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
          )));
}

Widget getImageEditAPISettings({
  required bool loadingResults,
  required bool loadingSelectedImage,
  required String selectedImageSize,
  required String sendButtonText,
  required bool sendButtonEnabled,
  Uint8List? selectedImage,
  required EditAreaPainter editAreaPainter,
  required TextEditingController imageQuantityController,
  required TextEditingController descriptionController,
  required void Function(String?)? imageSizeOnChanged,
  required void Function()? galleryOnPressed,
  required void Function()? cameraOnPressed,
  required void Function() sendButtonOnPressed,
  required void Function() removeSelectedImage,
}) {
  return getAPISettingsContainer(children: [
    getImageQuantityAndSizeRow(
      loadingResults: loadingResults,
      selectedImageSize: selectedImageSize,
      imageQuantityController: imageQuantityController,
      imageSizeOnChanged: imageSizeOnChanged,
    ),
    getDescriptionTextField(
      loadingResults: loadingResults,
      descriptionController: descriptionController,
    ),
    if (selectedImage == null)
      getGalleryCameraImagePicker(
        loadingResults: loadingResults,
        loadingSelectedImage: loadingSelectedImage,
        galleryOnPressed: galleryOnPressed,
        cameraOnPressed: cameraOnPressed,
      ),
    if (selectedImage != null)
      SizedBox(
        height: 16,
      ),
    if (selectedImage != null)
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child:SelectableAreaImage(
        editAreaPainter,
        removeSelectedImage,
      )),
    getSendButton(
        text: sendButtonText,
        sendButtonOnPressed: sendButtonOnPressed,
        enabled: sendButtonEnabled,
        loadingResults: loadingResults),
  ]);
}

Widget getImageVariationAPISettings({
  required bool loadingResults,
  required bool loadingSelectedImage,
  required String selectedImageSize,
  required String sendButtonText,
  required bool sendButtonEnabled,
  Uint8List? selectedImage,
  required TextEditingController imageQuantityController,
  required void Function(String?)? imageSizeOnChanged,
  required void Function()? galleryOnPressed,
  required void Function()? cameraOnPressed,
  required void Function() sendButtonOnPressed,
  required void Function() closeButtonOnPressed,
}) {
  return getAPISettingsContainer(children: [
    getImageQuantityAndSizeRow(
      loadingResults: loadingResults,
      selectedImageSize: selectedImageSize,
      imageQuantityController: imageQuantityController,
      imageSizeOnChanged: imageSizeOnChanged,
    ),
    if (selectedImage == null)
      getGalleryCameraImagePicker(
        loadingResults: loadingResults,
        loadingSelectedImage: loadingSelectedImage,
        galleryOnPressed: galleryOnPressed,
        cameraOnPressed: cameraOnPressed,
      ),
    if (selectedImage != null)
      SizedBox(
        height: 16,
      ),
    if (selectedImage != null)
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child:SelectedImageWidget(
        selectedImage: selectedImage,
        loadingResults: loadingResults,
        closeButtonOnPressed: closeButtonOnPressed,
      )),
    getSendButton(
        text: sendButtonText,
        sendButtonOnPressed: sendButtonOnPressed,
        enabled: sendButtonEnabled,
        loadingResults: loadingResults),
  ]);
}

Widget getImageGenerationAPISettings({
  required bool loadingResults,
  required String selectedImageSize,
  required String sendButtonText,
  required TextEditingController imageQuantityController,
  required TextEditingController descriptionController,
  required void Function(String?)? imageSizeOnChanged,
  required void Function() sendButtonOnPressed,
}) {
  return getAPISettingsContainer(children: [
    getImageQuantityAndSizeRow(
      loadingResults: loadingResults,
      selectedImageSize: selectedImageSize,
      imageQuantityController: imageQuantityController,
      imageSizeOnChanged: imageSizeOnChanged,
    ),
    getDescriptionTextField(
      loadingResults: loadingResults,
      descriptionController: descriptionController,
    ),
    getSendButton(
      text: sendButtonText,
      sendButtonOnPressed: sendButtonOnPressed,
      loadingResults: loadingResults,
    ),
  ]);
}
