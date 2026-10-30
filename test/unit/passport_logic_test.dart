import 'package:flutter_test/flutter_test.dart';
import '../../lib/features/roam/domain/entities/passport_stamp.dart';
import '../../lib/features/roam/domain/repositories/passport_vault.dart';

void main() {
  group('Landmark Passport Logic Tests', () {
    late PassportVault vault;

    setUp(() {
      vault = PassportVault();
    });

    test('initial vault is empty', () {
      expect(vault.totalUnlocked, equals(0));
      expect(vault.getAllStamps(), isEmpty);
    });

    test('unlocking a new landmark returns true and adds stamp', () {
      final isNew = vault.unlock(
        landmarkId: 'lm-01',
        title: 'Eiffel Tower',
        city: 'Paris',
        country: 'France',
        source: StampSource.liveWebcamView,
        badgeIcon: 'tower',
      );

      expect(isNew, isTrue);
      expect(vault.totalUnlocked, equals(1));
      expect(vault.isUnlocked('lm-01'), isTrue);

      final stamp = vault.getStamp('lm-01');
      expect(stamp, isNotNull);
      expect(stamp!.title, equals('Eiffel Tower'));
      expect(stamp.visitCount, equals(1));
      expect(stamp.source, equals(StampSource.liveWebcamView));
    });

    test('re-visiting existing landmark returns false and increments visitCount', () {
      vault.unlock(
        landmarkId: 'lm-02',
        title: 'Colosseum',
        city: 'Rome',
        country: 'Italy',
        source: StampSource.liveWebcamView,
      );

      final secondVisit = vault.unlock(
        landmarkId: 'lm-02',
        title: 'Colosseum',
        city: 'Rome',
        country: 'Italy',
        source: StampSource.gpsCameraCapture,
      );

      expect(secondVisit, isFalse);
      expect(vault.totalUnlocked, equals(1)); // Still only 1 unique landmark stamp

      final stamp = vault.getStamp('lm-02');
      expect(stamp!.visitCount, equals(2));
      expect(stamp.source, equals(StampSource.gpsCameraCapture));
    });

    test('tracks total visits across all stamps', () {
      vault.unlock(
        landmarkId: 'lm-01',
        title: 'Eiffel Tower',
        city: 'Paris',
        country: 'France',
        source: StampSource.liveWebcamView,
      );
      vault.unlock(
        landmarkId: 'lm-02',
        title: 'Colosseum',
        city: 'Rome',
        country: 'Italy',
        source: StampSource.liveWebcamView,
      );
      vault.unlock(
        landmarkId: 'lm-01', // Revisit
        title: 'Eiffel Tower',
        city: 'Paris',
        country: 'France',
        source: StampSource.roam360,
      );

      expect(vault.totalUnlocked, equals(2));
      expect(vault.getTotalVisits(), equals(3));
    });

    test('serializes and deserializes PassportStamp to/from JSON correctly', () {
      final original = PassportStamp(
        landmarkId: 'lm-03',
        title: 'Shibuya Crossing',
        city: 'Tokyo',
        country: 'Japan',
        unlockedAt: DateTime(2026, 10, 29, 12, 0),
        source: StampSource.gpsCameraCapture,
        badgeIcon: 'crossing',
        visitCount: 5,
      );

      final json = original.toJson();
      final restored = PassportStamp.fromJson(json);

      expect(restored.landmarkId, equals(original.landmarkId));
      expect(restored.title, equals(original.title));
      expect(restored.city, equals(original.city));
      expect(restored.country, equals(original.country));
      expect(restored.unlockedAt, equals(original.unlockedAt));
      expect(restored.source, equals(original.source));
      expect(restored.badgeIcon, equals(original.badgeIcon));
      expect(restored.visitCount, equals(original.visitCount));
    });
  });
}

