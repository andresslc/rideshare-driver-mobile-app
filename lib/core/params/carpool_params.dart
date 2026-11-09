class CarpoolRideParams {
  final String startingPointName;
  final List<double> startingPointCoordinates;
  final String destinationName;
  final List<double> destinationCoordinates;
  final List<RoutePoint> routes;
  final double avgTime;
  final double distance;
  final int maxPassengers;
  final double farePerSeat;
  final DateTime graceTime;

  CarpoolRideParams({
    required this.startingPointName,
    required this.startingPointCoordinates,
    required this.destinationName,
    required this.destinationCoordinates,
    required this.routes,
    required this.avgTime,
    required this.distance,
    required this.maxPassengers,
    required this.farePerSeat,
    required this.graceTime,
  });

  factory CarpoolRideParams.fromJson(Map<String, dynamic> json) {
    return CarpoolRideParams(
      startingPointName: json['startingPoint']['placeName'] as String,
      startingPointCoordinates: List<double>.from(
        json['startingPoint']['location']['coordinates'].map((c) => c as double),
      ),
      destinationName: json['destination']['placeName'] as String,
      destinationCoordinates: List<double>.from(
        json['destination']['location']['coordinates'].map((c) => c as double),
      ),
      routes: (json['routes'] as List)
          .map((r) => RoutePoint.fromJson(r as Map<String, dynamic>))
          .toList(),
      avgTime: (json['avgTime'] as num?)?.toDouble() ?? 0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      maxPassengers: json['maxPassengers'] as int,
      farePerSeat: (json['farePerSeat'] as num).toDouble(),
      graceTime: DateTime.parse(json['graceTime'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startingPoint': {
        'placeName': startingPointName,
        'location': {
          'type': 'Point',
          'coordinates': startingPointCoordinates,
        },
      },
      'destination': {
        'placeName': destinationName,
        'location': {
          'type': 'Point',
          'coordinates': destinationCoordinates,
        },
      },
      'routes': routes.map((e) => e.toJson()).toList(),
      'avgTime': avgTime,
      'distance': distance,
      'maxPassengers': maxPassengers,
      'farePerSeat': farePerSeat,
      'graceTime': graceTime.toUtc().toIso8601String(),
    };
  }
}

class RoutePoint {
  final String placeName;
  final List<double> coordinates;
  final int order;

  RoutePoint({
    required this.placeName,
    required this.coordinates,
    required this.order,
  });

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      placeName: json['placeName'] as String,
      coordinates: List<double>.from(
        json['location']['coordinates'].map((c) => c as double),
      ),
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeName': placeName,
      'location': {
        'type': 'Point',
        'coordinates': coordinates,
      },
      'order': order,
    };
  }
}

// For accepting/rejecting a booking
class BookingActionRequestParams {
  final String bookingId;
  final String action; 

  BookingActionRequestParams({
    required this.bookingId,
    required this.action,
  });

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'action': action,
      };
}

// For sending OTP to confirm booking
class BookingOtpRequestParams {
  final String bookingId;
  final String otp;

  BookingOtpRequestParams({
    required this.bookingId,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'otp': otp,
      };
}

class CarpoolArriveRequestParams {
  final String routeStopId;
  final String carpoolId;

  CarpoolArriveRequestParams({
    required this.routeStopId,
    required this.carpoolId,
  });

  Map<String, dynamic> toJson() => {
        'routeStopId': routeStopId,
        'carpoolId': carpoolId,
      };
}
