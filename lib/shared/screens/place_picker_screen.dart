import 'dart:async';

import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/location/service_region.dart';
import 'package:driver_app/features/carpool/presentation/widgets/components/map_styles.dart';
import 'package:driver_app/features/carpool/presentation/widgets/fixed_center_pin.dart';
import 'package:driver_app/features/carpool/presentation/widgets/place_picker_provider.dart';
import 'package:driver_app/features/carpool/presentation/widgets/place_picker_state.dart';
import 'package:driver_app/shared/provider/map_style_provider.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/services/places_search_service.dart';

class SelectedLocation {
  final ResolvedPlace? resolvedPlace;
  final double latitude;
  final double longitude;
  final String formattedAddress;

  const SelectedLocation({
    this.resolvedPlace,
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });
}

class PlacePickerScreen extends ConsumerStatefulWidget {
  final bool isAddingStop;
  final bool isPickupLocation;
  final bool isDropoffLocation;
  final String? initialAddress;
  final LatLng? initialPosition;

  const PlacePickerScreen({
    super.key,
    this.isAddingStop = false,
    this.isPickupLocation = false,
    this.isDropoffLocation = false,
    this.initialAddress,
    this.initialPosition,
  });

  @override
  ConsumerState<PlacePickerScreen> createState() => _PlacePickerScreenState();
}

class _PlacePickerScreenState extends ConsumerState<PlacePickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _lastSelectedTarget;
  bool _isDraggingPickerMap = false;

  @override
  void initState() {
    super.initState();
    _lastSelectedTarget = widget.initialPosition;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final latLng = await ref
          .read(placePickerProvider.notifier)
          .setInitialLocation(
            initialPosition: widget.initialPosition,
            initialAddress: widget.initialAddress,
          );
      if (latLng != null && mounted) {
        await _moveCamera(latLng);
      }
    });
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }

  Future<void> _moveCamera(LatLng position) async {
    if (!mounted) return;
    _lastSelectedTarget = position;
    final controller = _mapController;
    if (controller == null) return;
    try {
      await controller.animateCamera(CameraUpdate.newLatLng(position));
    } catch (_) {}
  }

  void _onConfirm(PlacePickerState state) {
    final result = SelectedLocation(
      latitude: state.currentPosition.latitude,
      longitude: state.currentPosition.longitude,
      formattedAddress: state.address,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(placePickerProvider);
    final notifier = ref.read(placePickerProvider.notifier);
    final activeRegion = ServiceRegionConfig.active;
    final CameraTargetBounds cameraTargetBounds = activeRegion.isGlobal
        ? CameraTargetBounds.unbounded
        : CameraTargetBounds(activeRegion.bounds);
    final colors = context.appColors;
    final l10n = context.l10n;
    final mapStyleState = ref.watch(mapStyleProvider);

    final String screenTitle = widget.isPickupLocation
        ? l10n.pickup_location
        : widget.isDropoffLocation
        ? l10n.dropoff_location
        : widget.isAddingStop
        ? 'Stop Location'
        : 'Select Location';

    final String chipTitle = widget.isPickupLocation
        ? l10n.pickup_location
        : widget.isDropoffLocation
        ? l10n.dropoff_location
        : widget.isAddingStop
        ? 'Stop Location'
        : 'Selected Location';

    final bool isResolving = state.isFetchingAddress;
    final bool shouldShowChip =
        !state.isDragging && (state.address.isNotEmpty || isResolving);

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          // Full-screen map extending to edges
          Positioned.fill(
            child: RepaintBoundary(
              child: GoogleMap(
                style: mapStyleState.maybeWhen(
                  data: (styleState) =>
                      context.isDark ? styleState.dark : styleState.light,
                  orElse: () =>
                      context.isDark ? MapStyles.dark : MapStyles.light,
                ),
                initialCameraPosition: CameraPosition(
                  target:
                      _lastSelectedTarget ??
                      activeRegion.clamp(state.currentPosition),
                  zoom: 16,
                ),
                cameraTargetBounds: cameraTargetBounds,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  final target = _lastSelectedTarget;
                  if (target != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      if (!mounted) return;
                      await _moveCamera(target);
                    });
                  }
                },
                onCameraMove: (position) {
                  notifier.onCameraMove(position.target);
                },
                onCameraMoveStarted: () {
                  if (mounted) {
                    setState(() => _isDraggingPickerMap = true);
                  }
                  notifier.setIsDragging(true);
                },
                onCameraIdle: () {
                  if (mounted) {
                    setState(() => _isDraggingPickerMap = false);
                  }
                  notifier.updatePosition(
                    state.currentPosition,
                    reason: 'manual_pin',
                  );
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                buildingsEnabled: false,
                mapToolbarEnabled: false,
                indoorViewEnabled: false,
              ),
            ),
          ),

          // Center Fixed Pin with lift/drop tactile animation
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FixedCenterPin(
                isDragging: _isDraggingPickerMap,
                badgeSize: 42,
              ),
            ),
          ),

          // Floating Top Header (Back button + centered pill title)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Floating Circular Back Button
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: context.isDark ? 0.4 : 0.12,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                  ),
                ),
                const SizedBox(width: 12),
                // Floating Title Pill
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(
                        alpha: context.isDark ? 0.92 : 0.96,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: context.isDark ? 0.35 : 0.1,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, size: 16, color: colors.brand),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            screenTitle,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 48,
                ), // Balances back button for visual center
              ],
            ),
          ),

          // Floating Dynamic Address Chip positioned independently above the pin
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 220),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        opacity: shouldShowChip ? 1.0 : 0.0,
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          offset: state.isDragging
                              ? const Offset(0, 0.15)
                              : Offset.zero,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: colors.fieldFill.withValues(
                                alpha: context.isDark ? 0.95 : 0.98,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colors.border.withValues(alpha: 0.8),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: context.isDark ? 0.35 : 0.08,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chipTitle,
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: colors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                                const SizedBox(height: 3),
                                isResolving
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.brand,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Locating...',
                                            style: context.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: colors.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                            textAlign: TextAlign.start,
                                          ),
                                        ],
                                      )
                                    : Text(
                                        state.locationTitle.isNotEmpty
                                            ? state.locationTitle
                                            : state.address,
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: colors.textPrimary,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Panel (GPS button + Resolved address confirmation card)
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.paddingOf(context).bottom + 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating My Location Button
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: FloatingActionButton.small(
                        heroTag: 'driver_place_picker_my_location_btn',
                        onPressed: () async {
                          final latLng = await notifier.setInitialLocation(
                            openSettingsIfNeeded: true,
                          );
                          if (latLng != null) {
                            await _moveCamera(latLng);
                          }
                        },
                        backgroundColor: colors.surface,
                        child: Icon(
                          Icons.my_location,
                          color: colors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                // Resolved address card + Confirm button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.fieldFill.withValues(
                      alpha: context.isDark ? 0.95 : 0.98,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.border.withValues(alpha: 0.8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: context.isDark ? 0.4 : 0.1,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colors.brand.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: colors.brand,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.locationTitle.isNotEmpty
                                      ? state.locationTitle
                                      : 'Selected Location',
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                isResolving
                                    ? Text(
                                        'Resolving address...',
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              color: colors.textSecondary,
                                            ),
                                      )
                                    : Text(
                                        state.address,
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              color: colors.textSecondary,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: 'Confirm Location',
                          backgroundColor: colors.brand,
                          fontColor: colors.button,
                          onPressed: () => _onConfirm(state),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
