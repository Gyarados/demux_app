import 'dart:typed_data';
import 'package:demux_app/app/pages/chat/widgets/double_slider_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:demux_app/domain/constants.dart';
import 'package:demux_app/app/pages/images/widgets/edit_area_painter.dart';
import 'package:demux_app/app/pages/images/widgets/selectable_area_image_widget.dart';
import 'package:demux_app/app/pages/images/widgets/selected_image_widget.dart';
import 'package:demux_app/app/widgets/model_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown_selectionarea.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget getAPISettingsContainer({
  required List<Widget> children,
}) {
  return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            color: Colors.grey[200],
            boxShadow: [
              BoxShadow(
                  color: Colors.black,
                  blurRadius: 4,
                  spreadRadius: 1,
                  blurStyle: BlurStyle.normal),
            ],
          ),
          child: Column(children: children)));
}

Widget getImageQuantityInput(
  bool loadingResults,
  TextEditingController imageQuantityController,
) {
  return TextField(
    controller: imageQuantityController,
    enabled: !loadingResults,
    decoration: InputDecoration(
      labelText: 'Quantity (1-10)',
      contentPadding: EdgeInsets.all(0.0),
    ),
    keyboardType: TextInputType.number,
  );
}

Widget getImageQuantityAndSizeDropdownRow({
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
              child: getImageQuantityInput(
            loadingResults,
            imageQuantityController,
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

Widget getImageQuantityAndSizeDoubleInput({
  required bool loadingResults,
  required TextEditingController imageQuantityController,
  required Function(double value) onHeightChanged,
  required Function(double value) onWidthChanged,
}) {
  return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
      child: Column(
        children: [
          Expanded(
              child: getImageQuantityInput(
            loadingResults,
            imageQuantityController,
          )),
          DoubleSliderWidget(
            label: "Height",
            min: 128,
            max: 1536,
            divisions: 24,
            defaultValue: 512,
            currentValue: 512,
            fractionDigits: 0,
            onChanged: onHeightChanged,
          ),
          DoubleSliderWidget(
            label: "Width",
            min: 128,
            max: 1536,
            divisions: 24,
            defaultValue: 512,
            currentValue: 512,
            fractionDigits: 0,
            onChanged: onWidthChanged,
          ),
        ],
      ));
}

Widget getDescriptionTextField({
  required bool loadingResults,
  required TextEditingController descriptionController,
  int? maxLength = 1000,
}) {
  return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
      child: TextField(
        controller: descriptionController,
        enabled: !loadingResults,
        maxLines: 5,
        minLines: 1,
        maxLength: maxLength,
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
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey),
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
              if (!kIsWeb)
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(top: 0, right: 16, left: 16),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey),
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
      padding: EdgeInsets.only(top: 8),
      child: !loadingResults
          ? Padding(
              padding: EdgeInsets.all(8),
              child: TextButton(
                onPressed: sendButtonOnPressed,
                child: Text(text),
              ))
          : Padding(
              padding: EdgeInsets.all(16),
              child: SpinKitRing(
                lineWidth: 4,
                size: 32,
                color: Colors.blueGrey,
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
    getImageQuantityAndSizeDropdownRow(
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
          child: SelectableAreaImage(
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
    getImageQuantityAndSizeDropdownRow(
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
          child: SelectedImageWidget(
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
    getImageQuantityAndSizeDropdownRow(
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

Widget getStabilityAiTextToImageAPISettings({
  required bool loadingResults,
  required String sendButtonText,
  required double quantity,
  required double height,
  required double width,
  required TextEditingController descriptionController,
  required void Function() sendButtonOnPressed,
  required void Function(double value) onHeightChanged,
  required void Function(double value) onWidthChanged,
  required void Function(double value) onQuantityChanged,
  required Function updateModelList,
  required Function saveSelectedModel,
  required Function getSelectedModel,
}) {
  return getAPISettingsContainer(children: [
    getDescriptionTextField(
        loadingResults: loadingResults,
        descriptionController: descriptionController,
        maxLength: null),
    Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 8),
        child: ModelDropDownWidget(
          label: "Engine",
          updateModelList: updateModelList,
          saveSelectedModel: saveSelectedModel,
          getSelectedModel: getSelectedModel,
        )),
    Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
        child: DoubleSliderWidget(
          label: "Quantity",
          min: 1,
          max: 10,
          divisions: 10,
          defaultValue: 1,
          currentValue: quantity,
          fractionDigits: 0,
          onChanged: onQuantityChanged,
        )),
    Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
        child: DoubleSliderWidget(
          label: "Height",
          min: 128,
          max: 1536,
          divisions: 22,
          defaultValue: 512,
          currentValue: height,
          fractionDigits: 0,
          onChanged: onHeightChanged,
        )),
    Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
        child: DoubleSliderWidget(
          label: "Width",
          min: 128,
          max: 1536,
          divisions: 22,
          defaultValue: 512,
          currentValue: width,
          fractionDigits: 0,
          onChanged: onWidthChanged,
        )),
    getSendButton(
      text: sendButtonText,
      sendButtonOnPressed: sendButtonOnPressed,
      loadingResults: loadingResults,
    ),
  ]);
}
