import 'dart:async';
import 'dart:typed_data';

import 'package:demux_app/app/pages/images/widgets/edit_area_painter.dart';
import 'package:flutter/material.dart';

class SelectableAreaImage extends StatefulWidget {
  final EditAreaPainter editAreaPainter;
  final Function parentRemoveSelectedImage;
  const SelectableAreaImage(
      this.editAreaPainter, this.parentRemoveSelectedImage,
      {super.key});

  @override
  State<SelectableAreaImage> createState() => _SelectableAreaImageState();
}

class _SelectableAreaImageState extends State<SelectableAreaImage> {
  GlobalKey canvasKey = GlobalKey();
  bool loadingResults = false;
  bool loadingSelectedImage = false;
  Uint8List? selectedImage;
  Timer? timer;
  double sliderValue = 27.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
            child: Column(children: [
              Row(
                children: [
                  const SizedBox(
                    width: 8,
                  ),
                  const Expanded(
                      child: Text(
                    "Selected image",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  GestureDetector(
                    onTap: loadingResults ? null : removeLastSelectedPoint,
                    onLongPress: loadingResults
                        ? null
                        : () {
                            setState(() {
                              timer = Timer.periodic(const Duration(milliseconds: 25),
                                  (timer) {
                                removeLastSelectedPoint();
                              });
                            });
                          },
                    onLongPressEnd: (_) {
                      setState(() {
                        timer?.cancel();
                      });
                    },
                    child: const IconButton(
                        onPressed: null,
                        icon: Icon(
                          Icons.undo_rounded,
                          color: Colors.black,
                        )),
                  ),
                  IconButton(
                    onPressed: loadingResults ? null : removeAllPoints,
                    icon: const Icon(
                      Icons.replay_sharp,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: loadingResults ? null : removeSelectedImage,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(children: [
                    const Text("Selection radius"),
                    SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                            overlayShape: SliderComponentShape.noOverlay,
                            showValueIndicator:
                                ShowValueIndicator.onlyForContinuous),
                        child: Slider(
                          min: 5,
                          max: 50,
                          label: sliderValue.toStringAsFixed(2),
                          value: sliderValue,
                          onChanged: (value) {
                            setState(() {
                              sliderValue = value;
                            });
                          },
                        )),
                    const Text("Select the area which will be replaced."),
                  ])),
            ])),
        GestureDetector(
          onPanDown: updateSelectionArea,
          onPanUpdate: updateSelectionArea,
          // To cancel the ListView vertical scroll:
          onVerticalDragUpdate: updateSelectionArea,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double width = constraints.maxWidth;
              return Container(
                width: width,
                height: width, // To ensure the square shape
                child: CustomPaint(
                  key: canvasKey,
                  painter: widget.editAreaPainter,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void updateSelectionArea(detailData) {
    setState(() {
      Offset point = detailData.localPosition;
      SelectedCircle selectedCircle =
          SelectedCircle(center: point, radius: sliderValue);
      widget.editAreaPainter.updatePoints(selectedCircle);
      canvasKey.currentContext!.findRenderObject()!.markNeedsPaint();
    });
  }

  void removeSelectedImage() {
    setState(() {
      widget.parentRemoveSelectedImage();
      selectedImage = null;
      widget.editAreaPainter.reset();
      canvasKey.currentContext!.findRenderObject()!.markNeedsPaint();
    });
  }

  void removeLastSelectedPoint() {
    setState(() {
      widget.editAreaPainter.removeLastPoint();
      canvasKey.currentContext!.findRenderObject()!.markNeedsPaint();
    });
  }

  void removeAllPoints() {
    setState(() {
      widget.editAreaPainter.removeAllPoints();
      canvasKey.currentContext!.findRenderObject()!.markNeedsPaint();
    });
  }
}
