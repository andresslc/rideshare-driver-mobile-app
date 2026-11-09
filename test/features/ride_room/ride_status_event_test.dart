import 'package:driver_app/core/config/ride_config_model.dart';
import 'package:driver_app/features/ride_room/data/models/ride_models.dart';
import 'package:driver_app/features/ride_room/data/models/ride_response.model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ride:status:update', () {
    // Shape the backend sends now: `rideId` at the envelope, the ride
    // populated, and `driverFare` beside it rather than inside it.
    final Map<String, dynamic> payload = <String, dynamic>{
      'rideId': '68c1f0',
      'type': 'in-progress',
      'ride': <String, dynamic>{
        'id': '68c1f0',
        'status': 'in-progress',
        'fare': 24.5,
        'user': <String, dynamic>{
          'id': '68b0',
          'firstName': 'Ana',
          'lastName': 'Pérez',
        },
      },
      'driverFare': 28.0,
    };

    test('reads the id from ride.id', () {
      expect(RideResponseModel.fromJson(payload).ride?.id, '68c1f0');
    });

    test('reads the status from ride.status', () {
      final RideResponseModel event = RideResponseModel.fromJson(payload);
      expect(event.type, 'in-progress');
      expect(event.ride?.rideStatus, 'in-progress');
    });

    test('reads the fare from ride.fare', () {
      expect(RideResponseModel.fromJson(payload).ride?.rideFare, 24.5);
    });

    test('folds the envelope driverFare onto the ride', () {
      final RideResponseModel event = RideResponseModel.fromJson(payload);
      expect(event.driverFare, 28.0);
      expect(event.ride?.driverFare, 28.0);
      expect(event.ride?.payoutFare, 28.0);
    });

    test('keeps the populated passenger', () {
      expect(RideResponseModel.fromJson(payload).ride?.user?.id, '68b0');
    });

    test('falls back to the envelope rideId when the ride carries none', () {
      final RideResponseModel event = RideResponseModel.fromJson(
        <String, dynamic>{
          'rideId': '68c1f0',
          'type': 'arrived',
          'ride': <String, dynamic>{'status': 'arrived'},
        },
      );
      expect(event.ride?.id, '68c1f0');
    });
  });

  group('dispatch ring', () {
    test('prints radius + distanceUnit, not the raw miles', () {
      final RideModel ride = RideModel.fromJson(<String, dynamic>{
        'rideId': 'r1',
        'dispatch': <String, dynamic>{
          'ring': 2,
          'radiusMiles': 2,
          'radius': 3.2,
          'distanceUnit': 'km',
        },
      });

      expect(ride.dispatch?.ring, 2);
      expect(ride.dispatch?.radiusMiles, 2);
      expect(ride.dispatch?.displayRadius, 3.2);
      expect(ride.dispatch?.distanceUnit, 'km');
    });

    test('falls back to the raw miles on a payload without radius', () {
      final RideModel ride = RideModel.fromJson(<String, dynamic>{
        'rideId': 'r1',
        'dispatch': <String, dynamic>{'ring': 1, 'radiusMiles': 1},
      });

      expect(ride.dispatch?.displayRadius, 1);
      expect(ride.dispatch?.distanceUnit, isNull);
    });
  });

  group('GET /config/ride', () {
    final Map<String, dynamic> payload = <String, dynamic>{
      'data': <String, dynamic>{
        'locale': 'es',
        'distanceUnit': 'mi',
        'dispatch': <String, dynamic>{
          'totalRings': 4,
          'ringTimeoutSeconds': 10,
          'maxSearchSeconds': 40,
          'rings': <Map<String, dynamic>>[
            <String, dynamic>{'ring': 1, 'radiusMiles': 1, 'radius': 1},
            <String, dynamic>{'ring': 4, 'radiusMiles': 5, 'radius': 5},
          ],
        },
        'messages': <String, dynamic>{
          'RIDE_OFFERS_DISABLED': 'Las ofertas de conductores ya no se usan.',
        },
        'updatedAt': '2026-09-17T14:02:11.000Z',
      },
    };

    test('unwraps the data envelope', () {
      final RideConfigModel config = RideConfigModel.fromJson(payload);
      expect(config.locale, 'es');
      expect(config.distanceUnit, 'mi');
      expect(config.dispatch.totalRings, 4);
      expect(config.dispatch.rings, hasLength(2));
      expect(config.dispatch.rings.last.radius, 5);
      expect(config.messages['RIDE_OFFERS_DISABLED'], isNotEmpty);
      expect(config.updatedAt, isNotNull);
    });

    test('a unit change in the panel is what the app prints', () {
      final Map<String, dynamic> inKm = <String, dynamic>{
        'data': <String, dynamic>{
          ...payload['data'] as Map<String, dynamic>,
          'distanceUnit': 'km',
        },
      };
      expect(RideConfigModel.fromJson(inKm).distanceUnit, 'km');
    });

    test('falls back to miles when the unit is missing', () {
      final RideConfigModel config = RideConfigModel.fromJson(<String, dynamic>{
        'data': <String, dynamic>{},
      });
      expect(config.distanceUnit, RideConfigModel.defaultDistanceUnit);
    });

    test('survives a cache round trip', () {
      final RideConfigModel original = RideConfigModel.fromJson(payload);
      final RideConfigModel? restored = RideConfigModel.decode(
        original.encode(),
      );

      expect(restored, isNotNull);
      expect(restored!.distanceUnit, original.distanceUnit);
      expect(restored.dispatch.rings.length, original.dispatch.rings.length);
      expect(restored.messages, original.messages);
    });

    test('a corrupt cache decodes to null instead of throwing', () {
      expect(RideConfigModel.decode('not json'), isNull);
      expect(RideConfigModel.decode(null), isNull);
      expect(RideConfigModel.decode('  '), isNull);
    });
  });
}
