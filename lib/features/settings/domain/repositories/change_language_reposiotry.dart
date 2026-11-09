

import 'package:driver_app/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';

abstract class ChangeLanguageRepository {
  Future<Either<Failure, String>> changeLanguage({
    required String languageCode,
  });
}
