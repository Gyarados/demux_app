sealed class ImageResultsState {
  final List<String> urls;
  ImageResultsState(this.urls);
}

class ImageResultsReturned extends ImageResultsState {
  ImageResultsReturned(super.urls);
}

// class ImageResultsDowloading extends ImageResultsState {
//   final int count;
//   final int total;
//   ImageResultsDowloading(super.urls, this.count, this.total);
// }
