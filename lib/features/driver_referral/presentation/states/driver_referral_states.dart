import '../../domain/entities/driver_referral_item_entity.dart';
import '../../domain/entities/driver_referral_summary_entity.dart';

class DriverReferralSummaryState {
  final bool isLoading;
  final DriverReferralSummaryEntity? summary;
  final String? errorMessage;

  const DriverReferralSummaryState({
    this.isLoading = false,
    this.summary,
    this.errorMessage,
  });

  DriverReferralSummaryState copyWith({
    bool? isLoading,
    DriverReferralSummaryEntity? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DriverReferralSummaryState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class DriverReferralHistoryState {
  final List<DriverReferralItemEntity> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? errorMessage;

  const DriverReferralHistoryState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 0,
    this.errorMessage,
  });

  DriverReferralHistoryState copyWith({
    List<DriverReferralItemEntity>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DriverReferralHistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
