import 'package:driver_app/main_common.dart';
import 'core/config/app_config.dart';
import 'core/constants/constants_data.dart';

void main() => mainCommon(
  config: AppConfig(
    appName: 'Driver App Dev',
    baseUrl: remoteConfigModel.baseUrlDev,
    flavor: Flavor.dev,
  ),
);
