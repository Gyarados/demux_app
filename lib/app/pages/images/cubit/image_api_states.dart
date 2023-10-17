sealed class ImageApiState {
  final String? prompt;
  final List<String> urls;
  ImageApiState(this.urls, {this.prompt});
}

class ImageApiRequested extends ImageApiState {
  ImageApiRequested(super.urls, {super.prompt});
}
