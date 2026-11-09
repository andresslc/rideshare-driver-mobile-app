
import 'package:driver_app/features/settings/domain/usecase/change_language_usecase.dart';
import 'package:driver_app/features/settings/presentation/states/change_language_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/service_locator.dart';

final changeLanguageProvider =
    NotifierProvider<ChangeLanguageProvider, ChangeLanguageState>(
      ChangeLanguageProvider.new,
    );

class ChangeLanguageProvider extends Notifier<ChangeLanguageState> {
  @override
  ChangeLanguageState build() {
    return const ChangeLanguageInitial();
  }

  /// ------------------------------
  /// CHANGE LANGUAGE
  /// ------------------------------
  Future<void> changeLanguage(String languageCode) async {
    state = const ChangeLanguageLoading();

    final result = await locator<ChangeLanguageUseCase>().call(languageCode);

    state = result.fold(
      (failure) => ChangeLanguageError(failure.message),
      (message) => LanguageChanged(message),
    );
  }
}
