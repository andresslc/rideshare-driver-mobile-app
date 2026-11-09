class ServerException implements Exception {
  String? message;

  ServerException(this.message);
}

class InvalidTokenException implements Exception {
  final String message;
  InvalidTokenException(this.message);
}

class CacheException implements Exception {}
