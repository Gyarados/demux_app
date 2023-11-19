import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class SelectedCircle {
  Offset center;
  double radius;

  SelectedCircle({required this.center, required this.radius});
}

class EditAreaPainter extends CustomPainter {
  ui.Image? image;
  List<SelectedCircle> points = [];
  Size? lastPaintSize;

  final Paint selectionPaint = Paint()
    ..color = Colors.blueGrey.withAlpha(200)
    ..style = PaintingStyle.fill;

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  void updatePoints(SelectedCircle offset) {
    points.add(offset);
  }

  Future<void> updateImage(Uint8List imageBytes) async {
    image = await loadImage(imageBytes);
  }

  void removeImage() {
    image = null;
  }

  void removeAllPoints() {
    points.clear();
  }

  void removeLastPoint() {
    if (points.isNotEmpty) {
      points.removeLast();
    }
  }

  // void updateRadius(double newRadius){
  //   radius = newRadius;
  // }

  void reset() {
    removeImage();
    removeAllPoints();
  }

  Future<Uint8List> exportMask() async {
    if (lastPaintSize == null) {
      throw Exception("Mask not available");
    }

    final recorder = ui.PictureRecorder();
    final offscreenCanvas = Canvas(
        recorder,
        Rect.fromPoints(const Offset(0, 0),
            Offset(image!.width.toDouble(), image!.height.toDouble())));

    // Calculate the scale factors
    final scaleX = image!.width / lastPaintSize!.width;
    final scaleY = image!.height / lastPaintSize!.height;

    // Scale the canvas
    offscreenCanvas.scale(scaleX, scaleY);

    // Draw the scaled content
    _drawMask(offscreenCanvas);

    final picture = recorder.endRecording();
    final img = await picture.toImage(image!.width, image!.height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  void _drawMask(Canvas canvas) {
    // First draw an opaque background color
    canvas.drawRect(
        Rect.fromPoints(
            const Offset(0, 0), Offset(lastPaintSize!.width, lastPaintSize!.height)),
        Paint()..color = Colors.green);

    final transparentCirclePaint = Paint()
      ..color = Colors.white
      ..blendMode = BlendMode.dstOut
      ..style = PaintingStyle.fill;

    for (SelectedCircle selectedCircle in points) {
      canvas.drawCircle(
          selectedCircle.center, selectedCircle.radius, transparentCirclePaint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;
    lastPaintSize = size;

    double widthScale = size.width / image!.width;
    double heightScale = size.height / image!.height;
    double scale = min(widthScale, heightScale);

    double offsetX = (size.width - image!.width * scale) / 2;
    double offsetY = (size.height - image!.height * scale) / 2;

    canvas.drawImageRect(
        image!,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
        Rect.fromLTWH(
            offsetX, offsetY, image!.width * scale, image!.height * scale),
        Paint());

    final recorder = ui.PictureRecorder();
    final offscreenCanvas = Canvas(recorder,
        Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)));

    // Drawing the circles onto the offscreen buffer with fully opaque colors
    final opaqueCirclePaint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.fill;

    for (SelectedCircle selectedCircle in points) {
      offscreenCanvas.drawCircle(
          selectedCircle.center, selectedCircle.radius, opaqueCirclePaint);
    }

    final picture = recorder.endRecording();

    // Set the clipping region for the main canvas
    canvas.clipRect(Rect.fromLTWH(
        offsetX, offsetY, image!.width * scale, image!.height * scale));

    canvas.saveLayer(
        Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)),
        selectionPaint);
    canvas.drawPicture(picture);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
