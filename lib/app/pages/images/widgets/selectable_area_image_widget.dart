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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
            child: Row(
              children: [
                SizedBox(
                  width: 8,
                ),
                Expanded(
                    child: Text(
                  "Selected image",
                  textAlign: TextAlign.start,
                )),
                GestureDetector(
                  onTap: loadingResults ? null : removeLastSelectedPoint,
                  onLongPress: loadingResults
                      ? null
                      : () {
                          setState(() {
                            timer = Timer.periodic(Duration(milliseconds: 25),
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
                  child: IconButton(
                    onPressed: null,
                    icon:Icon(
                    Icons.undo_rounded,
                    color: Colors.black,
                  )),
                ),
                IconButton(
                  onPressed: loadingResults ? null : removeAllPoints,
                  icon: Icon(
                    Icons.replay_sharp,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: loadingResults ? null : removeSelectedImage,
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                ),
              ],
            )),
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
      widget.editAreaPainter.updatePoints(point);
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
