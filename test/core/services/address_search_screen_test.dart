import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:driver_app/core/constants/constants_data.dart';
import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/core/location/service_region.dart';
import 'package:driver_app/core/services/address_search_diagnostics.dart';
import 'package:driver_app/core/services/location_service.dart';
import 'package:driver_app/core/services/storage_service.dart';
import 'package:driver_app/core/theme/app_theme.dart';
import 'package:driver_app/features/carpool/domain/entities/carpool_location_entity.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_route_provider.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_socket_provider.dart';
import 'package:driver_app/features/carpool/presentation/screens/create_carpool_screen.dart';
import 'package:driver_app/features/carpool/presentation/states/carpool_socket_states.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/features/ride_room/presentation/states/ride_state.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:driver_app/shared/location_component/location_models/address_details.dart';
import 'package:driver_app/shared/location_component/location_ui/address_search_field.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'address_search_review_test.dart' show flushReview;
import 'address_search_test.dart' show FakeTransport, predictions, details;

class ScreenLocationService extends LocationService {
  final initialPosition = Completer<Position?>();
  final reasons = <String>[];
  final legacyQueries = <String>[];
  int freshLookups = 0, legacyDetails = 0, profileDetails = 0;
  ScreenLocationService(
    StorageService storage,
    Dio dio,
    void Function(Map<String, Object>) observer,
  ) : super(storage: storage, dio: dio, placesObserver: observer);

  @override
  Future<Position?> getCurrentPosition() {
    freshLookups++;
    return initialPosition.future;
  }

  @override
  Future<Position?> getLastKnownPosition() async => null;

  @override
  Future<String?> getAddressFromLatLng(
    double lat,
    double lng, {
    String fallback = 'Unknown location',
    required String reason,
  }) async {
    reasons.add(reason);
    return 'Initial pickup, Orlando';
  }

  @override
  Future<List<Map<String, dynamic>>> getPlaceSuggestions(
    String query, {
    LatLng? origin,
  }) async {
    legacyQueries.add(query);
    return [
      {
        'place_id': 'legacy',
        'description': 'Legacy address',
        'structured_formatting': {'main_text': 'Legacy'},
      },
    ];
  }

  @override
  Future<Position?> getPlaceDetails(String placeId, {String? address}) async {
    legacyDetails++;
    return devicePosition();
  }

  @override
  Future<AddressDetails?> getAddressDetailsFromPlaceId(String placeId) async {
    profileDetails++;
    return AddressDetails(
      latitude: 28.5,
      longitude: -81.4,
      city: 'Orlando',
      state: 'Florida',
      country: 'US',
      zipCode: '',
    );
  }
}

class ScreenCarpoolSocket extends CarpoolSocketNotifier {
  @override
  CarpoolSocketState build() => const CarpoolSocketState();
}

class ScreenRideSocket extends RideRoomProvider {
  @override
  RideSocketState build() => const RideSocketState();
}

Position devicePosition() => Position(
  latitude: 28.5,
  longitude: -81.4,
  timestamp: DateTime(2026),
  accuracy: 1,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

void main() {
  final previousConfig = remoteConfigModel;
  late ScreenLocationService location;
  late StorageService storage;
  late FakeTransport transport;
  late List<Map<String, Object>> events;
  late ProviderContainer container;

  setUp(() async {
    ServiceRegionConfig.setActiveByKey('global');
    remoteConfigModel = previousConfig.copyWith(
      addressSearchV2Enabled: true,
      mapApiKey: 'test-only',
      serviceRegionId: 'global',
    );
    SharedPreferences.setMockInitialValues({});
    storage = StorageService(await SharedPreferences.getInstance());
    transport = FakeTransport();
    events = [];
    location = ScreenLocationService(
      storage,
      Dio()..httpClientAdapter = transport,
      events.add,
    );
    locator.registerSingleton<LocationService>(location);
    locator.registerSingleton<StorageService>(storage);
    container = ProviderContainer(
      overrides: [
        carpoolSocketProvider.overrideWith(ScreenCarpoolSocket.new),
        rideSocketProvider.overrideWith(ScreenRideSocket.new),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await locator.reset();
    remoteConfigModel = previousConfig;
  });

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CreateCarpoolScreen(),
        ),
      ),
    );
    await flushReview(tester);
  }

  Future<void> search(
    WidgetTester tester,
    String input, {
    int field = 1,
    int response = 0,
    String id = 'one',
  }) async {
    await tester.enterText(find.byType(TextField).at(field), input);
    await tester.pump(const Duration(milliseconds: 400));
    await flushReview(tester);
    transport.respond(response, predictions(id));
    await flushReview(tester);
  }

  testWidgets(
    'CreateCarpoolScreen disposal abandons a live interaction without ref errors',
    (tester) async {
      await open(tester);
      await search(tester, 'sample');
      await tester.pumpWidget(const SizedBox());
      await flushReview(tester);
      expect(tester.takeException(), isNull);
      expect(
        events.where((e) => e['event'] == 'interaction_abandoned'),
        hasLength(1),
      );
    },
  );

  testWidgets(
    'late GPS fills unedited pickup and preserves live dropoff token and selection',
    (tester) async {
      await open(tester);
      await search(tester, 'sample');
      final token = transport.requests.single.data['sessionToken'];
      location.initialPosition.complete(devicePosition());
      await flushReview(tester);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'Initial pickup, Orlando',
      );
      expect(container.read(carpoolRouteProvider).searchResults, hasLength(1));
      expect(
        events.where((e) => e['event'] == 'interaction_abandoned'),
        isEmpty,
      );
      await tester.tap(find.text('Sample business'));
      await flushReview(tester);
      expect(transport.requests[1].queryParameters['sessionToken'], token);
      transport.respond(1, details('one'));
      await flushReview(tester);
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
        '123 Sample Road',
      );
      expect(location.reasons, ['initial_position']);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpWidget(const SizedBox());
      await flushReview(tester);
    },
  );

  testWidgets('late GPS preserves pending dropoff Details and its token', (
    tester,
  ) async {
    await open(tester);
    await search(tester, 'sample');
    final token = transport.requests.single.data['sessionToken'];
    await tester.tap(find.text('Sample business'));
    await flushReview(tester);
    location.initialPosition.complete(devicePosition());
    await flushReview(tester);
    expect(transport.requests[1].queryParameters['sessionToken'], token);
    expect(events.where((e) => e['event'] == 'interaction_abandoned'), isEmpty);
    transport.respond(1, details('one'));
    await flushReview(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      '123 Sample Road',
    );
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(const SizedBox());
    await flushReview(tester);
  });

  testWidgets(
    'screen swap moves confirmed values and makes no address requests',
    (tester) async {
      location.initialPosition.complete(null);
      await open(tester);
      await search(tester, 'pickup', field: 0);
      await tester.tap(find.text('Sample business'));
      await flushReview(tester);
      transport.respond(1, details('one'));
      await flushReview(tester);
      await search(tester, 'dropoff', response: 2, id: 'two');
      await tester.tap(find.text('Sample business'));
      await flushReview(tester);
      final second = details('two')..['formattedAddress'] = 'Second address';
      transport.respond(3, second);
      await flushReview(tester);
      await tester.tap(find.byTooltip('Swap locations'));
      await flushReview(tester);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'Second address',
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
        '123 Sample Road',
      );
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).onPressed,
        isNotNull,
      );
      expect(transport.requests, hasLength(4));
      expect(location.reasons, isEmpty);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpWidget(const SizedBox());
      await flushReview(tester);
    },
  );

  testWidgets('late GPS cannot replace edited pickup', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField).first, 'a');
    location.initialPosition.complete(devicePosition());
    await flushReview(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'a',
    );
    expect(location.reasons, isEmpty);
    await tester.pumpWidget(const SizedBox());
    await flushReview(tester);
  });

  testWidgets(
    'screen double tap resolves once and edit during Details discards completion',
    (tester) async {
      await open(tester);
      await search(tester, 'sample');
      await tester.tap(find.text('Sample business'));
      await tester.tap(find.text('Sample business'));
      await flushReview(tester);
      expect(transport.requests, hasLength(2));
      await tester.enterText(find.byType(TextField).at(1), 'edited');
      transport.respond(1, details('one'));
      await flushReview(tester);
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
        'edited',
      );
      expect(container.read(carpoolRouteProvider).recents, isEmpty);
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).onPressed,
        isNull,
      );
      await tester.pumpWidget(const SizedBox());
      await flushReview(tester);
    },
  );

  testWidgets(
    'legacy carpool sends one character after 300ms and one legacy Details',
    (tester) async {
      remoteConfigModel = remoteConfigModel.copyWith(
        addressSearchV2Enabled: false,
      );
      location.initialPosition.complete(null);
      await open(tester);
      await tester.enterText(find.byType(TextField).at(1), 'a');
      await tester.pump(const Duration(milliseconds: 299));
      expect(location.legacyQueries, isEmpty);
      await tester.pump(const Duration(milliseconds: 1));
      await flushReview(tester);
      expect(location.legacyQueries, ['a']);
      expect(location.freshLookups, 2);
      await tester.tap(find.text('Legacy'));
      await flushReview(tester);
      expect(location.legacyDetails, 1);
      expect(transport.requests, isEmpty);
      await tester.pumpWidget(const SizedBox());
      await flushReview(tester);
    },
  );

  testWidgets(
    'legacy profile dropdown typing leaves parent metadata and controller unchanged',
    (tester) async {
      remoteConfigModel = remoteConfigModel.copyWith(
        addressSearchV2Enabled: false,
      );
      final text = TextEditingController(text: 'Confirmed address');
      var clears = 0, callbacks = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: AddressSearchField(
                controller: text,
                locationService: location,
                onAddressCleared: () => clears++,
                onDetailsFetched: (_) => callbacks++,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Confirmed address'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump(const Duration(milliseconds: 400));
      await flushReview(tester);
      expect(clears, 0);
      expect(text.text, 'Confirmed address');
      expect(location.legacyQueries, ['a']);
      expect(location.freshLookups, 0);
      await tester.tap(find.text('Legacy address'));
      await flushReview(tester);
      expect(location.profileDetails, 1);
      expect(location.legacyDetails, 0);
      expect(callbacks, 1);
      await tester.pumpWidget(const SizedBox());
      text.dispose();
      await flushReview(tester);
    },
  );

  test(
    'old (0,0) recents are hidden and never applied; single zero remains valid',
    () async {
      CarpoolLocationEntity recent(double lat, double lng) =>
          CarpoolLocationEntity(
            id: 'legacy',
            name: 'Saved',
            address: 'Saved address',
            latitude: lat,
            longitude: lng,
            timestamp: DateTime(2026),
          );
      await storage.setString(
        'recent_carpool_locations',
        jsonEncode([recent(0, 0).toJson(), recent(0, -80.19).toJson()]),
      );
      final notifier = container.read(carpoolRouteProvider.notifier);
      await notifier.initialize();
      expect(container.read(carpoolRouteProvider).recents, hasLength(1));
      expect(await notifier.resolveSelectedLocation(recent(0, 0)), isNull);
      expect(
        await notifier.resolveSelectedLocation(recent(0, -80.19)),
        isNotNull,
      );
      expect(transport.requests, isEmpty);
    },
  );

  test(
    'Driver diagnostics includes existing version/build and drops sensitive fields',
    () {
      final diagnostics = AddressSearchDiagnostics()
        ..version = 'test-version'
        ..build = 'test-build';
      final safe = diagnostics.sanitize({
        'event': 'request_started',
        'reason': 'initial_position',
        'query': 'private-query',
        'address': 'private-address',
        'latitude': 28.5,
        'longitude': -81.4,
        'apiKey': 'private-key',
        'sessionToken': 'private-token',
      });
      expect(safe, {
        'app_version': 'test-version',
        'build_number': 'test-build',
        'event': 'request_started',
        'reason': 'initial_position',
      });
    },
  );
}
