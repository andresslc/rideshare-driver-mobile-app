import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';

enum RideBottomSheetType {
  addStops,
  rideStartTimeAndSeat,
  searchCarpoolRide,
  carpoolRequest,
  rideProgress,
}

class RideSheetConstants {
  static const List<RideBottomSheetType> flow = [
    RideBottomSheetType.addStops,
    RideBottomSheetType.rideStartTimeAndSeat,
    RideBottomSheetType.searchCarpoolRide,
    RideBottomSheetType.carpoolRequest,
    RideBottomSheetType.rideProgress,
  ];

  static String title(RideBottomSheetType type, BuildContext context) {
    switch (type) {
      case RideBottomSheetType.addStops:
        return context.l10n.add_stops;
      case RideBottomSheetType.rideStartTimeAndSeat:
        return context.l10n.rideStartTimeSeats;
      case RideBottomSheetType.searchCarpoolRide:
        return context.l10n.search_carpool_ride;
      case RideBottomSheetType.carpoolRequest:
        return context.l10n.list_of_request;
      case RideBottomSheetType.rideProgress:
        return context.l10n.ride_progress;
    }
  }
}

//old way
  // static const Map<RideBottomSheetType, String> titles = {
  //   RideBottomSheetType.addStops: "Add Stops",
  //   RideBottomSheetType.rideStartTimeAndSeat: "Ride Start Time and Seats",
  //   RideBottomSheetType.searchCarpoolRide: "Search Carpool Ride",
  //   RideBottomSheetType.carpoolRequest: "List of Requests",
  //   RideBottomSheetType.rideProgress: "Ride Progress",
  // };
//e


