import '../../../../core/services/places_search_service.dart';

class CarpoolLocationEntity {
  final ResolvedPlace? resolvedPlace;
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const CarpoolLocationEntity({
    this.resolvedPlace,
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
  };

  factory CarpoolLocationEntity.fromJson(Map<String, dynamic> json) =>
      CarpoolLocationEntity(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        address: (json['address'] ?? '').toString(),
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        timestamp:
            DateTime.tryParse((json['timestamp'] ?? '').toString()) ??
            DateTime.now(),
      );
}
