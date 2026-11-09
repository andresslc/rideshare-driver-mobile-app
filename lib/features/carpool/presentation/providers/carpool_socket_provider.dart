import 'dart:async';
import 'dart:convert';

import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/core/services/sound_service.dart';
import 'package:driver_app/core/params/carpool_params.dart';
import 'package:driver_app/core/utils/app_log.dart';
import 'package:driver_app/features/carpool/data/models/carpool_model.dart';
import 'package:driver_app/features/carpool/domain/entities/carpool_entity.dart';
import 'package:driver_app/features/carpool/domain/repositories/carpool_socket_repository.dart';
import 'package:driver_app/features/carpool/presentation/states/carpool_socket_states.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final carpoolSocketProvider =
    NotifierProvider<CarpoolSocketNotifier, CarpoolSocketState>(
      CarpoolSocketNotifier.new,
    );

class CarpoolSocketNotifier extends Notifier<CarpoolSocketState> {
  late CarpoolSocketRepository _repository;
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];

  String _stateSnapshot(CarpoolSocketState value) {
    return 'status=${value.status}, action=${value.action}, activeCarpoolId=${value.activeCarpoolId}, incoming=${value.incomingRequests.length}, accepted=${value.acceptedRequests.length}, hasActiveRide=${value.hasActiveRide}, isRideStarted=${value.isRideStarted}, lastRideResumeKeys=${value.lastRideResume}';
  }

  @override
  CarpoolSocketState build() {
    _repository = locator<CarpoolSocketRepository>();
    _listenToIncomingRequests();
    _listenToCarpoolResume();
    _listenToRouteUpdates();
    _listenToPassengerPickedUpdates();
    _listenToBookingStatusUpdates();
    _listenToRideCompletedUpdates();
    _listenToErrors();
    ref.onDispose(() {
      for (final sub in _subscriptions) {
        sub.cancel();
      }
      _subscriptions.clear();
    });

    return const CarpoolSocketState();
  }

  void _listenToIncomingRequests() {
    final sub = _repository.incomingRequestStream().listen((request) {
      log(
        'incomingRequestStream -> bookingId=${request.bookingId}, before: ${_stateSnapshot(state)}',
        name: 'CarpoolSocketProvider',
      );
      final incomingId = request.bookingId;
      final List<CarpoolIncomingRequestEntity> updatedRequests =
          <CarpoolIncomingRequestEntity>[
            ...state.incomingRequests.where(
              (item) => item.bookingId != incomingId,
            ),
          ];
      updatedRequests.insert(0, request);

      state = state.copyWith(
        status: CarpoolSocketStatus.success,
        action: CarpoolSocketAction.rideIncoming,
        lastIncomingRequest: request,
        incomingRequests: updatedRequests,
        clearMessage: true,
      );
      locator<SoundService>().playRequestReceivedSound();
      log(
        'incomingRequestStream applied -> ${_stateSnapshot(state)}',
        name: 'CarpoolSocketProvider',
      );
    });
    _subscriptions.add(sub);
  }

  void _listenToErrors() {
    final sub = _repository.watchErrors().listen((err) {
      log('watchErrors -> $err', name: 'CarpoolSocketProvider');
      state = state.copyWith(status: CarpoolSocketStatus.error, message: err);
    });
    _subscriptions.add(sub);
  }

  void _listenToCarpoolResume() {
    final sub = _repository.carpoolResumeStream().listen((data) {
      log('carpoolResumeStream raw -> $data', name: 'CarpoolSocketProvider');
      final payload = _extractPayload(data);
      final extractedStops = _extractStopProgress(payload);
      final resolvedStops = extractedStops.isEmpty
          ? state.stopProgress
          : extractedStops;
      final nextIndex = _resolveCurrentStopIndex(
        payload: payload,
        stops: resolvedStops,
      );
      final nextStops = _syncStopArrivalState(
        stops: resolvedStops,
        currentStopIndex: nextIndex,
      );
      final normalizedStatus = _extractRideStatus(payload);
      final hasPassengerSnapshot = payload.containsKey('passengers');
      final pendingRequests = hasPassengerSnapshot
          ? _extractPendingRequests(payload)
          : state.incomingRequests;
      final acceptedRequests = hasPassengerSnapshot
          ? _extractAcceptedRequests(payload)
          : state.acceptedRequests;

      final String resumeCarpoolId = (_extractCarpoolId(payload) ?? '').trim();
      final String prevResumeId = (state.activeCarpoolId ?? '').trim();

      state = state.copyWith(
        status: CarpoolSocketStatus.success,
        action: CarpoolSocketAction.rideResume,
        activeCarpoolId: _extractCarpoolId(payload) ?? state.activeCarpoolId,
        stopProgress: nextStops,
        currentStopIndex: nextIndex,
        lastRideResume: payload,
        incomingRequests: pendingRequests,
        acceptedRequests: acceptedRequests,
        hasActiveRide: _hasActiveRideFromStatus(normalizedStatus),
        isRideStarted: _isRideStartedFromStatus(normalizedStatus),
        clearMessage: true,
      );
      log(
        'carpoolResumeStream applied -> ${_stateSnapshot(state)}',
        name: 'CarpoolSocketProvider',
      );
    });
    _subscriptions.add(sub);
  }

  void _listenToRouteUpdates() {
    final sub = _repository.routeUpdateStream().listen((data) {
      log('routeUpdateStream raw -> $data', name: 'CarpoolSocketProvider');
      final payload = _extractPayload(data);
      final carpoolId = _extractCarpoolId(payload);
      final extractedStops = _extractStopProgress(payload);
      final resolvedStops = extractedStops.isEmpty
          ? state.stopProgress
          : extractedStops;
      final normalizedStatus = _extractRideStatus(payload);
      final cancelledBookingId = (payload['cancelledBookingId'] ?? '')
          .toString()
          .trim();
      final cancellationReason = (payload['reason'] ?? '').toString().trim();
      final hasPassengerSnapshot = payload.containsKey('passengers');
      final pendingRequests = hasPassengerSnapshot
          ? _extractPendingRequests(payload)
          : state.incomingRequests;
      final acceptedRequests = hasPassengerSnapshot
          ? _extractAcceptedRequests(payload)
          : state.acceptedRequests;
      final adjustedPendingRequests = cancelledBookingId.isEmpty
          ? pendingRequests
          : pendingRequests
                .where((item) => item.bookingId != cancelledBookingId)
                .toList(growable: false);
      final adjustedAcceptedRequests = cancelledBookingId.isEmpty
          ? acceptedRequests
          : acceptedRequests
                .where((item) => item.bookingId != cancelledBookingId)
                .toList(growable: false);
      final adjustedStops = cancelledBookingId.isEmpty
          ? resolvedStops
          : _withCancelledBookingMarked(
              stops: resolvedStops,
              bookingId: cancelledBookingId,
            );
      final nextIndex = _resolveCurrentStopIndex(
        payload: payload,
        stops: adjustedStops,
      );
      final syncedStops = _syncStopArrivalState(
        stops: adjustedStops,
        currentStopIndex: nextIndex,
      );
      final mergedRideResume = _mergeRideResumePayload(
        state.lastRideResume,
        payload,
      );
      final updatedRideResume = cancelledBookingId.isEmpty
          ? mergedRideResume
          : _markPassengerStatusInRideResume(
              mergedRideResume,
              bookingId: cancelledBookingId,
              status: 'cancelled',
            );
      final wasLastPassengerCancelled =
          normalizedStatus == 'cancelled' &&
          // payload['wasLastPassenger'] == true &&
          adjustedPendingRequests.isEmpty
      // &&
      // adjustedAcceptedRequests.isEmpty
      ;

      if (normalizedStatus == 'completed') {
        locator<SoundService>().playRideCompletedSound();
        state = state.copyWith(
          status: CarpoolSocketStatus.success,
          action: CarpoolSocketAction.rideComplete,
          activeCarpoolId: '',
          stopProgress: const <CarpoolStopProgress>[],
          currentStopIndex: 0,
          hasActiveRide: false,
          isRideStarted: false,
          incomingRequests: const <CarpoolIncomingRequestEntity>[],
          acceptedRequests: const <CarpoolIncomingRequestEntity>[],
          lastRideResume: payload,
          clearIncomingRequest: true,
          clearLastPickedBookingId: true,
          clearLastCancelledBookingId: true,
          clearMessage: true,
        );
        log(
          'routeUpdateStream completed -> ${_stateSnapshot(state)}',
          name: 'CarpoolSocketProvider',
        );
        return;
      }

      if (wasLastPassengerCancelled) {
        locator<SoundService>().playRideCancelledSound();
        state = state.copyWith(
          status: CarpoolSocketStatus.success,
          action: CarpoolSocketAction.rideCancel,
          activeCarpoolId: '',
          stopProgress: const <CarpoolStopProgress>[],
          currentStopIndex: 0,
          hasActiveRide: false,
          isRideStarted: false,
          incomingRequests: const <CarpoolIncomingRequestEntity>[],
          acceptedRequests: const <CarpoolIncomingRequestEntity>[],
          lastRideResume: null,
          lastCancelledBookingId: cancelledBookingId,
          message: 'Your ride has been cancelled',
          clearIncomingRequest: true,
          clearLastPickedBookingId: true,
          clearLastCancelledBookingId: true,
        );
        log(
          'routeUpdateStream cancelled last passenger -> ${_stateSnapshot(state)}',
          name: 'CarpoolSocketProvider',
        );
        return;
      }

      final String nextCarpoolId = (carpoolId ?? '').trim();
      final String prevCarpoolId = (state.activeCarpoolId ?? '').trim();

      if (cancelledBookingId.isNotEmpty && !wasLastPassengerCancelled) {
        locator<SoundService>().playRideCancelledSound();
      }

      state = state.copyWith(
        status: CarpoolSocketStatus.success,
        action: CarpoolSocketAction.rideResume,
        activeCarpoolId: carpoolId ?? state.activeCarpoolId,
        stopProgress: syncedStops,
        currentStopIndex: nextIndex,
        hasActiveRide: _hasActiveRideFromStatus(normalizedStatus),
        isRideStarted: _isRideStartedFromStatus(normalizedStatus),
        incomingRequests: adjustedPendingRequests,
        acceptedRequests: adjustedAcceptedRequests,
        lastRideResume: updatedRideResume,
        lastCancelledBookingId: cancelledBookingId.isEmpty
            ? state.lastCancelledBookingId
            : cancelledBookingId,
        message: cancellationReason.isEmpty
            ? state.message
            : cancellationReason,
        clearMessage: cancellationReason.isEmpty,
      );
      log(
        'routeUpdateStream applied -> ${_stateSnapshot(state)}',
        name: 'CarpoolSocketProvider',
      );
    });
    _subscriptions.add(sub);
  }

  void _listenToPassengerPickedUpdates() {
    final sub = _repository.passengerPickedStream().listen((data) {
      final payload = _extractPayload(data);
      final bookingId = _extractBookingId(payload);
      final carpoolId = _extractCarpoolId(payload);

      List<CarpoolStopProgress> updatedStops = state.stopProgress;
      if (bookingId != null && state.stopProgress.isNotEmpty) {
        updatedStops = state.stopProgress
            .map((stop) {
              if (!stop.bookingIds.contains(bookingId) ||
                  stop.pickedBookingIds.contains(bookingId)) {
                return stop;
              }
              return stop.copyWith(
                pickedBookingIds: <String>[...stop.pickedBookingIds, bookingId],
              );
            })
            .toList(growable: false);
      }

      locator<SoundService>().playRideStartedSound();
      state = state.copyWith(
        status: CarpoolSocketStatus.success,
        action: CarpoolSocketAction.ridePassengerPick,
        activeCarpoolId: carpoolId ?? state.activeCarpoolId,
        stopProgress: updatedStops,
        lastPickedBookingId: bookingId ?? state.lastPickedBookingId,
        clearMessage: true,
      );
    });
    _subscriptions.add(sub);
  }

  void _listenToRideCompletedUpdates() {
    final sub = _repository.rideCompletedStream().listen((data) {
      final payload = _extractPayload(data);
      final bookingId = _extractBookingId(payload)?.trim();
      if (bookingId == null || bookingId.isEmpty) {
        return;
      }

      locator<SoundService>().playRideCompletedSound();
      _markBookingAsCompleted(
        bookingId,
        message: 'Passenger dropped successfully.',
      );
    });
    _subscriptions.add(sub);
  }

  void _listenToBookingStatusUpdates() {
    final sub = _repository.bookingStatusStream().listen((data) {
      log('Carpool status update data received: $data');

      final payload = _extractPayload(data);
      final bookingId = _extractBookingId(payload);
      final status = (payload['status'] ?? '').toString().trim().toLowerCase();
      final reason = (payload['reason'] ?? '').toString().trim().toLowerCase();
      final isCancelled =
          status == 'cancelled' || status == 'canceled' || status == 'rejected';
      if (!isCancelled || bookingId == null) {
        return;
      }
      locator<SoundService>().playRideCancelledSound();
      final isPaymentFailure =
          reason == 'card_declined' || reason == 'payment_failed';
      _markBookingAsCancelled(
        bookingId,
        message: isPaymentFailure
            ? 'Passenger payment failed. You can complete the ride.'
            : 'Passenger carpool request was cancelled.',
      );
    });
    _subscriptions.add(sub);
  }

  Future<bool> createRoute(CarpoolRideParams params) async {
    state = state.copyWith(
      status: CarpoolSocketStatus.loading,
      action: CarpoolSocketAction.none,
      clearMessage: true,
    );

    final res = await _repository.createRoute(params);
    return res.fold(
      (failure) {
        state = state.copyWith(
          status: CarpoolSocketStatus.error,
          message: failure.message,
        );
        return false;
      },
      (message) {
        final messageText = message.trim();
        final ackPayload = _decodeAckPayload(messageText);
        final ackMessage = ackPayload?['message']?.toString().trim();
        final serverPayload = ackPayload == null
            ? null
            : _extractPayload(ackPayload);
        final extractedCarpoolId =
            (serverPayload == null ? null : _extractCarpoolId(serverPayload)) ??
            _extractCarpoolIdFromCreateAck(messageText);
        final localPayload = _buildCreatedRoutePayload(
          params: params,
          carpoolId: extractedCarpoolId,
        );
        final createdRoutePayload =
            (serverPayload == null || serverPayload.isEmpty)
            ? localPayload
            : _mergeRideResumePayload(localPayload, serverPayload) ??
                  localPayload;
        final createdStops = _extractStopProgress(createdRoutePayload);
        final syncedStops = _syncStopArrivalState(
          stops: createdStops,
          currentStopIndex: 0,
        );
        state = state.copyWith(
          status: CarpoolSocketStatus.success,
          action: CarpoolSocketAction.none,
          activeCarpoolId: extractedCarpoolId ?? state.activeCarpoolId,
          stopProgress: syncedStops,
          currentStopIndex: 0,
          lastRideResume: createdRoutePayload,
          hasActiveRide: false,
          isRideStarted: false,
          message: ackMessage != null && ackMessage.isNotEmpty
              ? ackMessage
              : (messageText.isEmpty ? state.message : messageText),
        );

        return true;
      },
    );
  }

  Future<bool> cancelCurrentRoute() async {
    final carpoolId = _resolveCurrentCarpoolId();
    if (carpoolId == null) {
      state = state.copyWith(
        status: CarpoolSocketStatus.error,
        action: CarpoolSocketAction.rideCancel,
        message: 'Unable to cancel ride. Missing carpool ID.',
      );
      return false;
    }

    return await cancelRide(carpoolId);
  }

  Future<bool> respondToIncomingRideRequest(
    BookingActionRequestParams params,
  ) async {
    final requestBeforeAck = state.incomingRequests
        .cast<CarpoolIncomingRequestEntity?>()
        .firstWhere(
          (item) => item?.bookingId == params.bookingId,
          orElse: () => null,
        );
    log(
      'respondToIncomingRideRequest start -> bookingId=${params.bookingId}, action=${params.action}, before: ${_stateSnapshot(state)}',
      name: 'CarpoolSocketProvider',
    );
    state = state.copyWith(
      status: CarpoolSocketStatus.loading,
      action: CarpoolSocketAction.rideRequestAccept,
      clearMessage: true,
    );

    final res = await _repository.respondToRequest(params);
    return res.fold(
      (failure) {
        log(
          'respondToIncomingRideRequest failure -> bookingId=${params.bookingId}, action=${params.action}, message=${failure.message}',
          name: 'CarpoolSocketProvider',
        );
        if (_isPaymentFailureMessage(failure.message)) {
          _markBookingAsCancelled(
            params.bookingId,
            message: 'Passenger payment failed. You can complete the ride.',
          );
          return false;
        }
        state = state.copyWith(
          status: CarpoolSocketStatus.error,
          message: failure.message,
        );
        log(
          'respondToIncomingRideRequest failure applied -> ${_stateSnapshot(state)}',
          name: 'CarpoolSocketProvider',
        );
        return false;
      },
      (_) {
        final updated = state.incomingRequests
            .where((request) => request.bookingId != params.bookingId)
            .toList();
        final normalizedAction = params.action.trim().toLowerCase();
        final accepted =
            normalizedAction == 'accept' && requestBeforeAck != null
            ? <CarpoolIncomingRequestEntity>[
                ...state.acceptedRequests.where(
                  (item) => item.bookingId != requestBeforeAck.bookingId,
                ),
                requestBeforeAck,
              ]
            : state.acceptedRequests
                  .where((item) => item.bookingId != params.bookingId)
                  .toList(growable: false);

        if (normalizedAction == 'accept') {
          locator<SoundService>().playRideAcceptedSound();
        } else if (normalizedAction == 'reject' ||
            normalizedAction == 'decline') {
          locator<SoundService>().playRideCancelledSound();
        }
        state = state.copyWith(
          status: CarpoolSocketStatus.success,
          action: CarpoolSocketAction.rideRequestAccept,
          incomingRequests: updated,
          acceptedRequests: accepted,
        );
        log(
          'respondToIncomingRideRequest success applied -> bookingId=${params.bookingId}, action=${params.action}, after: ${_stateSnapshot(state)}',
          name: 'CarpoolSocketProvider',
        );
        return true;
      },
    );
  }

  Future<void> startRide(String rideId) async {
    if (!state.hasAcceptedPassengers) {
      state = state.copyWith(
        status: CarpoolSocketStatus.error,
        action: CarpoolSocketAction.rideStart,
        message: 'Accept at least one passenger before starting the carpool.',
      );
      return;
    }

    state = state.copyWith(
      status: CarpoolSocketStatus.loading,
      action: CarpoolSocketAction.rideStart,
      clearMessage: true,
    );

    final res = await _repository.startCarpool(rideId);
    res.fold(
      (failure) => state = state.copyWith(
        status: CarpoolSocketStatus.error,
        message: failure.message,
      ),
      (_) {
        final updatedRideResume = _updateRideResumeStatus(
          state.lastRideResume,
          status: 'in_progress',
          type: 'in_progress',
        );
        locator<SoundService>().playRideStartedSound();
        state = state.copyWith(
          status: CarpoolSocketStatus.success,
          action: CarpoolSocketAction.rideStart,
          hasActiveRide: true,
          isRideStarted: true,
          activeCarpoolId: rideId,
          lastRideResume: updatedRideResume,
          clearLastPickedBookingId: true,
          clearLastCancelledBookingId: true,
        );
      },
    );
  }

  Future<void> completeRide(String bookingId) async {
    state = state.copyWith(
      status: CarpoolSocketStatus.loading,
      action: CarpoolSocketAction.ridePassengerDrop,
      clearMessage: true,
    );

    final res = await _repository.completeCarpool(bookingId);
    res.fold(
      (failure) => state = state.copyWith(
        status: CarpoolSocketStatus.error,
        message: failure.message,
      ),
      (message) {
        final trimmedBookingId = bookingId.trim();
        final ackPayload = _decodeAckPayload(message.trim());
        final ackData = ackPayload == null ? null : _extractPayload(ackPayload);
        final carpoolCompleted = ackData?['carpoolCompleted'] == true;

        locator<SoundService>().playRideCompletedSound();
        _markBookingAsCompleted(
          trimmedBookingId,
          message: carpoolCompleted
              ? 'All passengers dropped successfully.'
              : 'Passenger dropped successfully.',
        );

        if (carpoolCompleted) {
          state = state.copyWith(action: CarpoolSocketAction.ridePassengerDrop);
        }
      },
    );
  }

  Future<bool> cancelRide(String rideId) async {
    state = state.copyWith(
      status: CarpoolSocketStatus.loading,
      action: CarpoolSocketAction.rideCancel,
      clearMessage: true,
    );

    final res = await _repository.cancelRoute(rideId);
    return res.fold(
      (failure) {
        state = state.copyWith(
          status: CarpoolSocketStatus.error,
          message: failure.message,
        );
        return false;
      },
      (_) {
        locator<SoundService>().playRideCancelledSound();
        state = state.copyWith(
          status: CarpoolSocketStatus.success,
          action: CarpoolSocketAction.rideCancel,
          hasActiveRide: false,
          isRideStarted: false,
          activeCarpoolId: '',
          clearRideResume: true,
          clearLastPickedBookingId: true,
          clearLastCancelledBookingId: true,
        );

        return true;
      },
    );
  }

  Future<bool> arriveAtStop({
    required String routeStopId,
    required String carpoolId,
  }) async {
    state = state.copyWith(
      status: CarpoolSocketStatus.loading,
      action: CarpoolSocketAction.rideArrive,
      clearMessage: true,
    );

    final res = await _repository.arriveAtStop(
      CarpoolArriveRequestParams(
        routeStopId: routeStopId,
        carpoolId: carpoolId,
      ),
    );
    return res.fold(
      (failure) {
        state = state.copyWith(
          status: CarpoolSocketStatus.error,
          message: failure.message,
        );
        return false;
      },
      (_) {
        locator<SoundService>().playDriverArrivedSound();
        final matchedStopIndex = state.stopProgress.indexWhere(
          (stop) => stop.routeStopId == routeStopId,
        );
        final effectiveStopIndex = matchedStopIndex >= 0
            ? matchedStopIndex
            : state.currentStopIndex;
        final hasNextStop = effectiveStopIndex < state.stopProgress.length - 1;
        final updatedStops = state.stopProgress
            .asMap()
            .entries
            .map(
              (entry) => entry.key == effectiveStopIndex
                  ? entry.value.copyWith(hasArrived: true)
                  : entry.value,
            )
            .toList(growable: false);
        state = state.copyWith(
          status: CarpoolSocketStatus.success,
          action: CarpoolSocketAction.rideArrive,
          stopProgress: updatedStops,
          currentStopIndex: hasNextStop
              ? effectiveStopIndex + 1
              : effectiveStopIndex,
        );
        return true;
      },
    );
  }

  Future<void> pickPassengerForCurrentStop({required String otp}) async {
    if (!state.hasActiveRide) {
      state = state.copyWith(
        status: CarpoolSocketStatus.error,
        message: 'Start ride first before picking passengers.',
      );
      return;
    }

    final currentStop = state.currentStop;
    final String? fallbackBookingId =
        state.lastIncomingRequest?.bookingId.trim().isNotEmpty == true
        ? state.lastIncomingRequest!.bookingId.trim()
        : null;
    final pending = currentStop?.pendingBookingIds ?? const <String>[];
    final bookingId =
        _resolveBookingIdByPickupCoordinates(currentStop: currentStop) ??
        (pending.isNotEmpty ? pending.first : fallbackBookingId);
    if (bookingId == null || bookingId.isEmpty) {
      state = state.copyWith(
        status: CarpoolSocketStatus.error,
        message: 'No passenger booking found for this stop.',
      );
      return;
    }

    await pickPassengerByBookingId(bookingId: bookingId, otp: otp);
  }

  Future<bool> pickPassengerByBookingId({
    required String bookingId,
    required String otp,
  }) async {
    if (!state.hasActiveRide) {
      state = state.copyWith(
        status: CarpoolSocketStatus.error,
        message: 'Start ride first before picking passengers.',
      );
      return false;
    }

    final normalizedBookingId = bookingId.trim();
    if (normalizedBookingId.isEmpty) {
      state = state.copyWith(
        status: CarpoolSocketStatus.error,
        message: 'Passenger booking ID is missing.',
      );
      return false;
    }

    state = state.copyWith(
      status: CarpoolSocketStatus.loading,
      action: CarpoolSocketAction.ridePassengerPick,
      clearMessage: true,
    );

    final res = await _repository.pickPassenger(
      BookingOtpRequestParams(bookingId: normalizedBookingId, otp: otp),
    );

    return res.fold(
      (failure) {
        state = state.copyWith(
          status: CarpoolSocketStatus.error,
          message: failure.message,
        );
        return false;
      },
      (_) {
        final updatedStops = state.stopProgress
            .map((stop) {
              if (!stop.bookingIds.contains(normalizedBookingId) ||
                  stop.pickedBookingIds.contains(normalizedBookingId)) {
                return stop;
              }
              return stop.copyWith(
                pickedBookingIds: <String>[
                  ...stop.pickedBookingIds,
                  normalizedBookingId,
                ],
              );
            })
            .toList(growable: false);

        var nextIndex = state.currentStopIndex;
        if (updatedStops.isNotEmpty &&
            nextIndex >= 0 &&
            nextIndex < updatedStops.length &&
            updatedStops[nextIndex].pendingBookingIds.isEmpty &&
            nextIndex < updatedStops.length - 1) {
          nextIndex = nextIndex + 1;
        }

        state = state.copyWith(
          status: CarpoolSocketStatus.success,
          action: CarpoolSocketAction.ridePassengerPick,
          stopProgress: updatedStops,
          currentStopIndex: nextIndex,
          lastPickedBookingId: normalizedBookingId,
          message: 'Passenger picked successfully.',
        );
        return true;
      },
    );
  }

  void moveToNextStop() {
    if (state.stopProgress.isEmpty) {
      return;
    }
    final next = state.currentStopIndex + 1;
    if (next >= state.stopProgress.length) {
      return;
    }
    state = state.copyWith(currentStopIndex: next, clearMessage: true);
  }

  void clearIncomingRequests() {
    state = state.copyWith(clearIncomingRequests: true);
  }

  void clearRecoveredCarpoolState() {
    state = state.copyWith(
      action: CarpoolSocketAction.none,
      status: CarpoolSocketStatus.initial,
      activeCarpoolId: '',
      stopProgress: const <CarpoolStopProgress>[],
      currentStopIndex: 0,
      incomingRequests: const <CarpoolIncomingRequestEntity>[],
      acceptedRequests: const <CarpoolIncomingRequestEntity>[],
      clearIncomingRequest: true,
      clearRideResume: true,
      clearLastPickedBookingId: true,
      clearLastCancelledBookingId: true,
      clearMessage: true,
    );
  }

  int _normalizeCurrentStopIndex({
    required int currentIndex,
    required List<CarpoolStopProgress> stops,
  }) {
    if (stops.isEmpty) {
      return 0;
    }
    if (currentIndex < 0) {
      return 0;
    }
    if (currentIndex >= stops.length) {
      return stops.length - 1;
    }
    return currentIndex;
  }

  int _resolveCurrentStopIndex({
    required Map<String, dynamic> payload,
    required List<CarpoolStopProgress> stops,
  }) {
    if (stops.isEmpty) {
      return 0;
    }

    final currentStop = payload['currentStop'];
    final currentStopMap = currentStop is Map<String, dynamic>
        ? currentStop
        : currentStop is Map
        ? Map<String, dynamic>.from(currentStop)
        : null;
    final payloadIndex =
        _asInt(
          payload['currentStopIndex'] ??
              payload['currentIndex'] ??
              payload['routeStopIndex'] ??
              payload['nextStopIndex'],
        ) ??
        _asInt(currentStopMap?['order']);
    if (payloadIndex != null) {
      final normalized = payloadIndex > 0 ? payloadIndex - 1 : payloadIndex;
      return _normalizeCurrentStopIndex(currentIndex: normalized, stops: stops);
    }

    final currentRouteStopId = _extractRouteStopIdFromPayload(payload);
    if (currentRouteStopId != null) {
      final matchedIndex = stops.indexWhere(
        (stop) => stop.routeStopId == currentRouteStopId,
      );
      if (matchedIndex >= 0) {
        return matchedIndex;
      }
    }

    final firstPendingIndex = stops.indexWhere((stop) => !stop.isCompleted);
    if (firstPendingIndex >= 0) {
      return firstPendingIndex;
    }

    return _normalizeCurrentStopIndex(
      currentIndex: state.currentStopIndex,
      stops: stops,
    );
  }

  Map<String, dynamic> _extractPayload(Map<String, dynamic> source) {
    final data = _asMap(source['data']);
    final payload = _asMap(source['payload']);
    final route = _asMap(source['route']);
    final carpoolRoute =
        _asMap(data?['carpoolRoute']) ?? _asMap(source['carpoolRoute']);

    if (data == null &&
        payload == null &&
        route == null &&
        carpoolRoute == null) {
      return source;
    }

    return <String, dynamic>{
      ...source,
      ...?data,
      ...?payload,
      ...?route,
      ...?carpoolRoute,
      if (source['type'] != null) 'type': source['type'],
      if (source['role'] != null) 'role': source['role'],
      'carpoolId':
          carpoolRoute?['carpoolId'] ??
          data?['carpoolId'] ??
          source['carpoolId'] ??
          carpoolRoute?['_id'] ??
          source['_id'],
    };
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  String? _extractCarpoolId(Map<String, dynamic> payload) {
    final id =
        payload['carpoolId'] ??
        payload['rideId'] ??
        payload['id'] ??
        payload['_id'];
    if (id == null) return null;
    final value = id.toString().trim();
    return value.isEmpty ? null : value;
  }

  String? _extractBookingId(Map<String, dynamic> payload) {
    final id =
        payload['bookingId'] ??
        payload['booking_id'] ??
        payload['id'] ??
        payload['_id'];
    if (id == null) return null;
    final value = id.toString().trim();
    return value.isEmpty ? null : value;
  }

  String? _extractRouteStopIdFromPayload(Map<String, dynamic> payload) {
    final currentStop = payload['currentStop'];
    if (currentStop is Map<String, dynamic>) {
      return _extractRouteStopId(currentStop);
    }
    if (currentStop is Map) {
      return _extractRouteStopId(Map<String, dynamic>.from(currentStop));
    }

    final id =
        payload['routeStopId'] ??
        payload['currentRouteStopId'] ??
        payload['stopId'];
    if (id == null) {
      return null;
    }
    final value = id.toString().trim();
    return value.isEmpty ? null : value;
  }

  String _extractRideStatus(Map<String, dynamic> payload) {
    final raw =
        payload['status'] ??
        payload['rideStatus'] ??
        payload['carpoolStatus'] ??
        payload['type'];
    return raw?.toString().trim().toLowerCase() ?? '';
  }

  bool _hasActiveRideFromStatus(String normalizedStatus) {
    if (normalizedStatus == 'completed' ||
        normalizedStatus == 'cancelled' ||
        normalizedStatus == 'full' ||
        normalizedStatus == 'canceled') {
      return false;
    }
    if (normalizedStatus == 'open' || normalizedStatus == 'pending') {
      return false;
    }
    if (normalizedStatus == 'started' ||
        normalizedStatus == 'in-progress' ||
        normalizedStatus == 'in_progress' ||
        normalizedStatus == 'active' ||
        normalizedStatus == 'resume' ||
        normalizedStatus == 'resumed') {
      return true;
    }
    return state.hasActiveRide;
  }

  bool _isRideStartedFromStatus(String normalizedStatus) {
    if (normalizedStatus == 'completed' ||
        normalizedStatus == 'cancelled' ||
        normalizedStatus == 'canceled') {
      return false;
    }
    if (normalizedStatus == 'open' || normalizedStatus == 'pending') {
      return false;
    }
    if (normalizedStatus == 'started' ||
        normalizedStatus == 'in-progress' ||
        normalizedStatus == 'in_progress' ||
        normalizedStatus == 'active' ||
        normalizedStatus == 'resume' ||
        normalizedStatus == 'resumed') {
      return true;
    }
    return state.isRideStarted;
  }

  List<CarpoolStopProgress> _extractStopProgress(Map<String, dynamic> payload) {
    final dynamic rawStops = payload['stops'] ?? payload['routes'];
    if (rawStops is! List) {
      return <CarpoolStopProgress>[];
    }

    final routePassengers = _extractRoutePassengers(payload['passengers']);
    final startingPoint = _asMap(payload['startingPoint']);
    final destination = _asMap(payload['destination']);

    final List<CarpoolStopProgress> stops = <CarpoolStopProgress>[];
    for (var i = 0; i < rawStops.length; i++) {
      final rawStopValue = rawStops[i];
      if (rawStopValue is! Map) {
        continue;
      }
      final rawStop = Map<String, dynamic>.from(rawStopValue);
      if (_isEndpointStop(
        stop: rawStop,
        startingPoint: startingPoint,
        destination: destination,
      )) {
        continue;
      }

      final stopName =
          (rawStop['placeName'] ?? rawStop['name'] ?? 'Stop ${i + 1}')
              .toString();
      final order = _asInt(rawStop['order']) ?? (i + 1);
      final routeStopId = _extractRouteStopId(rawStop);
      final coordinates = _extractCoordinates(rawStop);
      final rawPassengers =
          rawStop['passengers'] ??
          rawStop['bookings'] ??
          _matchingPassengersForStop(
            passengers: routePassengers,
            stop: rawStop,
          );
      final rawPicked =
          rawStop['pickedPassengers'] ??
          rawStop['pickedBookings'] ??
          _matchingPassengersForStop(
            passengers: routePassengers,
            stop: rawStop,
            statuses: const <String>{
              'picked',
              'picked_up',
              'pickedup',
              'completed',
            },
          );
      final rawCancelled =
          rawStop['cancelledPassengers'] ??
          rawStop['cancelledBookings'] ??
          _matchingPassengersForStop(
            passengers: routePassengers,
            stop: rawStop,
            statuses: const <String>{'cancelled', 'canceled'},
          );

      stops.add(
        CarpoolStopProgress(
          order: order,
          stopName: stopName,
          routeStopId: routeStopId,
          coordinates: coordinates,
          requiresArrival: true,
          bookingIds: _extractBookingIds(rawPassengers),
          pickedBookingIds: _extractBookingIds(rawPicked),
          cancelledBookingIds: _extractBookingIds(rawCancelled),
        ),
      );
    }
    stops.sort((a, b) => a.order.compareTo(b.order));
    return stops;
  }

  List<CarpoolStopProgress> _syncStopArrivalState({
    required List<CarpoolStopProgress> stops,
    required int currentStopIndex,
  }) {
    if (stops.isEmpty) {
      return stops;
    }

    return stops
        .asMap()
        .entries
        .map(
          (entry) => entry.value.copyWith(
            hasArrived: entry.value.hasArrived || entry.key < currentStopIndex,
          ),
        )
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _extractRoutePassengers(dynamic rawPassengers) {
    if (rawPassengers is! List) {
      return const <Map<String, dynamic>>[];
    }
    return rawPassengers
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  List<CarpoolIncomingRequestEntity> _extractPendingRequests(
    Map<String, dynamic> payload,
  ) {
    return _extractRequestsByStatuses(
      payload,
      statuses: const <String>{'pending', 'requested', 'open'},
    );
  }

  List<CarpoolIncomingRequestEntity> _extractAcceptedRequests(
    Map<String, dynamic> payload,
  ) {
    return _extractRequestsByStatuses(
      payload,
      statuses: const <String>{'accepted', 'confirmed'},
    );
  }

  List<CarpoolIncomingRequestEntity> _extractRequestsByStatuses(
    Map<String, dynamic> payload, {
    required Set<String> statuses,
  }) {
    final passengers = payload['passengers'];
    if (passengers is! List) {
      return const <CarpoolIncomingRequestEntity>[];
    }

    final bookingLookup = _extractBookingLookup(payload['bookings']);
    final requests = <CarpoolIncomingRequestEntity>[];

    for (final item in passengers.whereType<Map>()) {
      final passenger = Map<String, dynamic>.from(item);
      final status = (passenger['status'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      if (!statuses.contains(status)) {
        continue;
      }

      final request = _buildIncomingRequestFromResumePassenger(
        passenger,
        bookingLookup: bookingLookup,
        payload: payload,
      );
      if (request != null) {
        requests.add(request);
      }
    }

    return requests;
  }

  Map<String, Map<String, dynamic>> _extractBookingLookup(dynamic rawBookings) {
    if (rawBookings is! List) {
      return const <String, Map<String, dynamic>>{};
    }

    final lookup = <String, Map<String, dynamic>>{};
    for (final item in rawBookings.whereType<Map>()) {
      final booking = Map<String, dynamic>.from(item);
      final id = (booking['id'] ?? booking['_id'] ?? booking['bookingId'] ?? '')
          .toString()
          .trim();
      if (id.isNotEmpty) {
        lookup[id] = booking;
      }
    }
    return lookup;
  }

  CarpoolIncomingRequestEntity? _buildIncomingRequestFromResumePassenger(
    Map<String, dynamic> passenger, {
    required Map<String, Map<String, dynamic>> bookingLookup,
    required Map<String, dynamic> payload,
  }) {
    final bookingId =
        (passenger['bookingId'] ??
                passenger['booking']?['id'] ??
                passenger['booking']?['_id'] ??
                '')
            .toString()
            .trim();
    if (bookingId.isEmpty) {
      return null;
    }

    final booking = bookingLookup[bookingId] ?? const <String, dynamic>{};
    final pickupStop = _normalizeStopMap(
      passenger['pickupStop'],
      fallback: payload['startingPoint'],
    );
    final dropOffStop = _normalizeStopMap(
      passenger['dropOffStop'],
      fallback: payload['destination'],
    );
    final rawUser = passenger['user'];
    final passengerId = rawUser is Map
        ? (rawUser['passengerId'] ??
                  rawUser['id'] ??
                  rawUser['_id'] ??
                  rawUser['userId'] ??
                  '')
              .toString()
              .trim()
        : rawUser?.toString().trim() ?? '';
    final passengerImage = rawUser is Map
        ? (rawUser['profilePicture'] ?? rawUser['image'] ?? '')
              .toString()
              .trim()
        : '';
    final passengerRating = rawUser is Map ? (rawUser['rating'] ?? 0) : 0;
    final passengerFirstName = rawUser is Map
        ? (rawUser['firstName']?.toString().trim() ?? '')
        : '';
    final passengerLastName = rawUser is Map
        ? (rawUser['lastName']?.toString().trim() ?? '')
        : '';
    return CarpoolIncomingRequestModel(
      bookingId: bookingId,
      passenger: PassengerModel(
        passengerId: passengerId,
        firstName: passengerFirstName.isNotEmpty
            ? passengerFirstName
            : 'Passenger',
        lastName: passengerLastName,
        image: passengerImage,
        rating: passengerRating,
      ),
      pickupStop: CarpoolStopModel.fromJson(pickupStop),
      dropOffStop: CarpoolStopModel.fromJson(dropOffStop),
      requiredSeats:
          _asInt(
            passenger['requiredSeats'] ??
                passenger['seats'] ??
                booking['requiredSeats'] ??
                booking['seats'],
          ) ??
          1,
      fareCharged:
          _asDouble(
            passenger['fareCharged'] ??
                passenger['fare'] ??
                passenger['price'] ??
                booking['fareCharged'] ??
                booking['fare'] ??
                booking['price'],
          ) ??
          0,
      distance: _asDouble(
        passenger['distance'] ??
            // passenger['totalDistance'] ??
            // passenger['rideDistance'] ??
            booking['distance'],

        // booking['totalDistance'] ??
        // booking['rideDistance']
      ),
    );
  }

  Map<String, dynamic> _normalizeStopMap(dynamic rawStop, {dynamic fallback}) {
    if (rawStop is Map<String, dynamic>) {
      return rawStop;
    }
    if (rawStop is Map) {
      return Map<String, dynamic>.from(rawStop);
    }
    if (fallback is Map<String, dynamic>) {
      return fallback;
    }
    if (fallback is Map) {
      return Map<String, dynamic>.from(fallback);
    }
    return const <String, dynamic>{};
  }

  List<Map<String, dynamic>> _matchingPassengersForStop({
    required List<Map<String, dynamic>> passengers,
    required Map<String, dynamic> stop,
    Set<String>? statuses,
  }) {
    final stopId = _extractRouteStopId(stop);
    final stopOrder = _asInt(stop['order']);
    final stopCoordinates = _extractCoordinates(stop);

    return passengers
        .where((passenger) {
          final status = (passenger['status'] ?? '')
              .toString()
              .trim()
              .toLowerCase();
          if (statuses != null && !statuses.contains(status)) {
            return false;
          }

          final pickupStopRaw = passenger['pickupStop'];
          if (pickupStopRaw is! Map) {
            return false;
          }
          final pickupStop = Map<String, dynamic>.from(pickupStopRaw);
          final pickupStopId = _extractRouteStopId(pickupStop);
          if (stopId != null &&
              pickupStopId != null &&
              stopId == pickupStopId) {
            return true;
          }

          final pickupOrder = _asInt(pickupStop['order']);
          if (stopOrder != null &&
              pickupOrder != null &&
              stopOrder == pickupOrder) {
            return true;
          }

          final pickupCoordinates = _extractCoordinates(pickupStop);
          return _samePoint(stopCoordinates, pickupCoordinates);
        })
        .toList(growable: false);
  }

  bool _isEndpointStop({
    required Map<String, dynamic> stop,
    required Map<String, dynamic>? startingPoint,
    required Map<String, dynamic>? destination,
  }) {
    return _matchesStopReference(stop, startingPoint) ||
        _matchesStopReference(stop, destination);
  }

  bool _matchesStopReference(
    Map<String, dynamic> stop,
    Map<String, dynamic>? reference,
  ) {
    if (reference == null || reference.isEmpty) {
      return false;
    }

    final stopId = _extractRouteStopId(stop);
    final referenceId = _extractRouteStopId(reference);
    if (stopId != null && referenceId != null && stopId == referenceId) {
      return true;
    }

    final stopOrder = _asInt(stop['order']);
    final referenceOrder = _asInt(reference['order']);
    if (stopOrder != null &&
        referenceOrder != null &&
        stopOrder == referenceOrder) {
      return true;
    }

    return _samePoint(
      _extractCoordinates(stop),
      _extractCoordinates(reference),
    );
  }

  List<String> _extractBookingIds(dynamic rawItems) {
    if (rawItems is! List) {
      return <String>[];
    }
    final ids = <String>[];
    for (final item in rawItems) {
      if (item is String && item.trim().isNotEmpty) {
        ids.add(item.trim());
        continue;
      }
      if (item is Map<String, dynamic>) {
        final id = item['bookingId'] ?? item['id'] ?? item['_id'];
        if (id != null && id.toString().trim().isNotEmpty) {
          ids.add(id.toString().trim());
        }
      }
    }
    return ids;
  }

  String? _resolveBookingIdByPickupCoordinates({
    required CarpoolStopProgress? currentStop,
  }) {
    if (currentStop == null || !_hasValidCoordinates(currentStop.coordinates)) {
      return null;
    }

    final candidates = state.acceptedRequests.isNotEmpty
        ? state.acceptedRequests
        : state.incomingRequests;
    if (candidates.isEmpty) {
      return null;
    }

    final pendingAtStop = currentStop.pendingBookingIds;
    for (final request in candidates) {
      if (!_samePoint(
        currentStop.coordinates,
        request.pickupStop.coordinates,
      )) {
        continue;
      }
      final bookingId = request.bookingId.trim();
      if (bookingId.isEmpty) {
        continue;
      }
      if (pendingAtStop.isEmpty || pendingAtStop.contains(bookingId)) {
        return bookingId;
      }
    }
    return null;
  }

  List<double> _extractCoordinates(Map<String, dynamic> stop) {
    final raw = stop['location']?['coordinates'] ?? stop['coordinates'];
    if (raw is! List || raw.length < 2) {
      return const <double>[];
    }

    final longitude = _asDouble(raw[0]);
    final latitude = _asDouble(raw[1]);
    if (latitude == null || longitude == null) {
      return const <double>[];
    }
    return <double>[longitude, latitude];
  }

  String? _extractRouteStopId(Map<String, dynamic> rawStop) {
    final id =
        rawStop['routeStopId'] ??
        rawStop['stopId'] ??
        rawStop['id'] ??
        rawStop['_id'];
    if (id == null) {
      return null;
    }
    final value = id.toString().trim();
    return value.isEmpty ? null : value;
  }

  String? _resolveCurrentCarpoolId() {
    final fromState = state.activeCarpoolId?.trim();
    if (fromState != null && fromState.isNotEmpty) {
      return fromState;
    }

    final payload = state.lastRideResume ?? const <String, dynamic>{};
    final id =
        payload['carpoolId'] ??
        payload['rideId'] ??
        payload['id'] ??
        payload['_id'];
    if (id == null) {
      return null;
    }

    final normalized = id.toString().trim();
    return normalized.isEmpty ? null : normalized;
  }

  String? _extractCarpoolIdFromCreateAck(String rawMessage) {
    if (rawMessage.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawMessage);
      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        final nestedRoute = data is Map<String, dynamic>
            ? data['carpoolRoute']
            : data is Map
            ? Map<String, dynamic>.from(data)['carpoolRoute']
            : null;
        final id =
            decoded['carpoolId'] ??
            decoded['rideId'] ??
            decoded['id'] ??
            decoded['_id'] ??
            (data is Map<String, dynamic> ? data['carpoolId'] : null) ??
            (data is Map
                ? Map<String, dynamic>.from(data)['carpoolId']
                : null) ??
            (nestedRoute is Map<String, dynamic> ? nestedRoute['_id'] : null) ??
            (nestedRoute is Map
                ? Map<String, dynamic>.from(nestedRoute)['_id']
                : null);
        if (id != null) {
          final text = id.toString().trim();
          if (text.isNotEmpty) {
            return text;
          }
        }
      }
    } catch (_) {}

    final idMatch = RegExp(r'\b[a-fA-F0-9]{24}\b').firstMatch(rawMessage);
    return idMatch?.group(0)?.trim();
  }

  Map<String, dynamic>? _decodeAckPayload(String rawMessage) {
    if (rawMessage.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawMessage);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}

    return null;
  }

  Map<String, dynamic>? _updateRideResumeStatus(
    Map<String, dynamic>? payload, {
    required String status,
    String? type,
  }) {
    if (payload == null || payload.isEmpty) {
      return payload;
    }

    final updated = Map<String, dynamic>.from(payload)
      ..['status'] = status
      ..['type'] = type ?? status;

    final nestedRoute = payload['carpoolRoute'];
    if (nestedRoute is Map<String, dynamic>) {
      updated['carpoolRoute'] = Map<String, dynamic>.from(nestedRoute)
        ..['status'] = status;
    } else if (nestedRoute is Map) {
      updated['carpoolRoute'] = Map<String, dynamic>.from(nestedRoute)
        ..['status'] = status;
    }

    return updated;
  }

  Map<String, dynamic>? _mergeRideResumePayload(
    Map<String, dynamic>? existing,
    Map<String, dynamic> incoming,
  ) {
    if (existing == null || existing.isEmpty) {
      return incoming;
    }
    return <String, dynamic>{...existing, ...incoming};
  }

  Map<String, dynamic>? _markPassengerStatusInRideResume(
    Map<String, dynamic>? payload, {
    required String bookingId,
    required String status,
  }) {
    if (payload == null || payload.isEmpty || bookingId.isEmpty) {
      return payload;
    }

    var updatedPayload = Map<String, dynamic>.from(payload);
    var updatedAny = false;

    final passengers = payload['passengers'];
    if (passengers is List) {
      final updatedPassengers = passengers
          .map((item) {
            if (item is! Map) {
              return item;
            }

            final passenger = Map<String, dynamic>.from(item);
            final passengerBookingId =
                (passenger['bookingId'] ??
                        passenger['booking']?['id'] ??
                        passenger['booking']?['_id'] ??
                        '')
                    .toString()
                    .trim();
            if (passengerBookingId != bookingId) {
              return passenger;
            }

            updatedAny = true;
            return <String, dynamic>{...passenger, 'status': status};
          })
          .toList(growable: false);
      updatedPayload['passengers'] = updatedPassengers;
    }

    final bookings = payload['bookings'];
    if (bookings is List) {
      final updatedBookings = bookings
          .map((item) {
            if (item is! Map) {
              return item;
            }

            final booking = Map<String, dynamic>.from(item);
            final currentBookingId =
                (booking['bookingId'] ?? booking['id'] ?? booking['_id'] ?? '')
                    .toString()
                    .trim();
            if (currentBookingId != bookingId) {
              return booking;
            }

            updatedAny = true;
            return <String, dynamic>{...booking, 'status': status};
          })
          .toList(growable: false);
      updatedPayload['bookings'] = updatedBookings;
    }

    if (!updatedAny) {
      return payload;
    }

    return updatedPayload;
  }

  List<CarpoolStopProgress> _withCancelledBookingMarked({
    required List<CarpoolStopProgress> stops,
    required String bookingId,
  }) {
    final trimmedBookingId = bookingId.trim();
    if (trimmedBookingId.isEmpty) {
      return stops;
    }

    return stops
        .map((stop) {
          if (!stop.bookingIds.contains(trimmedBookingId) ||
              stop.cancelledBookingIds.contains(trimmedBookingId)) {
            return stop;
          }
          return stop.copyWith(
            cancelledBookingIds: <String>[
              ...stop.cancelledBookingIds,
              trimmedBookingId,
            ],
          );
        })
        .toList(growable: false);
  }

  Map<String, dynamic> _buildCreatedRoutePayload({
    required CarpoolRideParams params,
    String? carpoolId,
  }) {
    final routeJson = params.toJson();
    final routes = (routeJson['routes'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);

    return <String, dynamic>{
      'type': 'open',
      'status': 'open',
      if (carpoolId != null && carpoolId.isNotEmpty) 'carpoolId': carpoolId,
      if (carpoolId != null && carpoolId.isNotEmpty) '_id': carpoolId,
      'avgTime': routeJson['avgTime'],
      'distance': routeJson['distance'],
      'availableSeats': params.maxPassengers,
      'maxPassengers': params.maxPassengers,
      'graceTime': routeJson['graceTime'],
      'routes': routes
          .asMap()
          .entries
          .map((entry) {
            final route = entry.value;
            return <String, dynamic>{
              ...route,
              'status': 'pending',
              '_id':
                  route['_id'] ??
                  route['id'] ??
                  route['routeStopId'] ??
                  'local_route_stop_${entry.key + 1}',
            };
          })
          .toList(growable: false),
      'startingPoint': routeJson['startingPoint'],
      'destination': routeJson['destination'],
      'passengers': const <Map<String, dynamic>>[],
    };
  }

  bool _hasValidCoordinates(List<double> coordinates) {
    return coordinates.length >= 2;
  }

  bool _samePoint(List<double> first, List<double> second) {
    if (first.length < 2 || second.length < 2) {
      return false;
    }
    const epsilon = 0.0001;
    return (first[0] - second[0]).abs() <= epsilon &&
        (first[1] - second[1]).abs() <= epsilon;
  }

  bool _isPaymentFailureMessage(String message) {
    final normalized = message.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return normalized.contains('card was declined') ||
        normalized.contains('card_declined') ||
        normalized.contains('payment_failed') ||
        normalized.contains('payment failed');
  }

  void _markBookingAsCancelled(String bookingId, {String? message}) {
    final trimmedBookingId = bookingId.trim();
    if (trimmedBookingId.isEmpty) {
      return;
    }

    final updatedStops = _withCancelledBookingMarked(
      stops: state.stopProgress,
      bookingId: trimmedBookingId,
    );
    final updatedRideResume = _markPassengerStatusInRideResume(
      state.lastRideResume,
      bookingId: trimmedBookingId,
      status: 'cancelled',
    );

    state = state.copyWith(
      status: CarpoolSocketStatus.success,
      action: CarpoolSocketAction.ridePassengerPick,
      stopProgress: updatedStops,
      incomingRequests: state.incomingRequests
          .where((item) => item.bookingId != trimmedBookingId)
          .toList(growable: false),
      acceptedRequests: state.acceptedRequests
          .where((item) => item.bookingId != trimmedBookingId)
          .toList(growable: false),
      lastRideResume: updatedRideResume,
      lastCancelledBookingId: trimmedBookingId,
      message: message ?? state.message,
    );
  }

  void _markBookingAsCompleted(String bookingId, {String? message}) {
    final trimmedBookingId = bookingId.trim();
    if (trimmedBookingId.isEmpty) {
      return;
    }

    final updatedRideResume = _markPassengerStatusInRideResume(
      state.lastRideResume,
      bookingId: trimmedBookingId,
      status: 'completed',
    );

    state = state.copyWith(
      status: CarpoolSocketStatus.success,
      action: CarpoolSocketAction.ridePassengerDrop,
      incomingRequests: state.incomingRequests
          .where((item) => item.bookingId != trimmedBookingId)
          .toList(growable: false),
      acceptedRequests: state.acceptedRequests
          .where((item) => item.bookingId != trimmedBookingId)
          .toList(growable: false),
      lastRideResume: updatedRideResume,
      message: message ?? state.message,
    );
  }

  int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  double? _asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.trim());
    }
    return null;
  }
}
