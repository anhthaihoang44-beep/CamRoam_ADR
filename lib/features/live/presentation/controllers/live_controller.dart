import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/webcam_local_datasource.dart';
import '../../data/models/webcam_model.dart';
import '../../domain/entities/webcam.dart';

class LiveFeedState {
  final List<WebcamModel> allWebcams;
  final List<WebcamModel> filteredWebcams;
  final List<WebcamModel> nearbyWebcams;
  final String selectedCategory;
  final Set<String> favoriteIds;
  final bool isLoading;
  final String? errorMessage;

  const LiveFeedState({
    this.allWebcams = const [],
    this.filteredWebcams = const [],
    this.nearbyWebcams = const [],
    this.selectedCategory = 'All',
    this.favoriteIds = const {},
    this.isLoading = true,
    this.errorMessage,
  });

  LiveFeedState copyWith({
    List<WebcamModel>? allWebcams,
    List<WebcamModel>? filteredWebcams,
    List<WebcamModel>? nearbyWebcams,
    String? selectedCategory,
    Set<String>? favoriteIds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LiveFeedState(
      allWebcams: allWebcams ?? this.allWebcams,
      filteredWebcams: filteredWebcams ?? this.filteredWebcams,
      nearbyWebcams: nearbyWebcams ?? this.nearbyWebcams,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class LiveFeedNotifier extends StateNotifier<LiveFeedState> {
  final WebcamLocalDataSource _dataSource;

  LiveFeedNotifier(this._dataSource) : super(const LiveFeedState()) {
    loadFeed();
  }

  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _dataSource.loadWebcams();
      final nearby = list.take(8).toList(); // Fallback nearby
      state = state.copyWith(
        allWebcams: list,
        filteredWebcams: list,
        nearbyWebcams: nearby,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load webcam data: $e',
      );
    }
  }

  void selectCategory(String category) {
    if (category == state.selectedCategory) return;
    final filtered = _dataSource.getWebcamsByCategory(state.allWebcams, category);
    state = state.copyWith(
      selectedCategory: category,
      filteredWebcams: filtered,
    );
  }

  void updateNearbyWebcams(double lat, double lng) {
    final nearby = _dataSource.getNearbyWebcams(
      state.allWebcams,
      userLat: lat,
      userLng: lng,
      limit: 10,
    );
    state = state.copyWith(nearbyWebcams: nearby);
  }

  void toggleFavorite(String webcamId) {
    final newFavorites = Set<String>.from(state.favoriteIds);
    if (newFavorites.contains(webcamId)) {
      newFavorites.remove(webcamId);
    } else {
      newFavorites.add(webcamId);
    }
    state = state.copyWith(favoriteIds: newFavorites);
  }

  bool isFavorite(String webcamId) => state.favoriteIds.contains(webcamId);
}

final webcamDataSourceProvider = Provider<WebcamLocalDataSource>((ref) {
  return WebcamLocalDataSource();
});

final liveFeedProvider =
    StateNotifierProvider<LiveFeedNotifier, LiveFeedState>((ref) {
  final ds = ref.watch(webcamDataSourceProvider);
  return LiveFeedNotifier(ds);
});

