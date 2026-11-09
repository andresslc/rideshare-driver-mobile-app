import 'dart:async';
import 'package:driver_app/core/core.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';
import 'package:driver_app/features/ride_room/presentation/providers/ride_provider.dart';
import 'package:driver_app/features/ride_room/presentation/states/ride_state.dart';
import 'package:driver_app/features/ride_room/presentation/widgets/ride_request_widget.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:driver_app/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RideRequestScreen extends ConsumerStatefulWidget {
  /// Ride carried by the new-request push (`metadata.id`). Its card is pinned
  /// to the top and highlighted, so tapping the notification lands on that
  /// request instead of on the queue in general.
  final String? focusRideId;

  const RideRequestScreen({super.key, this.focusRideId});

  @override
  ConsumerState<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends ConsumerState<RideRequestScreen>
    with WidgetsBindingObserver {
  Timer? _pollTimer;
  bool _isHandlingOfflineMismatch = false;
  int _offlineErrorCount = 0;
  static const int _maxOfflineRetries = 3;
  Set<String> _knownRideIds = const <String>{};

  /// Cleared once the highlighted request leaves the queue.
  String? _focusRideId;

  // 🔹 Polling configuration
  static const Duration _basePollInterval = Duration(seconds: 10);
  static const Duration _maxPollInterval = Duration(seconds: 30);
  Duration _currentPollInterval = _basePollInterval;

  @override
  void initState() {
    super.initState();
    final String focusId = widget.focusRideId?.trim() ?? '';
    _focusRideId = focusId.isEmpty ? null : focusId;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPolling(immediate: true);
    });
  }

  @override
  void didUpdateWidget(covariant RideRequestScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusRideId == widget.focusRideId) return;
    final String focusId = widget.focusRideId?.trim() ?? '';
    setState(() => _focusRideId = focusId.isEmpty ? null : focusId);
  }

  /// Drops the highlight once the request it pointed at leaves the queue.
  /// Only fires after the ride has actually been seen, so a push that arrives
  /// before the first sync still highlights its card.
  void _syncFocusRide(RideSocketState? previous, RideSocketState next) {
    final String? focusId = _focusRideId;
    if (focusId == null) return;

    bool contains(List<RideEntity>? rides) =>
        rides?.any((ride) => ride.id.trim() == focusId) ?? false;

    if (!contains(previous?.incomingRides)) return;
    if (contains(next.incomingRides)) return;

    setState(() => _focusRideId = null);
  }

  /// Puts the request that came from the push first, so it is the card the
  /// driver sees on arrival.
  List<RideEntity> _orderedRides(List<RideEntity> rides) {
    final String? focusId = _focusRideId;
    if (focusId == null || rides.length < 2) return rides;

    final int index = rides.indexWhere((ride) => ride.id.trim() == focusId);
    if (index <= 0) return rides;

    return <RideEntity>[
      rides[index],
      ...rides.where((ride) => ride.id.trim() != focusId),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _currentPollInterval = _basePollInterval;
      _startPolling(immediate: true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopPolling();
    }
  }

  void _startPolling({bool immediate = false}) {
    _stopPolling();

    if (immediate) {
      unawaited(_refreshRideRequests());
    }

    _pollTimer = Timer.periodic(_currentPollInterval, (_) {
      if (!mounted) return;
      unawaited(_refreshRideRequests());
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _refreshRideRequests() async {
    final rideState = ref.read(rideSocketProvider);

    // 🔹 Optimization: Checking provider state directly instead of local bool
    final bool isAlreadyRefreshing =
        rideState.status == SocketStatus.loading &&
        rideState.action == SocketAction.availableRides;
    if (isAlreadyRefreshing || !mounted) return;

    try {
      await ref.read(rideSocketProvider.notifier).availableRides();
      if (!mounted) return;

      final rideState = ref.read(rideSocketProvider);
      if (rideState.status != SocketStatus.error) {
        // Reset counters on success
        _offlineErrorCount = 0;
        if (_currentPollInterval != _basePollInterval) {
          _currentPollInterval = _basePollInterval;
          _startPolling();
        }
      } else {
        _handleRefreshError();
      }
    } catch (_) {
      _handleRefreshError();
    }
  }

  void _handleRefreshError() {
    if (_currentPollInterval < _maxPollInterval) {
      _currentPollInterval = Duration(
        seconds: (_currentPollInterval.inSeconds * 1.5).toInt(),
      );
      _startPolling();
    }
  }

  Future<void> _acceptRideSafely(RideEntity ride) async {
    final rideId = ride.id.trim();
    if (rideId.isEmpty) {
      context.showToast(context.l10n.ride_request_unavailable);
      return;
    }

    final acceptingRideId = ref.read(rideSocketProvider).acceptingRideId;
    if (acceptingRideId != null) return;

    try {
      final currentRides = ref.read(rideSocketProvider).incomingRides;
      if (!currentRides.any((item) => item.id == rideId)) {
        await _refreshRideRequests();
        if (!mounted) return;

        if (!ref
            .read(rideSocketProvider)
            .incomingRides
            .any((item) => item.id == rideId)) {
          context.showToast(context.l10n.ride_request_unavailable);
          return;
        }
      }

      await ref
          .read(rideSocketProvider.notifier)
          .acceptRideRequest(rideId, ride: ride);
    } catch (_) {
      // Logic handled globally in provider
    }
  }

  bool _isDriverOfflineMessage(String? message) {
    final normalized = message?.trim().toLowerCase() ?? '';
    return normalized.contains('driver_is_offline') ||
        normalized.contains('driver is offline') ||
        normalized.contains('you are offline right now');
  }

  Future<void> _handleDriverOfflineMismatch(String? message) async {
    if (_isHandlingOfflineMismatch || !mounted) return;
    _isHandlingOfflineMismatch = true;

    try {
      final rideState = ref.read(rideSocketProvider);
      final bool hasActiveBusiness = rideState.incomingRides.isNotEmpty;

      _offlineErrorCount++;
      log(
        '⚠️ DRIVER_IS_OFFLINE detected (Attempt $_offlineErrorCount/$_maxOfflineRetries, ActiveBusiness: $hasActiveBusiness)',
        name: 'RideRequestScreen',
      );

      if (_offlineErrorCount < _maxOfflineRetries || hasActiveBusiness) {
        log(
          '🛠 Attempting self-healing: Forcing location sync...',
          name: 'RideRequestScreen',
        );
        try {
          await ref.read(rideSocketProvider.notifier).toggleDriverOnline(true);
          if (!mounted) return;

          await ref.read(rideSocketProvider.notifier).syncCurrentLocation();
          if (!mounted) return;

          await Future.delayed(const Duration(milliseconds: 1000));
          if (!mounted) return;

          if (hasActiveBusiness && _offlineErrorCount >= _maxOfflineRetries) {
            _offlineErrorCount = 0;
          }

          log(
            '🔄 Retrying availableRides polling...',
            name: 'RideRequestScreen',
          );
          await _refreshRideRequests();
          return;
        } catch (e) {
          log(
            '❌ Self-healing location sync failed: $e',
            name: 'RideRequestScreen',
          );
          return;
        }
      }

      _stopPolling();
      if (!mounted) return;

      final String fallbackMessage = message?.trim().isNotEmpty == true
          ? message!.trim()
          : context.l10n.ride_request_offline_toast;

      context.showToast(fallbackMessage);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final router = AppRouter.router;
        if (router.canPop()) {
          router.pop();
        } else {
          router.goNamed(Routes.home.name);
        }
      });
    } finally {
      _isHandlingOfflineMismatch = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // 🔹 Reactive watchers: No local setState needed!
    final bool isRefreshing = ref.watch(
      rideSocketProvider.select(
        (s) =>
            s.status == SocketStatus.loading &&
            s.action == SocketAction.availableRides,
      ),
    );
    final DateTime? lastSyncAt = ref.watch(
      rideSocketProvider.select((s) => s.lastSyncAt),
    );
    final incomingRides = ref.watch(
      rideSocketProvider.select((s) => s.incomingRides),
    );
    final isOnline = ref.watch(rideSocketProvider.select((s) => s.isOnline));
    final List<RideEntity> orderedRides = _orderedRides(incomingRides);

    ref.listen<RideSocketState>(rideSocketProvider, (previous, next) {
      _triggerHapticOnNewRide(previous, next);
      _syncFocusRide(previous, next);

      // Losing a ride is the normal outcome of ring dispatch, so it gets a
      // discreet notice and nothing else: the card is already gone and the
      // queue was repainted from the event.
      if (next.action == SocketAction.rideRequestTaken &&
          previous?.incomingRides != next.incomingRides) {
        final String message = next.message?.trim().isNotEmpty == true
            ? next.message!.trim()
            : l10n.ride_request_taken_toast;
        context.showToast(message);
      }

      if (next.action == SocketAction.rideRequestExpired &&
          previous?.action != SocketAction.rideRequestExpired) {
        context.showToast(l10n.ride_request_expired_toast);
      }

      // Shift limit reached: the driver was put offline, so say why.
      if (next.action == SocketAction.shiftExceeded &&
          previous?.action != SocketAction.shiftExceeded &&
          next.message?.trim().isNotEmpty == true) {
        context.showWarningToast(next.message!.trim());
      }

      if (next.status == SocketStatus.success) {
        final String statusStr = (next.ride?.rideStatus ?? '')
            .trim()
            .toLowerCase();

        // Only navigate to Ride Room if the ride is actually 'accepted'
        final bool shouldOpenRoom =
            next.ride != null &&
            statusStr == 'accepted' &&
            (next.action == SocketAction.rideRequestAccept ||
                next.action == SocketAction.rideStatusUpdate);

        if (shouldOpenRoom) {
          AppRouter.router.goNamed(Routes.rideRoom.name);
        }
      } else if (next.status == SocketStatus.error) {
        if (next.action == SocketAction.availableRides &&
            _isDriverOfflineMessage(next.message)) {
          // 🔹 Trigger the healing loop (location sync + retry)
          _handleDriverOfflineMismatch(next.message);
        } else if (next.action == SocketAction.rideRequestAccept &&
            next.message != null) {
          if (!mounted) return;
          context.showToast(next.message!);
        }
      }
    });

    final String refreshLabel = isRefreshing
        ? l10n.ride_request_refreshing_queue_label
        : lastSyncAt == null
        ? l10n.ride_request_syncing_queue_label
        : l10n.ride_request_updated_label(lastSyncAt.timeAgo);

    return AppScaffold(
      padding: EdgeInsets.zero,
      scrollable: false,
      whichBackground: ScaffoldBackgroundType.doubleShadow,
      appBar: AppBar(
        title: Text(
          l10n.ride_request,
        ).animate().fade(duration: 400.ms).slideY(begin: -0.2, end: 0),

        centerTitle: true,
        actions: [
          IconButton(
            onPressed: isRefreshing ? null : _refreshRideRequests,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isRefreshing
                  ? SizedBox(
                      key: const ValueKey('refreshing'),
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.appColors.brand,
                      ),
                    )
                  : Icon(
                      Icons.refresh_rounded,
                      key: const ValueKey('idle'),
                      color: context.appColors.textPrimary,
                    ),
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p11),
        child: RefreshIndicator(
          color: context.appColors.brand,
          onRefresh: _refreshRideRequests,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RideRequestsHeroCard(
                          requestCount: incomingRides.length,
                          isOnline: isOnline,
                          isRefreshing: isRefreshing,
                          refreshLabel: refreshLabel,
                        )
                        .animate()
                        .fade(duration: 350.ms)
                        .slideY(begin: 0.15, end: 0),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              incomingRides.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: _RideRequestsEmptyState(isOnline: isOnline)
                          .animate()
                          .fade(duration: 400.ms)
                          .scale(begin: const Offset(0.95, 0.95)),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final ride = orderedRides[index];
                        return Padding(
                          key: ValueKey('padding_${ride.id}'),
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _AnimatedRideRequestTile(
                            key: ValueKey('tile_${ride.id}'),
                            index: index,
                            child:
                                RideRequestCard(
                                      key: ValueKey('card_${ride.id}'),
                                      ride: ride,
                                      isHighlighted:
                                          ride.id.trim() == _focusRideId,
                                      onAccept: () => _acceptRideSafely(ride),
                                    )
                                    .animate(delay: (index * 120).ms)
                                    .fade(duration: 350.ms)
                                    .slideY(begin: 0.2, end: 0),
                          ),
                        );
                      }, childCount: orderedRides.length),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on _RideRequestScreenState {
  void _triggerHapticOnNewRide(
    RideSocketState? previous,
    RideSocketState next,
  ) {
    if (next.status != SocketStatus.success) return;
    final Set<String> nextIds = next.incomingRides
        .map((r) => r.id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    final Set<String> baselineIds =
        (previous?.incomingRides ?? const [])
            .map((r) => r.id.trim())
            .where((id) => id.isNotEmpty)
            .toSet()
          ..addAll(_knownRideIds);
    if (nextIds.difference(baselineIds).isNotEmpty) {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
    }
    _knownRideIds = nextIds;
  }
}

class _RideRequestsHeroCard extends StatelessWidget {
  const _RideRequestsHeroCard({
    required this.requestCount,
    required this.isOnline,
    required this.isRefreshing,
    required this.refreshLabel,
  });
  final int requestCount;
  final bool isOnline;
  final bool isRefreshing;
  final String refreshLabel;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bool hasRequests = requestCount > 0;
    final String title = l10n.ride_request_live_title(requestCount);
    final String subtitle = hasRequests
        ? l10n.ride_request_live_subtitle
        : isOnline
        ? l10n.ride_request_ready_subtitle
        : l10n.ride_request_go_online_subtitle;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.appColors.brand.withValues(
                alpha: context.isDark ? 0.24 : 0.16,
              ),
              context.appColors.fieldFill.withValues(
                alpha: context.isDark ? 0.88 : 0.98,
              ),
              context.appColors.fieldFill.withValues(
                alpha: context.isDark ? 0.96 : 1,
              ),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: context.appColors.brand.withValues(alpha: 0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: context.appColors.shadow.withValues(alpha: 0.12),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -18,
              right: -10,
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.appColors.brand.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              bottom: -28,
              left: -14,
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.appColors.brand.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _QueueStatusPill(
                        label: isRefreshing
                            ? l10n.ride_request_status_live_sync
                            : l10n.ride_request_status_newest_first,
                        isHighlighted: hasRequests || isRefreshing,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.appColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _QueueInfoChip(
                        icon: Icons.bolt_rounded,
                        label: refreshLabel,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueStatusPill extends StatelessWidget {
  const _QueueStatusPill({required this.label, required this.isHighlighted});
  final String label;
  final bool isHighlighted;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? context.appColors.brand.withValues(alpha: 0.16)
            : context.appColors.fieldFill.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isHighlighted
              ? context.appColors.brand.withValues(alpha: 0.28)
              : context.appColors.border,
        ),
      ),
      child: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: isHighlighted
              ? context.appColors.brand
              : context.appColors.textPrimary,
        ),
      ),
    );
  }
}

class _QueueInfoChip extends StatelessWidget {
  const _QueueInfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return AppGradientBox(
      cornerRadius: 16,
      enableBackdropBlur: false,
      borderWidth: context.isDark ? 1.0 : 0.6,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: context.appColors.brand),
          const SizedBox(width: 8),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _RideRequestsEmptyState extends StatelessWidget {
  const _RideRequestsEmptyState({required this.isOnline});
  final bool isOnline;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final String title = isOnline
        ? l10n.ride_request_empty_title_online
        : l10n.ride_request_empty_title_offline;
    final String subtitle = isOnline
        ? l10n.ride_request_empty_subtitle_online
        : l10n.ride_request_empty_subtitle_offline;
    return Padding(
      padding: EdgeInsets.only(top: context.screenHeight * 0.08),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.appColors.fieldFill.withValues(
                alpha: context.isDark ? 0.34 : 0.96,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.appColors.border),
            ),
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.92, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.appColors.brand.withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      isOnline
                          ? Icons.local_taxi_rounded
                          : Icons.power_settings_new_rounded,
                      size: 34,
                      color: context.appColors.brand,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.appColors.textSecondary,
                    height: 1.45,
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

class _AnimatedRideRequestTile extends StatelessWidget {
  const _AnimatedRideRequestTile({
    super.key,
    required this.index,
    required this.child,
  });
  final int index;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final int delay = index * 70;
    final int durationMs = 320 + (delay > 280 ? 280 : delay);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        final double translateY = (1 - value) * 22;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: child,
          ),
        );
      },
    );
  }
}
