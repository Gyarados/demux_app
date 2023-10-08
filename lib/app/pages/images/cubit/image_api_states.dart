sealed class ImageApiState {
  final List<String> urls;
  ImageApiState(this.urls);
}

class ImageApiRequested extends ImageApiState {
  ImageApiRequested(super.urls);
}
