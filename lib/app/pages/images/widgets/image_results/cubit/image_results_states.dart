sealed class ImageResultsState {
  final List<String> urls;
  ImageResultsState(this.urls);
}

class ImageResultsReturned extends ImageResultsState {
  ImageResultsReturned(super.urls);
}
