import 'package:flutter_test/flutter_test.dart';
import '../../lib/core/utils/haversine_calc.dart';

void main() {
  group('HaversineCalc Tests', () {
    test('calculates distance between Hanoi and Ho Chi Minh City accurately (~1138 km)', () {
      const hanoiLat = 21.0285;
      const hanoiLon = 105.8542;
      const hcmLat = 10.8231;
      const hcmLon = 106.6297;

      final distKm = HaversineCalc.distanceKm(hanoiLat, hanoiLon, hcmLat, hcmLon);

      // Known great-circle distance is ~1138 km
      expect(distKm, greaterThan(1130.0));
      expect(distKm, lessThan(1150.0));
    });

    test('calculates distance between London and Paris (~343 km)', () {
      const londonLat = 51.5074;
      const londonLon = -0.1278;
      const parisLat = 48.8566;
      const parisLon = 2.3522;

      final distKm = HaversineCalc.distanceKm(londonLat, londonLon, parisLat, parisLon);
      expect(distKm, greaterThan(340.0));
      expect(distKm, lessThan(350.0));
    });

    test('same coordinate yields 0 distance', () {
      final dist = HaversineCalc.distanceKm(40.7128, -74.0060, 40.7128, -74.0060);
      expect(dist, closeTo(0.0, 0.0001));
    });

    test('converts km to miles and vice versa accurately', () {
      const km = 100.0;
      final miles = HaversineCalc.toMiles(km);
      expect(miles, closeTo(62.1371, 0.01));

      final convertedBack = HaversineCalc.toKm(miles);
      expect(convertedBack, closeTo(km, 0.01));
    });

    test('multi-point route calculation sums individual legs', () {
      const p1 = GeoPoint(21.0285, 105.8542); // Hanoi
      const p2 = GeoPoint(16.0544, 108.2022); // Da Nang
      const p3 = GeoPoint(10.8231, 106.6297); // HCMC

      final totalRoute = HaversineCalc.routeDistanceKm([p1, p2, p3]);
      final leg1 = HaversineCalc.distanceKm(p1.latitude, p1.longitude, p2.latitude, p2.longitude);
      final leg2 = HaversineCalc.distanceKm(p2.latitude, p2.longitude, p3.latitude, p3.longitude);

      expect(totalRoute, closeTo(leg1 + leg2, 0.001));
    });

    test('route with fewer than 2 points returns 0.0', () {
      expect(HaversineCalc.routeDistanceKm([]), equals(0.0));
      expect(HaversineCalc.routeDistanceKm([const GeoPoint(10, 20)]), equals(0.0));
    });

    test('format helper outputs formatted strings with units', () {
      expect(HaversineCalc.format(1234.56, inMiles: false, decimals: 1), equals('1234.6 km'));
      expect(HaversineCalc.format(100.0, inMiles: true, decimals: 1), equals('62.1 mi'));
    });
  });
}

