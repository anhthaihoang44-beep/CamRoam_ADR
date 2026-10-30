import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/utils/coord_formatter.dart';

void main() {
  group('CoordFormatter Tests', () {
    test('formats northern and western coordinates correctly (NYC)', () {
      final formatted = CoordFormatter.format(40.7484, -73.9857);
      expect(formatted, equals('40.7484° N, 73.9857° W'));
    });

    test('formats southern and eastern coordinates correctly (Sydney)', () {
      final formatted = CoordFormatter.format(-33.8568, 151.2153);
      expect(formatted, equals('33.8568° S, 151.2153° E'));
    });

    test('formats northern and eastern coordinates correctly (Hanoi)', () {
      final formatted = CoordFormatter.format(21.0285, 105.8542);
      expect(formatted, equals('21.0285° N, 105.8542° E'));
    });

    test('formats southern and western coordinates correctly (Rio de Janeiro)', () {
      final formatted = CoordFormatter.format(-22.9711, -43.1822);
      expect(formatted, equals('22.9711° S, 43.1822° W'));
    });

    test('handles equator and prime meridian (0, 0)', () {
      final formatted = CoordFormatter.format(0.0, 0.0);
      expect(formatted, equals('0.0000° N, 0.0000° E'));
    });

    test('respects custom decimal places', () {
      final formatted = CoordFormatter.format(40.748412, -73.985734, decimals: 2);
      expect(formatted, equals('40.75° N, 73.99° W'));
    });

    test('formatLat and formatLng helpers', () {
      expect(CoordFormatter.formatLat(48.8584), equals('48.8584° N'));
      expect(CoordFormatter.formatLat(-13.1631), equals('13.1631° S'));
      expect(CoordFormatter.formatLng(2.2945), equals('2.2945° E'));
      expect(CoordFormatter.formatLng(-122.4783), equals('122.4783° W'));
    });

    test('formatHeading correctly maps cardinal and intercardinal labels', () {
      expect(CoordFormatter.formatHeading(0), equals('0° N'));
      expect(CoordFormatter.formatHeading(360), equals('0° N'));
      expect(CoordFormatter.formatHeading(90), equals('90° E'));
      expect(CoordFormatter.formatHeading(180), equals('180° S'));
      expect(CoordFormatter.formatHeading(270), equals('270° W'));
      expect(CoordFormatter.formatHeading(76), equals('76° ENE'));
    });
  });
}

