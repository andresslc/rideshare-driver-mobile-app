import 'dart:async';

import 'package:driver_app/core/constants/app_icons.dart';
import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/services/location_service.dart';
import 'package:driver_app/features/carpool/domain/entities/carpool_location_entity.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_route_provider.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_socket_provider.dart';
import 'package:driver_app/features/carpool/presentation/states/carpool_route_state.dart';
import 'package:driver_app/features/carpool/presentation/states/carpool_socket_states.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/l10n/app_localizations.dart';
import 'package:driver_app/shared/screens/place_picker_screen.dart';
import 'package:driver_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../shared/location_component/location_ui/address_search_error.dart';

enum CarpoolField { pickup, dropoff }

class CreateCarpoolScreen extends ConsumerStatefulWidget {
  const CreateCarpoolScreen({super.key});

  @override
  ConsumerState<CreateCarpoolScreen> createState() =>
      _CreateCarpoolScreenState();
}

class _CreateCarpoolScreenState extends ConsumerState<CreateCarpoolScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _dropoffFocusNode = FocusNode();

  late final CarpoolRouteNotifier _routeNotifier;
  int _selectionGeneration = 0;
  int _pickupEditGeneration = 0;
  bool _selecting = false;
  SelectedLocation? _pickupLocation;
  SelectedLocation? _dropoffLocation;
  CarpoolField _activeField = CarpoolField.dropoff;

  @override
  void initState() {
    super.initState();
    _routeNotifier = ref.read(carpoolRouteProvider.notifier);
    _pickupFocusNode.addListener(_onFocusChanged);
    _dropoffFocusNode.addListener(_onFocusChanged);
    _setInitialPickup();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(carpoolRouteProvider.notifier).initialize();
      _dropoffFocusNode.requestFocus();
    });
  }

  void _onFocusChanged() {
    if (_pickupFocusNode.hasFocus) _activateField(CarpoolField.pickup);
    if (_dropoffFocusNode.hasFocus) _activateField(CarpoolField.dropoff);
    if (!_pickupFocusNode.hasFocus && !_dropoffFocusNode.hasFocus) {
      final generation = _selectionGeneration;
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted ||
            generation != _selectionGeneration ||
            _selecting ||
            _pickupFocusNode.hasFocus ||
            _dropoffFocusNode.hasFocus)
          return;
        ref.read(carpoolRouteProvider.notifier).abandonSearch();
      });
    }
  }

  void _activateField(CarpoolField field) {
    if (_activeField == field) return;
    _selectionGeneration++;
    ref.read(carpoolRouteProvider.notifier).activateField(field.name);
    setState(() => _activeField = field);
  }

  @override
  void dispose() {
    _selectionGeneration++;
    _routeNotifier.abandonSearch(notify: false);
    _pickupFocusNode.removeListener(_onFocusChanged);
    _dropoffFocusNode.removeListener(_onFocusChanged);
    _pickupController.dispose();
    _dropoffController.dispose();
    _pickupFocusNode.dispose();
    _dropoffFocusNode.dispose();
    super.dispose();
  }

  Future<void> _setInitialPickup() async {
    final generation = _pickupEditGeneration;
    final locationService = locator<LocationService>();
    final position = await locationService.getCurrentPosition();
    if (position != null && mounted && generation == _pickupEditGeneration) {
      final address = await locationService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
        reason: 'initial_position',
      );
      if (address != null && mounted && generation == _pickupEditGeneration) {
        setState(() {
          _pickupController.text = address;
          _pickupLocation = SelectedLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            formattedAddress: address,
          );
        });
        ref
            .read(carpoolRouteProvider.notifier)
            .setSearchOrigin(LatLng(position.latitude, position.longitude));
      }
    }
  }

  void _swapPickupAndDropoff() {
    _selectionGeneration++;
    _pickupEditGeneration++;
    ref.read(carpoolRouteProvider.notifier).abandonSearch();
    setState(() {
      final tempText = _pickupController.text;
      final tempLocation = _pickupLocation;

      _pickupController.text = _dropoffController.text;
      _pickupLocation = _dropoffLocation;

      _dropoffController.text = tempText;
      _dropoffLocation = tempLocation;
    });

    ref.read(carpoolRouteProvider.notifier).onSearchQueryChanged('');
  }

  Future<void> _pickLocationFromMap({required bool isPickup}) async {
    final activeField = isPickup ? CarpoolField.pickup : CarpoolField.dropoff;
    _selectionGeneration++;
    if (isPickup) _pickupEditGeneration++;
    ref.read(carpoolRouteProvider.notifier).abandonSearch();
    _activateField(activeField);

    final currentLocation = isPickup ? _pickupLocation : _dropoffLocation;
    final LatLng? initialPos = currentLocation == null
        ? null
        : LatLng(currentLocation.latitude, currentLocation.longitude);

    final result = await Navigator.of(context).push<SelectedLocation>(
      MaterialPageRoute(
        builder: (context) => PlacePickerScreen(
          isPickupLocation: isPickup,
          isDropoffLocation: !isPickup,
          initialAddress: currentLocation?.formattedAddress,
          initialPosition: initialPos,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (isPickup) {
          _pickupController.text = result.formattedAddress;
          _pickupLocation = result;
        } else {
          _dropoffController.text = result.formattedAddress;
          _dropoffLocation = result;
        }
      });

      // Save to recents
      await ref
          .read(carpoolRouteProvider.notifier)
          .saveRecentLocation(
            CarpoolLocationEntity(
              id: '${result.latitude},${result.longitude}',
              name: result.formattedAddress.split(',').first.trim(),
              address: result.formattedAddress,
              latitude: result.latitude,
              longitude: result.longitude,
              timestamp: DateTime.now(),
            ),
          );

      if (isPickup) {
        if (_dropoffLocation == null || _dropoffController.text.isEmpty) {
          _dropoffFocusNode.requestFocus();
          _activateField(CarpoolField.dropoff);
        } else {
          _proceedToCarpoolRoute();
        }
      } else {
        if (_pickupLocation == null || _pickupController.text.isEmpty) {
          _pickupFocusNode.requestFocus();
          _activateField(CarpoolField.pickup);
        } else {
          _proceedToCarpoolRoute();
        }
      }
    }
  }

  Future<void> _handleLocationSelection(
    Object location, {
    bool retry = false,
  }) async {
    if (_selecting) return;
    _selecting = true;
    final field = _activeField;
    final generation = ++_selectionGeneration;
    if (field == CarpoolField.pickup) _pickupEditGeneration++;
    try {
      final notifier = ref.read(carpoolRouteProvider.notifier);
      final resolved = retry
          ? await notifier.retrySelection()
          : await notifier.resolveSelectedLocation(location);
      if (resolved == null ||
          !mounted ||
          generation != _selectionGeneration ||
          field != _activeField) {
        return;
      }
      await _applyLocationSelection(
        resolved,
        field == CarpoolField.pickup,
        generation,
      );
    } finally {
      _selecting = false;
    }
  }

  Future<void> _applyLocationSelection(
    CarpoolLocationEntity resolved,
    bool isPickup,
    int generation,
  ) async {
    final selected = SelectedLocation(
      resolvedPlace: resolved.resolvedPlace,
      latitude: resolved.latitude,
      longitude: resolved.longitude,
      formattedAddress: resolved.address,
    );

    setState(() {
      if (isPickup) {
        _pickupController.text = resolved.address.isNotEmpty
            ? resolved.address
            : resolved.name;
        _pickupLocation = selected;
      } else {
        _dropoffController.text = resolved.address.isNotEmpty
            ? resolved.address
            : resolved.name;
        _dropoffLocation = selected;
      }
    });

    await ref.read(carpoolRouteProvider.notifier).saveRecentLocation(resolved);
    if (!mounted || generation != _selectionGeneration) return;
    ref.read(carpoolRouteProvider.notifier).abandonSearch();

    if (isPickup) {
      if (_dropoffLocation == null || _dropoffController.text.isEmpty) {
        _dropoffFocusNode.requestFocus();
        _activateField(CarpoolField.dropoff);
      } else {
        _proceedToCarpoolRoute();
      }
    } else {
      if (_pickupLocation == null || _pickupController.text.isEmpty) {
        _pickupFocusNode.requestFocus();
        _activateField(CarpoolField.pickup);
      } else {
        _proceedToCarpoolRoute();
      }
    }
  }

  bool _hasRecoverableCarpool(CarpoolSocketState state) {
    final stateCarpoolId = state.activeCarpoolId?.trim() ?? '';
    if (stateCarpoolId.isNotEmpty && state.lastRideResume != null) {
      return true;
    }

    final payload = state.lastRideResume ?? const <String, dynamic>{};
    final payloadCarpoolId =
        (payload['carpoolId'] ?? payload['_id'] ?? payload['id'] ?? '')
            .toString()
            .trim();
    return payloadCarpoolId.isNotEmpty;
  }

  void _goToCurrentCarpool() {
    context.goNamed(Routes.rideMap.name);
  }

  void _proceedToCarpoolRoute() {
    if (ref.read(carpoolRouteProvider).isResolvingSelection) return;
    final socketState = ref.read(carpoolSocketProvider);
    if (_hasRecoverableCarpool(socketState)) {
      _goToCurrentCarpool();
      return;
    }

    final isOnline = ref.read(rideSocketProvider).isOnline;
    if (!isOnline) {
      context.showToast(context.l10n.carpool_online_before_start);
      return;
    }

    if (_pickupLocation == null || _dropoffLocation == null) {
      context.showToast(context.l10n.select_both_locations);
      return;
    }

    context.pushNamed(
      Routes.rideMap.name,
      extra: <String, dynamic>{
        'pickupLocation': _pickupLocation,
        'dropoffLocation': _dropoffLocation,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final socketState = ref.watch(carpoolSocketProvider);
    final hasRecoverableCarpool = _hasRecoverableCarpool(socketState);
    final l10n = context.l10n;
    final colors = context.appColors;

    final buttonText = hasRecoverableCarpool
        ? l10n.go_to_ride_progress
        : 'Confirm Route';

    final bool isConfirmEnabled =
        hasRecoverableCarpool ||
        (_pickupLocation != null && _dropoffLocation != null);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.enter_destination,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: AppButton(
            text: buttonText,
            backgroundColor: isConfirmEnabled
                ? colors.brand
                : colors.brand.withValues(alpha: 0.35),
            fontColor: colors.button,
            onPressed: isConfirmEnabled ? _proceedToCarpoolRoute : null,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Route Input Card
          _buildRouteInputsCard(context, l10n, colors),

          // "Choose on Map" action tile
          _buildChooseOnMapTile(context, l10n, colors),

          const SizedBox(height: 8),

          // Scrollable results (scoped Consumer for fast typing)
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final routeState = ref.watch(carpoolRouteProvider);

                if (routeState.isSearching) {
                  return _buildSearchResults(context, routeState, l10n, colors);
                }

                return _buildRecentsList(context, routeState, l10n, colors);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInputsCard(
    BuildContext context,
    AppLocalizations l10n,
    AppThemeColors colors,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.fieldFill.withValues(alpha: context.isDark ? 0.9 : 0.98),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Visual path indicators (Green dot -> line -> Brand dot)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981), // Emerald green
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 38,
                color: colors.border.withValues(alpha: 0.8),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors.brand,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Fields
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pickup input
                _buildRouteTextField(
                  context: context,
                  controller: _pickupController,
                  focusNode: _pickupFocusNode,
                  hintText: l10n.pickup_location,
                  isActive: _activeField == CarpoolField.pickup,
                  onTap: () {
                    _activateField(CarpoolField.pickup);
                  },
                  onChanged: (value) {
                    _selectionGeneration++;
                    _pickupEditGeneration++;
                    setState(() => _pickupLocation = null);
                    _activateField(CarpoolField.pickup);
                    ref
                        .read(carpoolRouteProvider.notifier)
                        .onSearchQueryChanged(value, field: 'pickup');
                  },
                  onClear: () {
                    _selectionGeneration++;
                    _pickupEditGeneration++;
                    _pickupController.clear();
                    setState(() => _pickupLocation = null);
                    ref
                        .read(carpoolRouteProvider.notifier)
                        .onSearchQueryChanged('');
                  },
                ),
                Divider(
                  height: 16,
                  thickness: 1,
                  color: colors.border.withValues(alpha: 0.5),
                ),
                // Dropoff input
                _buildRouteTextField(
                  context: context,
                  controller: _dropoffController,
                  focusNode: _dropoffFocusNode,
                  hintText: l10n.dropoff_location,
                  isActive: _activeField == CarpoolField.dropoff,
                  onTap: () {
                    _activateField(CarpoolField.dropoff);
                  },
                  onChanged: (value) {
                    _selectionGeneration++;
                    setState(() => _dropoffLocation = null);
                    _activateField(CarpoolField.dropoff);
                    final LatLng? pickupOrigin = _pickupLocation != null
                        ? LatLng(
                            _pickupLocation!.latitude,
                            _pickupLocation!.longitude,
                          )
                        : null;
                    ref
                        .read(carpoolRouteProvider.notifier)
                        .onSearchQueryChanged(
                          value,
                          origin: pickupOrigin,
                          field: 'dropoff',
                        );
                  },
                  onClear: () {
                    _selectionGeneration++;
                    _dropoffController.clear();
                    setState(() => _dropoffLocation = null);
                    ref
                        .read(carpoolRouteProvider.notifier)
                        .onSearchQueryChanged('');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Swap button
          IconButton(
            onPressed: _swapPickupAndDropoff,
            icon: Icon(Icons.swap_vert_rounded, color: colors.brand, size: 24),
            tooltip: 'Swap locations',
          ),
        ],
      ),
    );
  }

  Widget _buildRouteTextField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required bool isActive,
    required VoidCallback onTap,
    required ValueChanged<String> onChanged,
    required VoidCallback onClear,
  }) {
    final colors = context.appColors;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onTap: onTap,
            onChanged: onChanged,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: colors.textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              hintText: hintText,
              hintStyle: context.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary.withValues(alpha: 0.7),
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),
          ),
        ),
        if (controller.text.isNotEmpty)
          IconButton(
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            padding: EdgeInsets.zero,
            onPressed: onClear,
            icon: Icon(Icons.cancel, size: 16, color: colors.textSecondary),
          ),
      ],
    );
  }

  Widget _buildChooseOnMapTile(
    BuildContext context,
    AppLocalizations l10n,
    AppThemeColors colors,
  ) {
    final isPickup = _activeField == CarpoolField.pickup;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.fieldFill.withValues(alpha: context.isDark ? 0.7 : 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          dense: true,
          onTap: () => _pickLocationFromMap(isPickup: isPickup),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.brand.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.map_outlined, color: colors.brand, size: 20),
          ),
          title: Text(
            isPickup ? 'Choose Pickup on Map' : 'Choose Drop-off on Map',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    CarpoolRouteState routeState,
    AppLocalizations l10n,
    AppThemeColors colors,
  ) {
    if (routeState.isFetchingSuggestions || routeState.isResolvingSelection) {
      return const Center(child: CircularProgressIndicator());
    }
    if (routeState.searchError != null) {
      return Center(
        child: AddressSearchError(
          failure: routeState.searchError!,
          onRetry: () => _handleLocationSelection(Object(), retry: true),
        ),
      );
    }

    if (routeState.searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No locations found',
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: routeState.searchResults.length + 1,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: colors.border.withValues(alpha: 0.3)),
      itemBuilder: (context, index) {
        if (index == routeState.searchResults.length) {
          return const Text('Google Maps', textAlign: TextAlign.end);
        }
        final location = routeState.searchResults[index];
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border.withValues(alpha: 0.5)),
            ),
            child: Image.asset(
              AppIcons.locationFill,
              width: 18,
              height: 18,
              color: colors.brand,
            ),
          ),
          title: Text(
            location.primaryText.isEmpty
                ? location.label
                : location.primaryText,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            location.label,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _handleLocationSelection(location),
        );
      },
    );
  }

  Widget _buildRecentsList(
    BuildContext context,
    CarpoolRouteState routeState,
    AppLocalizations l10n,
    AppThemeColors colors,
  ) {
    if (!routeState.hasRecent) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_rounded,
                size: 48,
                color: colors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Search destination or choose on map',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Recent Locations',
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textSecondary,
            ),
          ),
        ),
        ...routeState.recents.map((location) {
          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: colors.border.withValues(alpha: 0.5)),
              ),
              child: Icon(
                Icons.history_rounded,
                size: 18,
                color: colors.textSecondary,
              ),
            ),
            title: Text(
              location.name,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              location.address,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _handleLocationSelection(location),
          );
        }),
      ],
    );
  }
}
