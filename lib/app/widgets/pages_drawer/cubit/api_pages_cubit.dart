import 'package:demux_app/app/widgets/pages_drawer/cubit/page_routes.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ApiPagesCubit extends HydratedCubit<DemuxPageRoute> {
  ApiPagesCubit() : super(DemuxPageRoute.openAiChatCompletion);

  void navigateTo(DemuxPageRoute route) {
    emit(route);
  }

  DemuxPageRoute getCurrentPageRoute() {
    return state;
  }

  bool isPageFromOpenAi(DemuxPageRoute page) {
    return DemuxPageRoute.openAiPages.contains(page);
  }

  bool isPageFromStabilityAi(DemuxPageRoute page) {
    return DemuxPageRoute.stabilityAiPages.contains(page);
  }

  @override
  DemuxPageRoute fromJson(Map<String, dynamic> json) {
    String path = json["path"];

    return DemuxPageRoute.getRouteFromPath(path);
  }

  @override
  Map<String, dynamic>? toJson(DemuxPageRoute state) {
    return {"path": state.path};
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print("error in drawer cubit conversion:");
    print(error);
    super.onError(error, stackTrace);
  }
}
