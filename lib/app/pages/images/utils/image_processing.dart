import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

Future<img.Image?> decodeImageFile(XFile imageFile) async {
  Uint8List imageBytes = await imageFile.readAsBytes();
  img.Image? decodedImage = img.decodeImage(imageBytes);
  return decodedImage;
}

img.Image resizeImage(img.Image image, width, height) {
  img.Image? resizedImage = img.copyResize(image, width: width, height: height);
  return resizedImage;
}

img.Image resizeImageToSquare(img.Image image) {
  int shortestSide = image.width < image.height ? image.width : image.height;
  img.Image? resizedImage =
      img.copyResize(image, width: shortestSide, height: shortestSide);
  return resizedImage;
}

Uint8List encodePngImage(img.Image image) {
  return img.encodePng(image);
}

Future<Uint8List> processImageFile(
  XFile imageFile, {
  bool resize = true,
  bool compress = true,
}) async {
  img.Image? decodedImage = await decodeImageFile(imageFile);
  if (decodedImage == null) {
    throw Exception('Failed to decode image file');
  }
  decodedImage = decodedImage.convert(numChannels: 4);

  if (resize) {
    if (decodedImage.width != decodedImage.height) {
      decodedImage = resizeImageToSquare(decodedImage);
    }
  }

  Uint8List pngBytes = encodePngImage(decodedImage);

  if (compress) {
    int imageSize = pngBytes.lengthInBytes;
    double imageSizeInMB = imageSize / 1048576.0;
    double maxImageSizeInMB = 4.0;

    double resizeRatio;
    int height;
    int width;
    if (imageSizeInMB > maxImageSizeInMB) {
      resizeRatio = (maxImageSizeInMB / imageSizeInMB);
      height = (resizeRatio * decodedImage.height).floor();
      width = height;
      decodedImage = resizeImage(decodedImage, width, height);
      pngBytes = encodePngImage(decodedImage);
    }
    return pngBytes;
  }

  return pngBytes;
}

Future<XFile?> pickImage(ImageSource source) async {
  ImagePicker imagePicker = ImagePicker();
  XFile? imageFile = await imagePicker.pickImage(source: source);
  return imageFile;
}
