import 'package:demux_app/app/pages/settings/cubit/app_settings_cubit.dart';

class AppSettingsService {
  final AppSettingsCubit _settingsCubit;

  AppSettingsService(this._settingsCubit);

  String get apiKey => _settingsCubit.state.apiKey;
}