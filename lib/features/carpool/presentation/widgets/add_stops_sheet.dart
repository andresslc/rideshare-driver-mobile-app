import 'package:driver_app/core/constants/app_icons.dart';
import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/extensions/context_extension.dart';
import 'package:driver_app/core/extensions/theme_extension.dart';
import 'package:driver_app/shared/screens/place_picker_screen.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';

class AddStopsSheet extends StatefulWidget {
  final void Function(List<SelectedLocation?> stops) onNext;
  final void Function(List<SelectedLocation?> stops)? onStopsChanged;
  final ScrollController scrollController;
  final List<SelectedLocation?>? initialStops;

  const AddStopsSheet({
    super.key,
    required this.onNext,
    this.onStopsChanged,
    required this.scrollController,
    this.initialStops,
  });

  @override
  State<AddStopsSheet> createState() => _AddStopsSheetState();
}

class _AddStopsSheetState extends State<AddStopsSheet> {
  late List<SelectedLocation?> stops;

  @override
  void initState() {
    super.initState();
    stops = widget.initialStops ?? [null];
  }

  bool _areLocationsSame(SelectedLocation a, SelectedLocation b) {
    if (a.formattedAddress.trim().toLowerCase() ==
        b.formattedAddress.trim().toLowerCase()) {
      return true;
    }
    final distance = Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
    return distance < 50;
  }

  Future<void> _pickLocation(int index) async {
    final bool isPickup = index == 0;
    final bool isDropoff = stops.length >= 2 && index == stops.length - 1;
    final bool isStop = !isPickup && !isDropoff;

    final result = await Navigator.of(context).push<SelectedLocation>(
      MaterialPageRoute(
        builder: (context) => PlacePickerScreen(
          isPickupLocation: isPickup,
          isDropoffLocation: isDropoff,
          isAddingStop: isStop,
        ),
      ),
    );

    if (result != null && mounted) {
      // Check immediately previous stop
      if (index > 0) {
        final prev = stops[index - 1];
        if (prev != null && _areLocationsSame(result, prev)) {
          context.showToast(
            'Consecutive stops cannot be the same location.',
          );
          return;
        }
      }

      // Check immediately next stop
      if (index < stops.length - 1) {
        final next = stops[index + 1];
        if (next != null && _areLocationsSame(result, next)) {
          context.showToast(
            'Consecutive stops cannot be the same location.',
          );
          return;
        }
      }

      setState(() {
        if (index < stops.length) {
          stops[index] = result;
        } else {
          stops.add(result);
        }
      });
      widget.onStopsChanged?.call(List<SelectedLocation?>.from(stops));

      // Auto scroll to bottom
      Future.delayed(const Duration(milliseconds: 200), () {
        if (widget.scrollController.hasClients) {
          widget.scrollController.animateTo(
            widget.scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  int get _newStopInsertIndex =>
      stops.length < 2 ? stops.length : stops.length - 1;

  Future<void> _addStop() async {
    final result = await Navigator.of(context).push<SelectedLocation>(
      MaterialPageRoute(
        builder: (context) => const PlacePickerScreen(isAddingStop: true),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    final insertIndex = _newStopInsertIndex;

    // Check stop immediately before insert point
    if (insertIndex > 0) {
      final prev = stops[insertIndex - 1];
      if (prev != null && _areLocationsSame(result, prev)) {
        context.showToast(
          'Consecutive stops cannot be the same location.',
        );
        return;
      }
    }

    // Check stop immediately after insert point
    if (insertIndex < stops.length) {
      final next = stops[insertIndex];
      if (next != null && _areLocationsSame(result, next)) {
        context.showToast(
          'Consecutive stops cannot be the same location.',
        );
        return;
      }
    }

    setState(() {
      stops.insert(insertIndex, result);
    });
    widget.onStopsChanged?.call(List<SelectedLocation?>.from(stops));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (widget.scrollController.hasClients) {
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _removeStop(int index) {
    setState(() => stops.removeAt(index));
    widget.onStopsChanged?.call(List<SelectedLocation?>.from(stops));
  }

  bool get _hasUnselectedStops => stops.any((stop) => stop == null);

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = context.colorScheme;
    final l10n = context.l10n;

    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + context.padding.bottom),
      children: [
        Text(
          l10n.add_stops_title,
          style: textTheme.titleLarge,
        ).animate().fade(duration: 300.ms).slideY(begin: -0.2, end: 0),
        const SizedBox(height: 6),
        Text(
          l10n.add_stops_subtitle,
          style: textTheme.bodyMedium,
        ).animate().fade(delay: 100.ms).slideY(begin: -0.1, end: 0),
        Divider(color: colors.outlineVariant),

        // Stops
        ...List.generate(stops.length, (index) {
          final stop = stops[index];
          String title = l10n.stop_title(index + 1);
          if (index == 0) title += l10n.starting_point_suffix;
          if (index == stops.length - 1) title += l10n.final_destination_suffix;
          return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _pickLocation(index),
                      borderRadius: BorderRadius.circular(8),
                      child: AppGradientBox(
                        cornerRadius: AppSizes.p11,
                        child: Padding(
                          padding: EdgeInsets.all(AppSizes.p14),
                          child: Row(
                            children: [
                              Image.asset(
                                AppIcons.location,
                                width: 20,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  stop?.formattedAddress ??
                                      l10n.tap_to_select_location,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: stop == null
                                        ? colors.outline
                                        : colors.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (index != 0 && index != stops.length - 1)
                                GestureDetector(
                                  onTap: () => _removeStop(index),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Icon(
                                      Icons.close,
                                      color: colors.error,
                                      size: 15,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fade(
                delay: Duration(milliseconds: 120 * index),
                duration: 300.ms,
              )
              .slideX(begin: 0.08, end: 0);
        }),

        // Add Stop Button
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _addStop(),
            icon: Icon(Icons.add, color: colors.primary),
            label: Text(
              l10n.add_stops,
              style: textTheme.bodyMedium?.copyWith(color: colors.primary),
            ),
          ),
        ).animate().fade(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
        Divider(color: colors.outlineVariant),

        // Continue button
        AppButton(
          text: l10n.save_stops_continue,
          onPressed: _hasUnselectedStops
              ? null
              : () {
                  if (stops.length < 2) {
                    context.showToast('Please select pickup and drop-off locations.');
                    return;
                  }

                  // If pickup == dropoff without intermediate stops
                  if (stops.length == 2 &&
                      stops[0] != null &&
                      stops[1] != null &&
                      _areLocationsSame(stops[0]!, stops[1]!)) {
                    context.showToast(
                      'Please add at least one intermediate stop for a round trip.',
                    );
                    return;
                  }

                  // Check consecutive stops
                  for (var i = 0; i < stops.length - 1; i++) {
                    final current = stops[i];
                    final next = stops[i + 1];
                    if (current != null &&
                        next != null &&
                        _areLocationsSame(current, next)) {
                      context.showToast(
                        'Consecutive stops cannot be the same location.',
                      );
                      return;
                    }
                  }

                  widget.onNext(stops);
                },
        ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 16),
      ],
    );
  }
}
