import 'package:driver_app/features/carpool/domain/entities/carpool_location_entity.dart';

import '../../../../core/services/places_search_service.dart';

class CarpoolRouteState {
  final bool isLoading;
  final bool isFetchingSuggestions, isResolvingSelection;
  final PlacesFailure? searchError;
  final List<CarpoolLocationEntity> recents;
  final String searchQuery;
  final List<PlaceSuggestion> searchResults;
  final String? errorMessage;

  const CarpoolRouteState({
    this.isLoading = false,
    this.isFetchingSuggestions = false,
    this.isResolvingSelection = false,
    this.searchError,
    this.recents = const [],
    this.searchQuery = '',
    this.searchResults = const [],
    this.errorMessage,
  });

  bool get hasRecent => recents.isNotEmpty;
  bool get isSearching => searchQuery.trim().isNotEmpty;

  CarpoolRouteState copyWith({
    bool? isLoading,
    bool? isFetchingSuggestions,
    bool? isResolvingSelection,
    PlacesFailure? searchError,
    List<CarpoolLocationEntity>? recents,
    String? searchQuery,
    List<PlaceSuggestion>? searchResults,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CarpoolRouteState(
      isLoading: isLoading ?? this.isLoading,
      isFetchingSuggestions:
          isFetchingSuggestions ?? this.isFetchingSuggestions,
      isResolvingSelection: isResolvingSelection ?? this.isResolvingSelection,
      searchError: clearError ? null : (searchError ?? this.searchError),
      recents: recents ?? this.recents,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
