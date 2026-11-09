
import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/features/settings/domain/repositories/change_language_reposiotry.dart';
import 'package:fpdart/fpdart.dart';

class ChangeLanguageUseCase {
  final ChangeLanguageRepository repository;

  ChangeLanguageUseCase(this.repository);

  Future<Either<Failure, String>> call(String languageCode) async {
    return await repository.changeLanguage(languageCode: languageCode);
  }
}
