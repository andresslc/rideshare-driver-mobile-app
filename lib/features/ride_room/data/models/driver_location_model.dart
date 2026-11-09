import '../../domain/entities/driver_location_entity.dart';

class DriverLocationModel extends DriverLocationEntity {
  const DriverLocationModel({
    required super.driverId,
    required super.longitude,
    required super.latitude,
    required super.timestamp,
  });

  factory DriverLocationModel.fromMap(Map<String, dynamic> map) {
    final List<dynamic> rawCoordinates =
        map['coordinates'] as List<dynamic>? ?? <dynamic>[];
    final List<double> coordinates = rawCoordinates
        .map((item) => (item as num).toDouble())
        .toList();

    return DriverLocationModel(
      driverId: (map['driver'] ?? '').toString(),
      longitude: coordinates.isNotEmpty ? coordinates[0] : 0.0,
      latitude: coordinates.length > 1 ? coordinates[1] : 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        _toInt(map['timestamp']),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driver': driverId,
      'coordinates': [longitude, latitude],
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
