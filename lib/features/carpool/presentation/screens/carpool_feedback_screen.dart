import 'package:driver_app/core/constants/app_images.dart';
import 'package:driver_app/core/constants/app_sizes.dart';
import 'package:driver_app/core/core.dart';
import 'package:driver_app/core/params/feedback_params.dart';
import 'package:driver_app/features/carpool/domain/entities/carpool_entity.dart';
import 'package:driver_app/features/carpool/domain/entities/view_carpool_passenger_entity.dart';
import 'package:driver_app/features/carpool/domain/usecases/carpool_usecase.dart';
import 'package:driver_app/features/carpool/presentation/providers/carpool_socket_provider.dart';
import 'package:driver_app/features/reviews/domain/use_case/feedback_usecase.dart';
import 'package:driver_app/shared/screens/success_screen.dart';
import 'package:driver_app/shared/widgets/app_button.dart';
import 'package:driver_app/shared/widgets/app_scaffold.dart';
import 'package:driver_app/shared/widgets/ride_driver_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class CarpoolFeedbackArgs {
  const CarpoolFeedbackArgs({
    required this.rideId, // carpoolId
    required this.passengers,
  });

  final String rideId; // carpoolId
  final List<CarpoolIncomingRequestEntity> passengers;
}

class CarpoolFeedbackScreen extends ConsumerStatefulWidget {
  const CarpoolFeedbackScreen({super.key, required this.args});

  final CarpoolFeedbackArgs args;

  @override
  ConsumerState<CarpoolFeedbackScreen> createState() =>
      _CarpoolFeedbackScreenState();
}

class _CarpoolFeedbackScreenState extends ConsumerState<CarpoolFeedbackScreen> {
  final FeedBackUseCase _feedbackUseCase = locator<FeedBackUseCase>();
  final ViewPassengerUseCase _viewPassengerUseCase =
      locator<ViewPassengerUseCase>();
  final Map<String, int> _ratings = <String, int>{};
  bool _isSubmitting = false;
  bool _isLoadingPassengers = false;
  List<_FeedbackPassenger> _fetchedPassengers = const <_FeedbackPassenger>[];

  @override
  void initState() {
    super.initState();
    _loadPassengersIfNeeded();
  }

  List<_FeedbackPassenger> get _initialPassengers {
    final seen = <String>{};
    final unique = <_FeedbackPassenger>[];

    for (final passenger in widget.args.passengers) {
      final mapped = _FeedbackPassenger.fromIncomingRequest(passenger);
      final key = mapped.id;
      if (key.isEmpty || !seen.add(key)) {
        continue;
      }
      unique.add(mapped);
    }

    return unique;
  }

  List<_FeedbackPassenger> get _passengers {
    return _initialPassengers.isNotEmpty
        ? _initialPassengers
        : _fetchedPassengers;
  }

  Future<void> _loadPassengersIfNeeded() async {
    if (_initialPassengers.isNotEmpty) {
      return;
    }

    final carpoolId = widget.args.rideId.trim();
    if (carpoolId.isEmpty) {
      return;
    }

    setState(() => _isLoadingPassengers = true);
    final result = await _viewPassengerUseCase.call(carpoolId);

    if (!mounted) {
      return;
    }

    result.fold(
      (_) {
        setState(() => _isLoadingPassengers = false);
      },
      (passengers) {
        final seen = <String>{};
        final mapped = passengers
            .map(_FeedbackPassenger.fromViewPassenger)
            .where(
              (passenger) => passenger.id.isNotEmpty && seen.add(passenger.id),
            )
            .toList(growable: false);
        setState(() {
          _fetchedPassengers = mapped;
          _isLoadingPassengers = false;
        });
      },
    );
  }

  void _goHome() {
    ref.read(carpoolSocketProvider.notifier).clearRecoveredCarpoolState();
    context.goNamed(Routes.home.name);
  }

  Future<void> _submitRatings() async {
    final l10n = context.l10n;
    final carpoolId = widget.args.rideId.trim();
    final passengers = _passengers;

    if (carpoolId.isEmpty || passengers.isEmpty) {
      _goHome();
      return;
    }

    final missingRating = passengers.any((passenger) {
      return (_ratings[passenger.id] ?? 0) <= 0;
    });
    if (missingRating) {
      context.showToast(l10n.rate_all_passengers_or_skip);
      return;
    }

    setState(() => _isSubmitting = true);

    for (final passenger in passengers) {
      final receiveId = passenger.id;
      final stars = _ratings[passenger.id] ?? 0;
      if (receiveId.isEmpty || stars <= 0) {
        continue;
      }

      final result = await _feedbackUseCase.call(
        FeedbackParam(
          receiveId: receiveId,
          receiverType: 'User',
          stars: stars,
          description: '',
          carpoolId: carpoolId,
        ),
      );

      final hasFailed = result.fold((failure) {
        if (mounted) {
          context.showToast(failure.message);
        }
        return true;
      }, (_) => false);

      if (hasFailed) {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
        return;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);
    ref.read(carpoolSocketProvider.notifier).clearRecoveredCarpoolState();
    context.goNamed(
      Routes.success.name,
      extra: SuccessArgs(
        type: SuccessType.feedbackSubmitted,
        redirectRouteName: Routes.home.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passengers = _passengers;
    final l10n = context.l10n;

    return AppScaffold(
      padding: const EdgeInsets.all(16),
      scrollable: true,
      appBar: AppBar(
        title: Text(
          l10n.give_rating_users,
        ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.05, end: 0),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              text: _isSubmitting ? l10n.submitting : l10n.submit,
              onPressed: _isSubmitting ? null : _submitRatings,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

            const Gap(12),
            AppButton(
              text: l10n.skip,
              onPressed: _isSubmitting ? null : _goHome,
              backgroundColor: context.appColors.lightButton,
              fontColor: context.appColors.brand,
            ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.rate_your_passengers,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.2, end: 0),
          const Gap(AppSizes.p8),
          Text(
                l10n.your_passenger_feedback,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.appColors.textSecondary,
                ),
              )
              .animate()
              .fadeIn(delay: 220.ms, duration: 250.ms)
              .slideX(begin: 0.3, end: 0),
          const Gap(AppSizes.p20),
          if (_isLoadingPassengers)
            const Center(child: CircularProgressIndicator())
          else if (passengers.isEmpty)
            Text(
              l10n.no_passengers_to_rate,
              style: context.textTheme.bodyMedium,
            )
          else
            ...passengers.asMap().entries.map((entry) {
              final index = entry.key;
              final passenger = entry.value;
              final rating = (_ratings[passenger.id] ?? 0).toDouble();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.appColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.passenger_number(index + 1),
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(12),
                    DriverInfoSection(
                          profileImage: passenger.image ?? '',

                          userName: passenger.displayName,

                          rating: passenger.rating,
                          carImage: AppImages.noImage,
                          carName: '',
                          vehicleType: '',
                          showTrailing: false,
                          showTopBorder: false,
                        )
                        .animate()
                        .fadeIn(delay: 120.ms)
                        .slideY(begin: 0.2, end: 0),

                    const Gap(14),
                    Text(
                          l10n.your_rating,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 120.ms)
                        .slideY(begin: 0.2, end: 0),

                    const Gap(8),
                    RatingBar.builder(
                          initialRating: rating,
                          minRating: 1,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 30,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (value) {
                            setState(() {
                              _ratings[passenger.id] = value.toInt();
                            });
                          },
                        )
                        .animate()
                        .fadeIn(delay: 180.ms)
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                          curve: Curves.easeOutBack,
                        ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _FeedbackPassenger {
  const _FeedbackPassenger({
    required this.id,
    required this.displayName,
    required this.image,
    required this.rating,
  });

  final String id;
  final String displayName;
  final String image;
  final num rating;

  factory _FeedbackPassenger.fromIncomingRequest(
    CarpoolIncomingRequestEntity passenger,
  ) {
    final id = passenger.passenger.passengerId.trim().isNotEmpty
        ? passenger.passenger.passengerId.trim()
        : passenger.bookingId.trim();
    return _FeedbackPassenger(
      id: id,
      displayName: passenger.passenger.displayName,
      image: passenger.passenger.image,
      rating: passenger.passenger.rating,
    );
  }

  factory _FeedbackPassenger.fromViewPassenger(
    CarpoolPassengerEntity passenger,
  ) {
    return _FeedbackPassenger(
      id: passenger.id?.trim() ?? '',
      displayName: passenger.displayName,
      image: passenger.profilePicture ?? '',
      rating: passenger.rating,
    );
  }
}
