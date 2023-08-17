import 'package:demux_app/app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget getAPISettingsContainer({
  required List<Widget> children,
}) {
  return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.blueGrey[200]!),
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
  return Row(
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
  );
}

Widget getDescriptionTextField({
  required bool loadingResults,
  required TextEditingController descriptionController,
}) {
  return TextField(
    controller: descriptionController,
    enabled: !loadingResults,
    maxLines: 5,
    minLines: 1,
    decoration: InputDecoration(
      labelText: 'Description',
    ),
  );
}

Widget getGalleryCameraImagePicker({
  required bool loadingResults,
  required bool loadingSelectedImage,
  required void Function()? galleryOnPressed,
  required void Function()? cameraOnPressed,
}) {
  return Padding(
      padding: EdgeInsets.only(top: 16),
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
    bool enabled = true}) {
  return Padding(
      padding: EdgeInsets.only(left: 100, right: 100, top: 16),
      child: TextButton(
        onPressed: enabled ? sendButtonOnPressed : null,
        child: Text(text),
      ));
}

Widget getLoadingResultsWidget() {
  return Padding(
      padding: EdgeInsets.only(left: 100, right: 100, top: 30, bottom: 9),
      child: SpinKitFadingCube(
        color: Colors.blueGrey,
        size: 25,
      ));
}

Widget getImageEditAPISettings({
  required bool loadingResults,
  required bool loadingSelectedImage,
  required String selectedImageSize,
  required String sendButtonText,
  required bool sendButtonEnabled,
  required TextEditingController imageQuantityController,
  required TextEditingController descriptionController,
  required void Function(String?)? imageSizeOnChanged,
  required void Function()? galleryOnPressed,
  required void Function()? cameraOnPressed,
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
    getGalleryCameraImagePicker(
      loadingResults: loadingResults,
      loadingSelectedImage: loadingSelectedImage,
      galleryOnPressed: galleryOnPressed,
      cameraOnPressed: cameraOnPressed,
    ),
    loadingResults
        ? getLoadingResultsWidget()
        : getSendButton(
            text: sendButtonText,
            sendButtonOnPressed: sendButtonOnPressed,
            enabled: sendButtonEnabled),
  ]);
}

Widget getImageVariationAPISettings({
  required bool loadingResults,
  required bool loadingSelectedImage,
  required String selectedImageSize,
  required String sendButtonText,
  required bool sendButtonEnabled,
  required TextEditingController imageQuantityController,
  required void Function(String?)? imageSizeOnChanged,
  required void Function()? galleryOnPressed,
  required void Function()? cameraOnPressed,
  required void Function() sendButtonOnPressed,
}) {
  return getAPISettingsContainer(children: [
    getImageQuantityAndSizeRow(
      loadingResults: loadingResults,
      selectedImageSize: selectedImageSize,
      imageQuantityController: imageQuantityController,
      imageSizeOnChanged: imageSizeOnChanged,
    ),
    getGalleryCameraImagePicker(
      loadingResults: loadingResults,
      loadingSelectedImage: loadingSelectedImage,
      galleryOnPressed: galleryOnPressed,
      cameraOnPressed: cameraOnPressed,
    ),
    loadingResults
        ? getLoadingResultsWidget()
        : getSendButton(
            text: sendButtonText,
            sendButtonOnPressed: sendButtonOnPressed,
            enabled: sendButtonEnabled),
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
    // getLoadingResultsWidget(),
    loadingResults
        ? getLoadingResultsWidget()
        : getSendButton(
            text: sendButtonText,
            sendButtonOnPressed: sendButtonOnPressed,
          ),
  ]);
}
