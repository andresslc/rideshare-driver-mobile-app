import 'package:driver_app/features/carpool/domain/entities/carpool_entity.dart';

class CarpoolIncomingRequestModel extends CarpoolIncomingRequestEntity {
  const CarpoolIncomingRequestModel({
    required super.bookingId,
    required super.passenger,
    required super.pickupStop,
    required super.dropOffStop,
    required super.requiredSeats,
    required super.fareCharged,
    super.distance,
  });

  factory CarpoolIncomingRequestModel.fromJson(Map<String, dynamic> json) {
    final payload = _extractPayload(json);
    return CarpoolIncomingRequestModel(
      bookingId: _readString(payload, const [
        'bookingId',
        'requestId',
        'id',
        '_id',
      ]),
      passenger: PassengerModel.fromJson(
        _toMap(payload['passenger'] ?? payload['user']),
      ),
      pickupStop: CarpoolStopModel.fromJson(
        _toMap(
          payload['pickupStop'] ??
              payload['pickup'] ??
              payload['pickupPoint'] ??
              payload['startingPoint'],
        ),
      ),
      dropOffStop: CarpoolStopModel.fromJson(
        _toMap(
          payload['dropOffStop'] ??
              payload['dropoff'] ??
              payload['dropOffPointRequested'] ??
              payload['destination'],
        ),
      ),
      requiredSeats: _readInt(payload, const ['requiredSeats', 'seats']),
      fareCharged: _readDouble(payload, const [
        'fareCharged',
        'fare',
        'price',
        'rideFare',
      ]),
      distance: _readDouble(payload, const [
        'distance',
        'totalDistance',
        'rideDistance',
      ]),
    );
  }

  Map<String, dynamic> toJson() {
    final passengerModel = passenger is PassengerModel
        ? passenger as PassengerModel
        : PassengerModel.fromEntity(passenger);
    final pickupStopModel = pickupStop is CarpoolStopModel
        ? pickupStop as CarpoolStopModel
        : CarpoolStopModel.fromEntity(pickupStop);
    final dropOffStopModel = dropOffStop is CarpoolStopModel
        ? dropOffStop as CarpoolStopModel
        : CarpoolStopModel.fromEntity(dropOffStop);

    return {
      "bookingId": bookingId,
      "passenger": passengerModel.toJson(),
      "pickupStop": pickupStopModel.toJson(),
      "dropOffStop": dropOffStopModel.toJson(),
      "requiredSeats": requiredSeats,
      "fareCharged": fareCharged,
      "distance": distance,
    };
  }

  static Map<String, dynamic> _extractPayload(Map<String, dynamic> source) {
    final nested = source['request'] ?? source['data'] ?? source['payload'];
    if (nested is Map<String, dynamic>) {
      return nested;
    }
    return source;
  }
}

class PassengerModel extends PassengerEntity {
  const PassengerModel({
    required super.passengerId,
    required super.firstName,
    required super.lastName,
    required super.image,
    required super.rating,
  });

  factory PassengerModel.fromJson(Map<String, dynamic> json) {
    return PassengerModel(
      passengerId: json['passengerId'] ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      image: json['profilePicture'] ?? '',
      rating: json['rating'] ?? 0,
    );
  }

  factory PassengerModel.fromEntity(PassengerEntity entity) {
    return PassengerModel(
      passengerId: entity.passengerId,
      firstName: entity.firstName,
      lastName: entity.lastName,
      image: entity.image,
      rating: entity.rating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "passengerId": passengerId,
      "firstName": firstName,
      "lastName": lastName,
      "image": image,
      "rating": rating,
    };
  }
}

class CarpoolStopModel extends CarpoolStopEntity {
  const CarpoolStopModel({
    required super.placeName,
    required super.coordinates,
    required super.order,
  });

  factory CarpoolStopModel.fromJson(Map<String, dynamic> json) {
    final rawCoordinates =
        json['location']?['coordinates'] ?? json['coordinates'];
    return CarpoolStopModel(
      placeName: json['placeName'] ?? '',
      coordinates: rawCoordinates is List
          ? rawCoordinates.map((e) => (e as num).toDouble()).toList()
          : <double>[],
      order: _readInt(json, const ['order']),
    );
  }

  factory CarpoolStopModel.fromEntity(CarpoolStopEntity entity) {
    return CarpoolStopModel(
      placeName: entity.placeName,
      coordinates: entity.coordinates,
      order: entity.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "placeName": placeName,
      "location": {"type": "Point", "coordinates": coordinates},
      "order": order,
    };
  }
}

Map<String, dynamic> _toMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return <String, dynamic>{};
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null) {
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
  }
  return '';
}

int _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return 0;
}

double _readDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return 0;
}
