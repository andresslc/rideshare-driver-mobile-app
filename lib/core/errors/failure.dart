abstract class Failure {
  final String message;
  final dynamic error;
  const Failure({required this.message, this.error});
}

class ServerFailure extends Failure {
  ServerFailure({required super.message, super.error});
}

class TokenFailure extends Failure {
  TokenFailure({required super.message});
}

class SyntaxFailure extends Failure {
  SyntaxFailure({required super.message});
}

class CacheFailure extends Failure {
  CacheFailure({required super.message});
}

class AgoraFailure extends Failure {
  AgoraFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// Socket ack rejection that carries the backend code alongside the already
/// translated message, so callers can tell an expected outcome (losing the
/// dispatch race) apart from a real error.
class SocketAckFailure extends Failure {
  final String code;

  const SocketAckFailure({required super.message, this.code = ''});

  /// Codes the backend returns when another driver won the ride first.
  static const Set<String> rideTakenCodes = <String>{
    'RIDE_ALREADY_TAKEN',
    'UNABLE_TO_ACCEPT_RIDE',
    'ASSIGNMENT_IN_PROGRESS',
  };

  String get normalizedCode => code.trim().toUpperCase();

  /// True when the driver simply lost the race — an expected result, not an error.
  bool get isRideTaken {
    final String normalized = normalizedCode;
    if (rideTakenCodes.contains(normalized)) return true;
    final String upperMessage = message.trim().toUpperCase();
    return rideTakenCodes.any((code) => upperMessage.contains(code));
  }

  bool get isRideExpired {
    if (normalizedCode == 'RIDE_EXPIRED') return true;
    return message.trim().toUpperCase().contains('RIDE_EXPIRED');
  }
}
