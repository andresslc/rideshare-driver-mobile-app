class DriverLocationParams {
  final double latitude;
  final double longitude;
  final String? eta;

  const DriverLocationParams({
    required this.latitude,
    required this.longitude,
    this.eta,
  });

  Map<String, dynamic> toJson() {
    return {
      "location": {
        "type": "Point",
        "coordinates": [longitude, latitude],
      },
      if (eta != null) "eta": eta,
    };
  }
}
