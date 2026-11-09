import 'package:driver_app/core/core.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_provider.dart';
import 'package:driver_app/features/carpool/presentation/widgets/view_passenger_card.dart';
import 'package:driver_app/features/ride_room/presentation/providers/chat_history_provider.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class PassengerList extends ConsumerStatefulWidget {
  final String carpoolId;
  const PassengerList({super.key, required this.carpoolId});

  @override
  ConsumerState<PassengerList> createState() => _PassengerListState();
}

class _PassengerListState extends ConsumerState<PassengerList> {
  /// Avoids stale red dots / chat list from a previous carpool when opening this screen for a new id.
  static String? _sessionLastCarpoolIdChatClearedFor;
  static const Set<String> _hiddenPassengerStatuses = <String>{
    'pending',
    'requested',
    'open',
  };

  Future<void> _loadPassengers() async {
    final carpoolId = widget.carpoolId.trim();
    if (carpoolId.isEmpty) return;
    await ref.read(carpoolProvider.notifier).viewPassenger(carpoolId);
  }

  void _clearChatUiIfFirstOpenForThisCarpool() {
    final String id = widget.carpoolId.trim();
    if (id.isEmpty) return;
    if (_sessionLastCarpoolIdChatClearedFor == id) return;
    _sessionLastCarpoolIdChatClearedFor = id;
    ref
        .read(rideSocketProvider.notifier)
        .clearChatNotificationsForContextSwitch();
    ref.read(chatHistoryProvider.notifier).clearConversation();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearChatUiIfFirstOpenForThisCarpool();
      _loadPassengers();
    });
  }

  bool _shouldShowPassenger(String status) {
    final normalizedStatus = status.trim().toLowerCase();
    return !_hiddenPassengerStatuses.contains(normalizedStatus);
  }

  @override
  void didUpdateWidget(PassengerList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.carpoolId != widget.carpoolId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _clearChatUiIfFirstOpenForThisCarpool();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(carpoolProvider);
    final l10n = context.l10n;
    final visiblePassengers = state.passengers
        .where((passenger) => _shouldShowPassenger(passenger.status))
        .toList(growable: false);

    return AppScaffold(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      appBar: AppBar(title: Text(l10n.passenger_detail), centerTitle: true),

      child: RefreshIndicator(
        onRefresh: _loadPassengers,
        child: Builder(
          builder: (_) {
            if (widget.carpoolId.trim().isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(child: Text(l10n.missing_carpool_id)),
                  ),
                ],
              );
            }

            if (state.isLoading && state.passengers.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null && state.passengers.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(child: Text(state.error!)),
                  ),
                ],
              );
            }

            // Only show "No passengers found" if list is empty
            if (visiblePassengers.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Text(
                        l10n.noPassengerfound,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Display passengers list
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(0),
              itemCount: visiblePassengers.length,
              separatorBuilder: (_, index) => const Gap(12),
              itemBuilder: (context, index) {
                final passenger = visiblePassengers[index];
                return ViewPassengerCard(
                  passenger: passenger,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
