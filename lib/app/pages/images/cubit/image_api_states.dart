sealed class ImageApiState {
  final String? prompt;
  final List<String>? urls;
  final List<String>? b64Strings;
  ImageApiState({this.prompt, this.urls, this.b64Strings});
}

class ImageApiRequested extends ImageApiState {
  ImageApiRequested({super.prompt, super.urls, super.b64Strings});
}
