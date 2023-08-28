import 'package:demux_app/app/pages/images/widgets/image_results/cubit/image_results_states.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';


class ImageResultsCubit extends HydratedCubit<ImageResultsState> {
  ImageResultsCubit() : super(ImageResultsReturned([]));

  void showImageResults(List<String> urls){
    emit(ImageResultsReturned(urls));
  }

  @override
  ImageResultsState fromJson(Map<String, dynamic> json) {
    return ImageResultsReturned(json['results'] as List<String>);
  }

  @override
  Map<String, dynamic>? toJson(ImageResultsState state) {
    if (state is ImageResultsReturned) {
      return {'results': state.urls};
    }
    return null;
  }
}

class GenerationImageResultsCubit extends ImageResultsCubit{}
class VariationImageResultsCubit extends ImageResultsCubit{}
class EditImageResultsCubit extends ImageResultsCubit{}
