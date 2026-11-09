import 'package:dio/dio.dart';
import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/core/services/address_search_controller.dart';
import 'package:driver_app/core/services/location_service.dart';
import 'package:driver_app/core/services/places_search_service.dart';
import 'package:driver_app/core/services/storage_service.dart';
import 'package:driver_app/core/theme/app_theme.dart';
import 'package:driver_app/features/carpool/domain/entities/carpool_location_entity.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_route_provider.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:driver_app/shared/location_component/location_models/address_details.dart';
import 'package:driver_app/shared/location_component/location_ui/address_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'address_search_test.dart' show FakeTransport, predictions, details;

class TestLocationService extends LocationService {
  TestLocationService(StorageService storage, Dio dio)
    : super(storage: storage, dio: dio);
  @override
  AddressSearchController createAddressSearch({
    required void Function() onChanged,
    LatLng? Function()? origin,
    bool legacyDeviceOrigin = true,
    void Function(LatLng)? onLegacyOriginResolved,
    Duration legacyDebounce = const Duration(milliseconds: 300),
  }) => AddressSearchController(
    service: placesSearch,
    contextProvider: () =>
        const PlacesContext(enabled: true, apiKey: 'test-only', language: 'en'),
    onChanged: onChanged,
  );
}

void main() {
  late FakeTransport transport;
  late TestLocationService locationService;
  late StorageService storage;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService(await SharedPreferences.getInstance());
    transport = FakeTransport();
    locationService = TestLocationService(
      storage,
      Dio()..httpClientAdapter = transport,
    );
  });
  tearDown(() async => locator.reset());
  Future<void> flush(WidgetTester tester) async {
    await tester.runAsync(() async {
      await Future<void>.delayed(Duration.zero);
    });
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
  }

  testWidgets(
    'carpool field switching rejects Details and recent selection accepts valid zero coordinates without a call',
    (tester) async {
      locator.registerSingleton<LocationService>(locationService);
      locator.registerSingleton<StorageService>(storage);
      final container = ProviderContainer();
      final notifier = container.read(carpoolRouteProvider.notifier);
      notifier.onSearchQueryChanged('sample', field: 'pickup');
      await tester.pump(const Duration(milliseconds: 400));
      await flush(tester);
      transport.respond(0, predictions('one'));
      await flush(tester);
      final chosen = container.read(carpoolRouteProvider).searchResults.single;
      final first = notifier.resolveSelectedLocation(chosen),
          second = notifier.resolveSelectedLocation(chosen);
      await flush(tester);
      expect(transport.requests, hasLength(2));
      notifier.activateField('dropoff');
      transport.respond(1, details('one'));
      await flush(tester);
      expect(await first, isNull);
      expect(await second, isNull);
      final recent = CarpoolLocationEntity(
        id: 'recent',
        name: 'Saved',
        address: 'Saved address',
        latitude: 0,
        longitude: 10,
        timestamp: DateTime(2026),
      );
      expect(await notifier.resolveSelectedLocation(recent), same(recent));
      expect(transport.requests, hasLength(2));
      await notifier.saveRecentLocation(recent);
      expect(container.read(carpoolRouteProvider).recents, hasLength(1));
      container.dispose();
    },
  );

  testWidgets(
    'carpool Details failure never publishes artificial coordinates or falls back to legacy',
    (tester) async {
      locator.registerSingleton<LocationService>(locationService);
      locator.registerSingleton<StorageService>(storage);
      final container = ProviderContainer();
      final notifier = container.read(carpoolRouteProvider.notifier);
      notifier.onSearchQueryChanged('sample', field: 'pickup');
      await tester.pump(const Duration(milliseconds: 400));
      await flush(tester);
      transport.respond(0, predictions('one'));
      await flush(tester);
      final selected = notifier.resolveSelectedLocation(
        container.read(carpoolRouteProvider).searchResults.single,
      );
      await flush(tester);
      transport.respond(1, {}, status: 503);
      await flush(tester);
      expect(await selected, isNull);
      expect(
        container.read(carpoolRouteProvider).searchError,
        PlacesFailure.network,
      );
      expect(transport.requests, hasLength(2));
      expect(container.read(carpoolRouteProvider).recents, isEmpty);
      final retry = notifier.retrySelection();
      await flush(tester);
      expect(
        transport.requests.last.queryParameters.containsKey('sessionToken'),
        isFalse,
      );
      transport.respond(2, details('one'));
      await flush(tester);
      expect((await retry)!.latitude, 0);
      container.dispose();
    },
  );

  Future<void> openField(
    WidgetTester tester,
    TextEditingController text,
    void Function(AddressDetails) onResolved,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: AddressSearchField(
              controller: text,
              locationService: locationService,
              onDetailsFetched: onResolved,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Street Address'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'sample');
    await tester.pump(const Duration(milliseconds: 400));
    await flush(tester);
    transport.respond(0, predictions('one'));
    await flush(tester);
  }

  testWidgets(
    'profile selection applies one callback with street, city and validated coordinates',
    (tester) async {
      final text = TextEditingController();
      final applied = <AddressDetails>[];
      await openField(tester, text, applied.add);
      await tester.tap(find.text('Sample business, sample street'));
      await flush(tester);
      transport.respond(1, details('one'));
      await flush(tester);
      expect(transport.requests, hasLength(2));
      expect(applied, hasLength(1));
      expect(applied.single.isResolvedFromPlaces, isTrue);
      expect(applied.single.street, '123 Sample Road');
      expect(applied.single.city, 'Sample Town');
      expect(applied.single.latitude, 0);
      await tester.pumpWidget(const SizedBox());
      text.dispose();
    },
  );

  testWidgets(
    'profile Details failure leaves manual entry available and makes no automatic fallback request',
    (tester) async {
      final text = TextEditingController();
      final applied = <AddressDetails>[];
      await openField(tester, text, applied.add);
      await tester.tap(find.text('Sample business, sample street'));
      await flush(tester);
      transport.respond(1, {}, status: 503);
      await flush(tester);
      expect(applied, isEmpty);
      expect(transport.requests, hasLength(2));
      expect(find.text('Try again'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      text.dispose();
    },
  );
}
