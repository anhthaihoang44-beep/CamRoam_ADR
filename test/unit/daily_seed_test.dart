import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/utils/daily_seed.dart';

void main() {
  group('DailySeed Deterministic Algorithm Tests', () {
    test('same date always returns the identical index', () {
      final date = DateTime(2026, 10, 29);
      const totalCount = 60;

      final index1 = DailySeed.getDailyIndex(totalCount, date: date);
      final index2 = DailySeed.getDailyIndex(totalCount, date: date);
      final index3 = DailySeed.getDailyIndex(totalCount, date: date);

      expect(index1, equals(index2));
      expect(index2, equals(index3));
    });

    test('daily index is strictly within range [0, totalCount - 1]', () {
      const totalCount = 60;
      for (int day = 1; day <= 30; day++) {
        final date = DateTime(2026, 10, day);
        final index = DailySeed.getDailyIndex(totalCount, date: date);
        expect(index, greaterThanOrEqualTo(0));
        expect(index, lessThan(totalCount));
      }
    });

    test('date key formatting matches YYYY-MM-DD', () {
      final key1 = DailySeed.getDateKey(date: DateTime(2026, 5, 4));
      expect(key1, equals('2026-05-04'));

      final key2 = DailySeed.getDateKey(date: DateTime(2026, 10, 29));
      expect(key2, equals('2026-10-29'));
    });

    test('handles totalCount 0 or negative gracefully without throwing', () {
      expect(DailySeed.getDailyIndex(0), equals(0));
      expect(DailySeed.getDailyIndex(-5), equals(0));
    });
  });
}

