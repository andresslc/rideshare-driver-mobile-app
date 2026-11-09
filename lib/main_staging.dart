import 'package:driver_app/core/config/app_config.dart';
import 'package:driver_app/core/constants/constants_data.dart';
import 'package:driver_app/main_common.dart';

void main() => mainCommon(
  config: AppConfig(
    appName: 'Driver App Staging',
    baseUrl: remoteConfigModel.baseUrlStaging,
    flavor: Flavor.staging,
  ),
);
