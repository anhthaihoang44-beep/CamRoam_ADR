/// Deterministic daily discovery selector
class DailySeed {
  DailySeed._();

  /// Returns a deterministic index for a given [date] and [totalCount].
  /// Guaranteed to return the exact same index for the same calendar day (YYYY-MM-DD).
  static int getDailyIndex(int totalCount, {DateTime? date}) {
    if (totalCount <= 0) return 0;
    final targetDate = date ?? DateTime.now();
    final dayKey = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
    
    // Jenkins-one-at-a-time or simple DJB2 hash
    int hash = 5381;
    for (int i = 0; i < dayKey.length; i++) {
      hash = ((hash << 5) + hash) + dayKey.codeUnitAt(i);
    }
    
    return (hash.abs()) % totalCount;
  }

  /// Returns the current date key string, e.g. "2026-10-29"
  static String getDateKey({DateTime? date}) {
    final d = date ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

