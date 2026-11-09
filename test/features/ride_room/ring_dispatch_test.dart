import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/features/ride_room/data/models/ride_models.dart';
import 'package:driver_app/features/ride_room/data/models/ride_taken_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ride:incoming payload', () {
    // The exact field list the backend sends under ring dispatch.
    final Map<String, dynamic> payload = <String, dynamic>{
      'rideId': '68c1f0',
      'pickupPoint': <String, dynamic>{
        'placeName': 'Brickell City Centre',
        'location': <String, dynamic>{
          'type': 'Point',
          'coordinates': <double>[-80.1918, 25.7617],
        },
      },
      'dropOffPoint': <String, dynamic>{
        'placeName': 'Miami International Airport',
        'location': <String, dynamic>{
          'type': 'Point',
          'coordinates': <double>[-80.2870, 25.7959],
        },
      },
      'rideType': 'economy',
      'specialRequest': 'Dos maletas',
      'rideDistance': 8.4,
      'averageTime': 18,
      'paymentMethod': 'attached_card',
      'rideFare': 24.50,
      'driverFare': 28.00,
      'user': <String, dynamic>{
        'id': '68b0',
        'firstName': 'Ana',
        'lastName': 'Pérez',
        'profilePicture': 'https://example.test/ana.png',
        'rating': 4.8,
        'reviews': 32,
      },
      'dispatch': <String, dynamic>{'ring': 2, 'radiusMiles': 2},
    };

    test('reads the ride id from rideId', () {
      expect(RideModel.fromJson(payload).id, '68c1f0');
    });

    test('keeps driverFare apart from the passenger fare', () {
      final RideModel ride = RideModel.fromJson(payload);
      expect(ride.rideFare, 24.50);
      expect(ride.driverFare, 28.00);
      expect(ride.payoutFare, 28.00);
    });

    test('a free ride still pays the driver', () {
      final RideModel ride = RideModel.fromJson(<String, dynamic>{
        ...payload,
        'rideFare': 0,
      });
      expect(ride.rideFare, 0);
      expect(ride.payoutFare, 28.00);
    });

    test('falls back to the ride fare when driverFare is absent', () {
      final Map<String, dynamic> withoutDriverFare = Map<String, dynamic>.from(
        payload,
      )..remove('driverFare');
      expect(RideModel.fromJson(withoutDriverFare).payoutFare, 24.50);
    });

    test('reads the dispatch ring', () {
      final RideModel ride = RideModel.fromJson(payload);
      expect(ride.dispatch?.ring, 2);
      expect(ride.dispatch?.radiusMiles, 2);
    });

    test('has no dispatch when the backend does not send one', () {
      final Map<String, dynamic> withoutDispatch = Map<String, dynamic>.from(
        payload,
      )..remove('dispatch');
      expect(RideModel.fromJson(withoutDispatch).dispatch, isNull);
    });

    test('reads dropOffPoint as the requested destination', () {
      expect(
        RideModel.fromJson(payload).dropOffPointRequested?.placeName,
        'Miami International Airport',
      );
    });

    test('leaves absent passenger fields empty instead of "null"', () {
      final RideModel ride = RideModel.fromJson(payload);
      expect(ride.user?.phone, '');
      expect(ride.user?.id, '68b0');
    });
  });

  group('ride:request:taken payload', () {
    test('carries the ride id, the reason and the fresh queue', () {
      final RideTakenModel taken = RideTakenModel.fromJson(<String, dynamic>{
        'rideId': '68c1f0',
        'reason': 'RIDE_ALREADY_TAKEN',
        'availableRides': <Map<String, dynamic>>[
          <String, dynamic>{'_id': 'other-ride', 'rideStatus': 'requested'},
        ],
      });

      expect(taken.rideId, '68c1f0');
      expect(taken.normalizedReason, 'RIDE_ALREADY_TAKEN');
      expect(taken.availableRides, hasLength(1));
      expect(taken.availableRides!.single.id, 'other-ride');
    });

    test('an empty queue is a real answer, not a missing one', () {
      final RideTakenModel taken = RideTakenModel.fromJson(<String, dynamic>{
        'rideId': '68c1f0',
        'availableRides': <dynamic>[],
      });

      expect(taken.availableRides, isEmpty);
      expect(taken.availableRides, isNotNull);
    });

    test('a missing queue stays null so the local list is only pruned', () {
      final RideTakenModel taken = RideTakenModel.fromJson(<String, dynamic>{
        'rideId': '68c1f0',
        'reason': 'RIDE_ALREADY_TAKEN',
      });

      expect(taken.availableRides, isNull);
    });
  });

  group('accept ack rejection', () {
    test('the three losing-the-race codes are not errors', () {
      for (final String code in <String>[
        'RIDE_ALREADY_TAKEN',
        'UNABLE_TO_ACCEPT_RIDE',
        'ASSIGNMENT_IN_PROGRESS',
      ]) {
        final failure = SocketAckFailure(
          message: 'Ese viaje ya fue tomado',
          code: code,
        );
        expect(failure.isRideTaken, isTrue, reason: code);
        expect(failure.isRideExpired, isFalse, reason: code);
      }
    });

    test('recognises the code when it only comes in the message', () {
      const failure = SocketAckFailure(message: 'RIDE_ALREADY_TAKEN');
      expect(failure.isRideTaken, isTrue);
    });

    test('a real rejection is still a real rejection', () {
      const failure = SocketAckFailure(
        message: 'You already have a ride',
        code: 'DRIVER_ALREADY_ON_RIDE',
      );
      expect(failure.isRideTaken, isFalse);
      expect(failure.isRideExpired, isFalse);
    });

    test('an expired request is told apart from a lost race', () {
      const failure = SocketAckFailure(
        message: 'Ride expired',
        code: 'RIDE_EXPIRED',
      );
      expect(failure.isRideExpired, isTrue);
      expect(failure.isRideTaken, isFalse);
    });
  });
}
