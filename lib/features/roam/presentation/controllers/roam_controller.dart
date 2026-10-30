import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/landmark_local_datasource.dart';
import '../../data/models/landmark_model.dart';
import '../../domain/entities/passport_stamp.dart';
import '../../domain/repositories/passport_vault.dart';

class RoamState {
  final List<LandmarkModel> landmarks;
  final LandmarkModel? dailyDiscovery;
  final List<PassportStamp> stamps;
  final bool isLoading;

  const RoamState({
    this.landmarks = const [],
    this.dailyDiscovery,
    this.stamps = const [],
    this.isLoading = true,
  });

  RoamState copyWith({
    List<LandmarkModel>? landmarks,
    LandmarkModel? dailyDiscovery,
    List<PassportStamp>? stamps,
    bool? isLoading,
  }) {
    return RoamState(
      landmarks: landmarks ?? this.landmarks,
      dailyDiscovery: dailyDiscovery ?? this.dailyDiscovery,
      stamps: stamps ?? this.stamps,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RoamNotifier extends StateNotifier<RoamState> {
  final LandmarkLocalDataSource _dataSource;
  final PassportVault _vault;

  RoamNotifier(this._dataSource, this._vault) : super(const RoamState()) {
    _load();
  }

  Future<void> _load() async {
    final lms = await _dataSource.loadLandmarks();
    final daily = _dataSource.getDailyDiscovery(lms);
    state = state.copyWith(
      landmarks: lms,
      dailyDiscovery: daily,
      stamps: _vault.getAllStamps(),
      isLoading: false,
    );
  }

  bool unlockStamp(LandmarkModel lm, StampSource source) {
    final isNew = _vault.unlock(
      landmarkId: lm.id,
      title: lm.name,
      city: lm.city,
      country: lm.country,
      source: source,
      badgeIcon: lm.badgeIcon,
    );
    state = state.copyWith(stamps: _vault.getAllStamps());
    return isNew;
  }

  bool isUnlocked(String landmarkId) => _vault.isUnlocked(landmarkId);
}

final landmarkDataSourceProvider = Provider<LandmarkLocalDataSource>((ref) {
  return LandmarkLocalDataSource();
});

final passportVaultProvider = Provider<PassportVault>((ref) {
  return PassportVault();
});

final roamProvider = StateNotifierProvider<RoamNotifier, RoamState>((ref) {
  return RoamNotifier(
    ref.watch(landmarkDataSourceProvider),
    ref.watch(passportVaultProvider),
  );
});

