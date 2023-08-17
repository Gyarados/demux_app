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
    return Stack(
      children: [
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
        Align(
          alignment: Alignment(1, 0),
          child: IconButton(
            onPressed: loadingResults ? null : removeSelectedImage,
            icon: Icon(
              Icons.close,
              color: Colors.red,
            ),
          ),
        ),
        Align(
          alignment: Alignment(0.8, 0),
          child: GestureDetector(
            onTap: loadingResults ? null : removeLastSelectedPoint,
            onLongPress: loadingResults
                ? null
                : () {
                    setState(() {
                      timer =
                          Timer.periodic(Duration(milliseconds: 25), (timer) {
                        removeLastSelectedPoint();
                      });
                    });
                  },
            onLongPressEnd: (_) {
              setState(() {
                print("up");
                timer?.cancel();
              });
            },
            // style: TextButton.styleFrom(backgroundColor: Colors.transparent),
            child: Icon(
              Icons.undo_rounded,
              color: Colors.black,
            ),
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
}
