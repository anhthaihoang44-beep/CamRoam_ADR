import '../entities/passport_stamp.dart';

/// In-memory and local repository manager for Landmark Passport
class PassportVault {
  final Map<String, PassportStamp> _stamps = {};

  PassportVault([List<PassportStamp>? initialStamps]) {
    if (initialStamps != null) {
      for (final s in initialStamps) {
        _stamps[s.landmarkId] = s;
      }
    }
  }

  /// Try to unlock a stamp.
  /// Returns `true` if it's a BRAND NEW stamp unlocked.
  /// Returns `false` if it was already unlocked (increments visitCount instead).
  bool unlock({
    required String landmarkId,
    required String title,
    required String city,
    required String country,
    required StampSource source,
    String badgeIcon = 'landmark',
  }) {
    if (_stamps.containsKey(landmarkId)) {
      final existing = _stamps[landmarkId]!;
      _stamps[landmarkId] = existing.copyWith(
        visitCount: existing.visitCount + 1,
        unlockedAt: DateTime.now(),
        source: source,
      );
      return false; // Not brand new
    }

    _stamps[landmarkId] = PassportStamp(
      landmarkId: landmarkId,
      title: title,
      city: city,
      country: country,
      unlockedAt: DateTime.now(),
      source: source,
      badgeIcon: badgeIcon,
      visitCount: 1,
    );
    return true; // Newly unlocked
  }

  bool isUnlocked(String landmarkId) => _stamps.containsKey(landmarkId);

  PassportStamp? getStamp(String landmarkId) => _stamps[landmarkId];

  List<PassportStamp> getAllStamps() {
    final list = _stamps.values.toList();
    list.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
    return list;
  }

  int get totalUnlocked => _stamps.length;

  int getTotalVisits() {
    return _stamps.values.fold(0, (sum, stamp) => sum + stamp.visitCount);
  }

  void clear() {
    _stamps.clear();
  }
}

